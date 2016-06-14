include_recipe 'sprout-git::git_hooks'

git_hooks_global_dir = node['sprout']['git']['git_hooks']['global_dir']

if node['platform'] == 'mac_os_x'
  package 'git-secrets'
else
  log 'Should install git-secrets for linux, but not implemented...'
end

execute 'git secrets --register-aws --global' do
  returns [0, 1]
end

execute "git config --global -l | grep 'secrets\.' >~/.git-secrets-patterns.bak"
execute 'git config --global --remove-section secrets'

execute 'git secrets --add --global "AKIA[A-Z0-9]{16}"'

execute [
  'git secrets --add --global ',
  %q("(\"|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)),
  %q((\"|')?\\s*(:|=>|=)\\s*(\"|')?[A-Za-z0-9/\\+=]{40}(\"|')?")
].join('')

execute [
  'git secrets --add --global ',
  %q("(\"|')?(AWS|aws|Aws)?_?(ACCOUNT|account|Account)_?(ID|id|Id)?),
  %q((\"|')?\\s*(:|=>|=)\\s*(\"|')?[0-9]{4}\\-?[0-9]{4}\\-?[0-9]{4}(\"|')?")
].join('')

execute [
  'git secrets --add --global ',
  %q("(\"|')*[A-Za-z0-9_-]*),
  '([sS]ecret|[pP]rivate[-_]?[Kk]ey|[Pp]assword|[sS]alt|SECRET|PRIVATE[-_]?KEY|PASSWORD|SALT)',
  %q([\"']*\\s*(=|:|\\s|:=|=>)\\s*[\"'][A-Za-z0-9.$+=&\\/_\\\\\\-]{12,}(\"|')")
].join('')

execute 'git secrets --add --allowed --global "[\"]\\\\$"'
execute 'git secrets --add --allowed --global "[fF][aA][kK][eE]"'
execute 'git secrets --add --allowed --global "[eE][xX][aA][mM][pP][lL][eE]"'

hooks = [
  'pre-commit',
  'commit-msg',
  'prepare-commit-msg'
]

hooks.each do |hook|
  directory "#{git_hooks_global_dir}/#{hook}" do
    mode 0755
    owner node['sprout']['user']
  end
  template "#{git_hooks_global_dir}/#{hook}/00-git-secrets" do
    mode 0755
    owner node['sprout']['user']
    source '00-git-secrets.erb'
    variables hook_name: "#{hook.tr('-', '_')}_hook"
  end
end
