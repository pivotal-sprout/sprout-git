git_hooks_file_tgz = '/usr/local/bin/git-hooks.tgz'
git_hooks_file = '/usr/local/bin/git-hooks'
git_hooks_uri = 'https://github.com/git-hooks/git-hooks/releases/download/v1.1.3/git-hooks_darwin_amd64.tar.gz'
git_hooks_global_dir = node['sprout']['git']['git_hooks_global_dir']
git_hooks_global_templates_dir = '/usr/local/share/githooks-templatedir'

# Downloading & installing git-hooks is 3 resources to placate foodcritic's FC041
remote_file git_hooks_file_tgz do
  source git_hooks_uri
  not_if { File.exist?(git_hooks_file_tgz) }
end

execute 'install git-hooks' do
  command "tar -xf #{git_hooks_file_tgz} -O > #{git_hooks_file}"
  not_if { File.exist?(git_hooks_file) }
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

sprout_git_post_commit_hook 'installing git post-commit hook ~/workspace/*' do
  git_repo_dirs Dir.glob(File.join(node['sprout']['home'], 'workspace', '*'))
  owner node['sprout']['user']
end

sprout_git_post_commit_hook 'installing git post-commit hook ~/go/src/github.com/*/*' do
  git_repo_dirs Dir.glob(File.join(node['sprout']['home'], 'go', 'src', 'github.com', '*', '*'))
  owner node['sprout']['user']
end

directory '/usr/local/share/githooks-templatedir/hooks' do
  mode '0755'
  recursive true
  owner node['sprout']['user']
end

execute "git config --global init.templatedir #{git_hooks_global_templates_dir}"

ruby_block 'git-hook templates' do
  block do
    system_git_core = '/usr/share/git-core'
    local_git_core = '/usr/local/share/git-core'

    actual_git_core = Dir.exist?(system_git_core) ? system_git_core : local_git_core

    Dir.glob("#{actual_git_core}/templates/hooks/*.sample").each do |sample_hook|
      new_hook_name = File.basename(sample_hook, '.sample')

      r = Chef::Resource::Template.new "#{git_hooks_global_templates_dir}/hooks/#{new_hook_name}", run_context
      r.cookbook 'sprout-git'
      r.source  'git_hook.erb'
      r.owner node['sprout']['user']
      r.mode 0755
      r.run_action :create
    end
  end
end
