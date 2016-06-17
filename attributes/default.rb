node.default['sprout']['git']['aliases'] = [
  # a space delimited string containing the alias-name and alias-value
]
node.default['sprout']['git']['base_aliases'] = [
  'st status',
  'di diff',
  'co checkout',
  'ci commit',
  'br branch',
  'sta stash',
  'llog "log --date=local"',
  'flog "log --pretty=fuller --decorate"',
  [
    'lg',
    [
      '"log', # open quotes around alias. Included here to avoid a space at the beginning of a line, that breaks git
      '--graph',
      "--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'",
      '--abbrev-commit',
      '"' # close quotes around the alias
    ]
  ].flatten.join(' '),
  'lol "log --graph --decorate --oneline"',
  'lola "log --graph --decorate --oneline --all"',
  'blog "log origin/master... --left-right"',
  'ds "diff --staged"',
  'fixup "commit --fixup"',
  'squash "commit --squash"',
  'unstage "reset HEAD"',
  'rum "rebase master@{u}"'
]

node.default['sprout']['git']['editor'] = 'vim'

node.default['sprout']['git']['global_config'] = {
  'core.pager' => '"less -FXRS -x2"',
  'core.excludesfile' => "#{node['sprout']['home']}/.gitignore_global",
  'apply.whitespace' => 'nowarn',
  'color.branch' => 'auto',
  'color.diff' => 'auto',
  'color.interactive' => 'auto',
  'color.status' => 'auto',
  'color.ui' => 'auto',
  'branch.autosetupmerge' => 'true',
  'rebase.autosquash' => 'true',
  'push.default' => 'simple'
}
