include_recipe 'sprout-git::install'

node['sprout']['git']['global_config'].each_pair do |setting, value|
  execute "set git config setting #{setting}" do
    command "git config --global #{setting} #{value}"
    user node['current_user']
  end
end
