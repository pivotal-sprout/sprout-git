include_recipe 'sprout-git::install'

aliases = node['sprout']['git']['base_aliases'] + node['sprout']['git']['aliases']
aliases.each do |alias_string|
  abbrev = alias_string.split[0]
  execute "set alias #{abbrev}" do
    command "git config --global alias.#{alias_string}"
    user node['current_user']
    only_if "[ -z `git config --global alias.#{abbrev}` ]"
  end
end
