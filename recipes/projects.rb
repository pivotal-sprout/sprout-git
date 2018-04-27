# frozen_string_literal: true

# Recipe to clone git repositories into the users workspace_directory
# look at soloistrc for example

include_recipe 'sprout-base::workspace_directory'

settings_hash = node['sprout']['git']['projects_settings']
# rubocop:disable Metrics/BlockLength
node['sprout']['git']['projects'].each do |project_hash|
  if project_hash['url']
    repo_address = project_hash['url']
  elsif project_hash['github']
    repo_address = "git@github.com:#{project_hash['github']}.git"
  end

  if project_hash.fetch('recursive', 'not present') != 'not present'
    do_recursive = '--recursive' if project_hash['recursive']
  elsif settings_hash['recursive']
    do_recursive = '--recursive'
  end

  repo_name = project_hash['name'] || %r{^.+\/([^\/\.]+)(?:\.git)?$}.match(repo_address)[1]
  repo_dir = project_hash['workspace_path']
  repo_branch = project_hash['branch'] || 'master'
  post_clone_commands = project_hash['post_clone_commands'] || []
  update = project_hash.attribute?('update') ? project_hash['update'] : false

  repo_dir ||= "#{node['sprout']['home']}/#{node['workspace_directory']}"
  repo_dir = File.expand_path(repo_dir)

  directory "workspace path for #{repo_name}" do
    path repo_dir
    owner node['sprout']['user']
    mode '0755'
    action :create
    recursive true
  end
  repo_existed_originally = ::File.exist?("#{repo_dir}/#{repo_name}")

  execute [
    'git',
    'clone',
    '-b',
    repo_branch,
    do_recursive,
    repo_address,
    repo_name
  ].compact.join(' ') do
    # execute "git clone -b #{repo_branch}#{do_recursive} #{repo_address} #{repo_name}" do
    user node['sprout']['user']
    cwd repo_dir
    not_if { ::File.exist?("#{repo_dir}/#{repo_name}") }
  end

  if update
    execute 'git pull -r' do # ~FC040 -- git resource cannot rebase
      user node['sprout']['user']
      cwd "#{repo_dir}/#{repo_name}"
      ignore_failure true
      only_if { repo_existed_originally }
    end
  end

  post_clone_commands.each do |post_clone_command|
    execute post_clone_command do
      user node['sprout']['user']
      cwd "#{repo_dir}/#{repo_name}"
      ignore_failure true
      not_if { repo_existed_originally }
    end
  end
end
# rubocop:enable Metrics/BlockLength
