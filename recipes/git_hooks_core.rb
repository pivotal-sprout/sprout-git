# frozen_string_literal: true

include_recipe 'sprout-git::install'

hooks_repository = node['sprout']['git']['hooks']['repository']
git_hooks_dir = node['sprout']['git']['hooks']['dir']

if hooks_repository
  directory File.dirname(git_hooks_dir) do
    user node['sprout']['user']
    group node['sprout']['group']
    mode '0755'
    action :create
  end

  git git_hooks_dir do
    repository hooks_repository
    revision node['sprout']['git']['hooks']['revision']
    user node['sprout']['user']
    group node['sprout']['group']
  end

  sprout_git_config 'core.hooksPath' do
    setting_value git_hooks_dir
  end
else
  log 'git_hooks_core' do
    message 'Error: sprout.git.hooks.repository must be set for this recipe to run.'
    level :warn
  end
end
