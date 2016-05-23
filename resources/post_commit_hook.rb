property :git_repo_dirs, Array

property :owner, String, default: node['sprout']['user']

default_action :create

action :create do
  ruby_block 'installing git repo hooks' do
    block do
      Recipe::PostCommitHook.install_post_commit_hook(git_repo_dirs)
    end
  end
end
