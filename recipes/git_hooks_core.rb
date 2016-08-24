include_recipe 'sprout-git::cred_alert'
include_recipe 'sprout-git::install'

git_hooks_dir = node['sprout']['git']['hooks']['dir']

directory File.dirname(git_hooks_dir) do
  user node['sprout']['user']
  group node['sprout']['group']
  mode '0755'
  action :create
end

git git_hooks_dir do
  repository node['sprout']['git']['hooks']['repository']
  revision 'master'
  user node['sprout']['user']
  group node['sprout']['group']
end

sprout_git_config 'core.hooksPath' do
  setting_value git_hooks_dir
end
