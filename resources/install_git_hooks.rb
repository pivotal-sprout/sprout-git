property :search_dir, String, name_attribute: true

property :user, String, default: node['sprout']['user']

default_action :create

action :create do
  ruby_block 'installing git repo hooks' do
    block do
      Recipe::GitHooks.new(user).install(search_dir)
    end
  end
end
