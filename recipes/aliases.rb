include_recipe 'sprout-git::install'

aliases = node['sprout']['git']['aliases'] + node['sprout']['git']['base_aliases']
aliases.each do |alias_string|
  abbrev = alias_string.split[0]
  execute "git config --global alias.#{alias_string}" do
    user node['sprout']['user']
    only_if "[ -z \"$(git config --global alias.#{abbrev})\" ]"
  end
end
