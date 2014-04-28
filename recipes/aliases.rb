include_recipe 'sprout-git::install'

pretty_format = %q{--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'}
aliases = <<EOF
st status
di diff
co checkout
ci commit
br branch
sta stash
llog \"log --date=local\"
flog \"log --pretty=fuller --decorate\"
lg \"log --graph #{pretty_format} --abbrev-commit --date=relative\"
lol \"log --graph --decorate --oneline\"
lola \"log --graph --decorate --oneline --all\"
blog \"log origin/master... --left-right\"
ds \"diff --staged\"
fixup \"commit --fixup\"
squash \"commit --squash\"
unstage \"reset HEAD\"
rum \"rebase master@{u}\"
EOF

aliases.split("\n").each do |alias_string|
  abbrev = alias_string.split[0]
  execute "set alias #{abbrev}" do
    command "git config --global alias.#{alias_string}"
    user node['current_user']
    only_if "[ -z `git config --global alias.#{abbrev}` ]"
  end
end
