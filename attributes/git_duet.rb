# frozen_string_literal: true

node.default['sprout']['git']['git_duet'] = {
  'config' => {
    # see: https://github.com/git-duet/git-duet
    'alias.dci' => 'duet-commit',
    'alias.drv' => 'duet-revert',
    'alias.dmg' => 'duet-merge',
    'alias.drb' => %q('rebase -i --exec "git duet-commit --amend --reset-author"')
  }
}
