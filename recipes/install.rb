# frozen_string_literal: true

include_recipe 'homebrew'

# Explicitly choose a unique resource name to avoid warnings
# See https://tickets.opscode.com/browse/CHEF-2812
package 'sprout-git: git' do
  package_name 'git'
end
