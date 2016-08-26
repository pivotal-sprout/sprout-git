require 'unit/spec_helper'

RSpec.describe 'sprout-git::git_hooks_core' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:hooks_dir) { '/etc/git/hooks' }

  before do
    stub_command('which git').and_return(true)
    runner.node.set['sprout']['git']['hooks']['repository'] = 'https://git.example.com'

    runner.converge(described_recipe)
  end

  it 'includes sprout-git::install' do
    expect(runner).to include_recipe('sprout-git::install')
  end

  it 'creates the parent dir of the repo' do
    expect(runner).to create_directory(File.dirname(hooks_dir)).with(
      owner: runner.node['sprout']['user'],
      group: runner.node['sprout']['group'],
      mode: '0755'
    )
  end

  it 'clones hooks into the hooks dir' do
    expect(runner).to sync_git(hooks_dir).with(
      repository: 'https://git.example.com',
      revision: 'master',
      user: runner.node['sprout']['user'],
      group: runner.node['sprout']['group']
    )
  end

  it 'sets the git hooks directory to be the hooks dir' do
    expect(runner).to create_sprout_git_global_resource('core.hooksPath').with(
      setting_value: hooks_dir
    )
  end
end
