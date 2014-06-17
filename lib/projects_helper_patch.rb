#!/bin/env ruby
# encoding: utf-8

module ProjectsHelperPatch

	def self.included(base) # :nodoc:

		base.send(:include, InstanceMethods)

		base.class_eval do
			alias_method_chain :render_project_hierarchy, :roles
		end

	end

	module InstanceMethods

		def render_project_hierarchy_with_roles(projects)
			s = ''

			# show all projects for allowed groups
			if not Setting.plugin_chiliproject_projectlist_details['fullViewGroupIds'].empty?
				groupIds = Setting.plugin_chiliproject_projectlist_details['fullViewGroupIds'].split(",").map { |s| s.to_i }
				groupIds.each do |groupId|
					group = Group.find_by_id(groupId)
					if group.try(:users).try(:include?, User.current)
						projects = Project.active.find(:all, :order => 'lft')
					end
				end
			end

			if projects.any?
				ancestors = []
				original_project = @project
				projects.each do |project|
					# set the project environment to please macros.
					@project = project
					if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
						s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>\n"
					else
						ancestors.pop
						s << "</li>"
						while (ancestors.any? && !project.is_descendant_of?(ancestors.last))
							ancestors.pop
							s << "</ul></li>\n"
						end
					end
					classes = (ancestors.empty? ? 'root' : 'child')
					s << "<li class='#{classes}'><div class='#{classes}'>" +
						   link_to_project(project, {}, :class => "project #{User.current.member_of?(project) ? 'my-project' : nil}")

					if project.users_by_role.any?
						s << "<div class='projectlistdetails'>"
						project.users_by_role.keys.sort.each do |role|
							s << "<span class='projectlistdetails-role-name'> | "+h(role)+":</span> <span class='projectlistdetails-role-user'>"+project.users_by_role[role].sort.collect{|u| link_to_user u}.join(", ")+"</span><br />"
						end
						s << "</div>"
					end
					 
					s << "<div class='wiki description'>#{textilizable(project.short_description, :project => project)}</div>" unless project.description.blank?
					s << "</div>\n"
					ancestors << project
				end
				s << ("</li></ul>\n" * ancestors.size)
				@project = original_project
			end
			s

		end

	end

end