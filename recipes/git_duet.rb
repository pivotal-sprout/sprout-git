include_recipe 'homebrew'
include_recipe 'sprout-git::git_duet_global'
include_recipe 'sprout-git::git_duet_rotate_authors'
include_recipe 'sprout-git::authors'

homebrew_tap 'git-duet/homebrew-tap'

package 'git-duet'
