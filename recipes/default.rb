#
# Cookbook Name:: et_accounts_app
# Recipe:: default
#
# Copyright (C) 2014 EverTrue, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'debian'
  include_recipe 'apt'
  package 'fontconfig'
end

package 'git'

include_recipe 'node'
include_recipe 'et_users::evertrue'
include_recipe 'apache2'

directory node['et_accounts_app']['deploy_to'] do
  owner 'deploy'
  group node['apache']['group']
  mode '2775'
end

# Install some excellent Apache config rules, courtesy of h5bp.com
cookbook_file "#{node['apache']['dir']}/conf.d/h5bp.conf" do
  source 'h5bp.conf'
  mode '0644'
  owner 'root'
  group node['apache']['root_group']
  action :create_if_missing
end

web_app 'accounts' do
  server_name node['et_accounts_app']['server_name']
  docroot node['et_accounts_app']['docroot']
end
