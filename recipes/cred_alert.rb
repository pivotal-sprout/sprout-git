remote_file '/usr/local/bin/cred-alert-cli' do
  source 'https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_darwin'
  user node['sprout']['user']
  group node['sprout']['group']
  mode '0755'
  action :create_if_missing
end
