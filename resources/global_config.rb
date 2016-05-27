property :setting_key, String, name_attribute: true
property :setting_value, String
property :setting_owner, String, default: node['sprout']['user']

default_action :create

action :create do
  execute "set git config setting #{setting_key}" do
    command "git config --global #{setting_key} #{setting_value}"
    user setting_owner
  end
end
