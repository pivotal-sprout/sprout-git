# frozen_string_literal: true

include_attribute 'sprout-base::home'
include_attribute 'sprout-base::workspace_directory'

node.default['sprout']['git']['hooks'] = {
  'repository' => nil,
  'revision' => 'master',
  'dir' => File.join(node['sprout']['home'], node['workspace_directory'], 'git-hooks-core')
}
