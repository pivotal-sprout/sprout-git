property :setting_key, String, name_attribute: true
property :setting_value, String
property :setting_owner, String, default: node['sprout']['user']
property :scope, is: [:system, :global], default: :global

default_action :create

action :create do
  execute "git config --#{scope} #{setting_key} #{setting_value}" do
    user setting_owner
  end
end
