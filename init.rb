#!/bin/env ruby
# encoding: utf-8

require 'redmine'
require 'projects_helper_patch'

Redmine::Plugin.register :chiliproject_projectlist_details do
  name 'Project List Details'
  author 'Alexander Blum'
  description 'This plugin for ChiliProject include details of projects within the project list'
  version '0.1'
  author_url 'mailto:alexander.blum@c3s.cc'
  url 'https://github.com/C3S/chiliproject_projectlist_details'
  settings(:default => {
    'fullViewGroupIds' => nil
  }, :partial => 'settings/chiliproject_projectlist_details')
end

# Generate Projectlist
Dispatcher.to_prepare do
  require_dependency 'projects_helper'
  ProjectsHelper.send(:include, ProjectsHelperPatch)
end

class RedmineMyPluginHookListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
      stylesheet_link_tag "projectlistdetails", :plugin => 'chiliproject_projectlist_details'
  end
end