git_hooks_file_tgz='/usr/local/bin/git-hooks.tgz'
git_hooks_file='/usr/local/bin/git-hooks'
git_hooks_uri='https://github.com/git-hooks/git-hooks/releases/download/v1.1.3/git-hooks_darwin_amd64.tar.gz'
git_hooks_global_dir='/usr/local/share/githooks'

remote_file git_hooks_file_tgz do
  source git_hooks_uri
  not_if { File.exists?(git_hooks_file) }
end

execute 'install git-hooks' do
  command "tar -xf #{git_hooks_file_tgz} -O > #{git_hooks_file}"
  not_if { File.exists?(git_hooks_file) }
end

file git_hooks_file_tgz do
  action :delete
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

# Chef::Resource::git_post_commit_hook.new('git_post_commit_hook', )

home = node.default['sprout']['home']

sprout_git_post_commit_hook 'installing git post-commit hook ~/workspace/*' do
  git_repo_dirs Dir.glob(File.join(home, 'workspace', '*'))
  owner node['sprout']['user']
end

sprout_git_post_commit_hook 'installing git post-commit hook ~/go/src/github.com/*/*' do
  git_repo_dirs Dir.glob(File.join(home, 'go', 'src', 'github.com', '*', '*'))
  owner node['sprout']['user']
end
