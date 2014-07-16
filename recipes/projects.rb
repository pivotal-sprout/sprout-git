# Recipe to clone git repositories into the users workspace_directory
# look at soloistrc for example

include_recipe 'sprout-base::workspace_directory'

node['sprout']['git']['projects'].each do |hash_or_legacy_array|
  post_clone_commands = []
  if hash_or_legacy_array.is_a?(Hash)
    project_hash = hash_or_legacy_array
    repo_address = project_hash['url']
    repo_name = project_hash['name'] || %r{^.+\/([^\/\.]+)(?:\.git)?$}.match(repo_address)[1]
    repo_dir = project_hash['workspace_path']
    post_clone_commands = project_hash['post_clone_commands'] || []
  else
    legacy_array = hash_or_legacy_array
    repo_name = legacy_array[0]
    repo_address = legacy_array[1]
  end
  repo_dir ||= "#{node['sprout']['home']}/#{node['sprout']['git']['workspace_directory']}"
  repo_dir = File.expand_path(repo_dir)

  directory repo_dir do
    owner node['current_user']
    mode '0755'
    action :create
    recursive true
  end

  execute "git clone #{repo_address} #{repo_name}" do
    user node['current_user']
    cwd repo_dir
    not_if { ::File.exist?("#{repo_dir}/#{repo_name}") }
  end

  post_clone_commands.each do |post_clone_command|
    execute post_clone_command do
      user node['current_user']
      cwd "#{repo_dir}/#{repo_name}"
      ignore_failure true
    end
  end

  ['git branch --set-upstream master origin/master',  'git submodule update --init --recursive'].each do |git_cmd|
    execute "#{repo_name} - #{git_cmd}" do
      command git_cmd
      cwd "#{repo_dir}/#{repo_name}"
      user node['current_user']
      not_if { ::File.exist?("#{repo_dir}/#{repo_name}") }
    end
  end
end
