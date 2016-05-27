pretty_format = %{--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'}
node.default['sprout']['git']['base_aliases'] = [
  'st status',
  'di diff',
  'co checkout',
  'ci commit',
  'br branch',
  'sta stash',
  'llog "log --date=local"',
  'flog "log --pretty=fuller --decorate"',
  "lg \"log --graph #{pretty_format} --abbrev-commit --date=relative\"",
  'lol "log --graph --decorate --oneline"',
  'lola "log --graph --decorate --oneline --all"',
  'blog "log origin/master... --left-right"',
  'ds "diff --staged"',
  'fixup "commit --fixup"',
  'squash "commit --squash"',
  'unstage "reset HEAD"',
  'rum "rebase master@{u}"'
]

node.default['sprout']['git']['aliases'] = [
  # a space delimited string containing the alias-name and alias-value
]
