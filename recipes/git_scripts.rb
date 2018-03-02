include_recipe 'sprout-base::user_owns_usr_local'

checkout_path = "#{Chef::Config['file_cache_path']}/git_scripts"
installation_path = '/usr/local/bin'

git checkout_path do
  repository 'https://github.com/pivotal/git_scripts.git'
  reference 'master'
  action :export
end

execute "cp #{checkout_path}/bin/* #{installation_path}" do
  user node['sprout']['user']
  not_if 'which git-pair'
end

template "#{node['sprout']['home']}/.pairs" do
  owner node['sprout']['user']
  source 'pairs.yml.erb'
end
