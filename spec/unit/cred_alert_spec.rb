require 'unit/spec_helper'

RSpec.describe 'sprout-git::cred_alert' do
  let(:runner) { ChefSpec::SoloRunner.new }

  before do
    stub_command('which git').and_return(true)

    runner.converge(described_recipe)
  end

  it 'downloads and installs cred-alert' do
    expect(runner).to create_remote_file_if_missing('/usr/local/bin/cred-alert-cli').with(
      source: 'https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_darwin',
      user: runner.node['sprout']['user'],
      group: runner.node['sprout']['group'],
      mode: '0755',
    )
  end
end
