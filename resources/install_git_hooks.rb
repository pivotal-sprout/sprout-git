property :git_repo_dirs, Array

property :owner, String, default: node['sprout']['user']

default_action :create

action :create do
  ruby_block 'installing git repo hooks' do
    block do
      Recipe::GitHooks.install(git_repo_dirs, owner)
    end
  end
end
