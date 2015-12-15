# Recipe to clone git repositories into the users workspace_directory
# look at soloistrc for example

include_recipe 'sprout-base::workspace_directory'

node['sprout']['git']['projects'].each do |hash_or_legacy_array|
  post_clone_commands = []
  if hash_or_legacy_array.is_a?(Hash)
    project_hash = hash_or_legacy_array
    repo_address = if project_hash['url']
      project_hash['url']
    elsif project_hash['github']
      "git@github.com:#{project_hash['github']}.git"
    end
    do_recursive = "--recursive" if project_hash['recursive']
    repo_name = project_hash['name'] || %r{^.+\/([^\/\.]+)(?:\.git)?$}.match(repo_address)[1]
    repo_dir = project_hash['workspace_path']
    repo_branch = project_hash['branch'] || 'master'
    post_clone_commands = project_hash['post_clone_commands'] || []
  else
    legacy_array = hash_or_legacy_array
    repo_name = legacy_array[0]
    repo_address = legacy_array[1]
    post_clone_commands << 'git submodule update --init --recursive'
    repo_branch = 'master'
  end
  repo_dir ||= "#{node['sprout']['home']}/#{node['sprout']['git']['workspace_directory']}"
  repo_dir = File.expand_path(repo_dir)

  directory repo_dir do
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
#  execute "git clone -b #{repo_branch}#{do_recursive} #{repo_address} #{repo_name}" do
    user node['sprout']['user']
    cwd repo_dir
    not_if { ::File.exist?("#{repo_dir}/#{repo_name}") }
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
