git_hooks_file='/usr/local/bin/git-hooks'
git_hooks_uri='https://github.com/git-hooks/git-hooks/releases/download/v1.1.3/git-hooks_darwin_amd64.tar.gz'
git_hooks_global_dir='/usr/local/share/githooks'

execute 'install git-hooks' do
  command "curl -L #{git_hooks_uri} | tar -xf - -O > #{git_hooks_file}"
  not_if File.exists?(git_hooks_file)
end

file git_hooks_file do
  mode '0755'
  owner node['sprout']['user']
end

directory git_hooks_global_dir do
  mode '0755'
  owner node['sprout']['user']
end

execute "git config --system --add hooks.global #{git_hooks_global_dir}"

ruby_block 'configure the individual repos with the security scan post-commit-hook' do
  block do
    home = node.default['sprout']['home']
    workspace_dirs = Dir.glob(File.join(home, 'workspace' '*'))
    gopath_dirs = Dir.glob(File.join(home, 'go', 'src', 'github.com', '*', '*'))

    potential_repos = [workspace_dirs , gopath_dirs].flatten
    repos = potential_repos.select do |potential_repo|
      git_repo_path = File.join(potential_repo, '.git')
      File.directory?(git_repo_path)
    end
    repos.each do |repo|
      potential_hook_files = Dir.glob(File.join(repo, '.git', 'hooks', '*' ))
      hook_files = potential_hook_files.select do | potential_hook_file |
        !! potential_hook_file[/.sample$/]
      end

      Chef::Log.info("adding hooks for repo #{repo}")
    end
  end
end