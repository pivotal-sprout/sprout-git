property :search_dir, Array, name_attribute: true

property :user, String, default: node['sprout']['user']
property :group, String, default: node['sprout']['group']

default_action :create

action :create do
  ruby_block 'installing git repo hooks' do
    block do
      Recipe::GitHooks.new(user, group).install(search_dir)
    end
  end
end
