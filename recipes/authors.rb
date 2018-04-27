# frozen_string_literal: true

# Manage a .git-authors file as expected by https://github.com/modcloth/git-duet

template "#{node['sprout']['home']}/.git-authors" do
  owner node['sprout']['user']
  source 'authors.yml.erb'
end
