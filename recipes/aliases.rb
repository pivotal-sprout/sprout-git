include_recipe 'sprout-git::install'

aliases = node['sprout']['git']['aliases'] + node['sprout']['git']['base_aliases']

aliases.each do |alias_string|
  alias_setting, alias_value = alias_string.split(' ', 2)

  sprout_git_global_config "alias.#{alias_setting}" do
    setting_value alias_value
  end
end
