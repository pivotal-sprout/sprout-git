include_recipe 'sprout-base::user_owns_usr_local'

tarball_url = 'https://github.com/pivotal/git_scripts/tarball/master'
src_path = File.join(Chef::Config['file_cache_path'], 'git_scripts.tgz')
extract_path = '/usr/local/bin'

remote_file src_path do
  source tarball_url
end

execute "tar --strip=2 -xzf #{src_path} -C #{extract_path}" do
  user node['sprout']['user']
  not_if 'which git-pair'
end

template "#{node['sprout']['home']}/.pairs" do
  owner node['sprout']['user']
  source 'pairs.yml.erb'
end
