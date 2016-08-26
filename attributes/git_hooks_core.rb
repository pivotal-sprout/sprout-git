include_attribute 'sprout-base::home'
include_attribute 'sprout-base::workspace_directory'

node.default['sprout']['git']['hooks'] = {
  'repository' => nil,
  'dir' => File.join(node['sprout']['home'], node['workspace_directory'], 'git-hooks-core')
}
