# frozen_string_literal: true

include_recipe 'sprout-git::install'

node['sprout']['git']['global_config'].each_pair do |setting, value|
  sprout_git_config setting do
    setting_value value
    scope :global
  end
end
