template "#{node['sprout']['home']}/.gitignore_global" do
  source 'gitignore_global.erb'
  owner node['sprout']['user']
  variables(ignore_idea: node['git_global_ignore_idea'] || true)
end
