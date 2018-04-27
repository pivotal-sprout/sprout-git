# frozen_string_literal: true

include_recipe 'homebrew'
include_recipe 'sprout-git::git_duet_global'
include_recipe 'sprout-git::git_duet_rotate_authors'
include_recipe 'sprout-git::authors'

homebrew_tap 'git-duet/tap'

package 'git-duet'

execute 'link git-duet' do
  command 'brew link git-duet'
  user    node['sprout']['user']
end

node['sprout']['git']['git_duet']['config'].each_pair do |setting, value|
  sprout_git_config setting do
    setting_value value
  end
end
