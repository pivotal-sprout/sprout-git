require 'unit/spec_helper'

describe 'sprout-git::git_secrets' do
  let(:chef_run) { ChefSpec::SoloRunner.new }
  let(:global_hooks_dir) { '/usr/local/share/githooks' }

  before { chef_run.converge(described_recipe) }

  it 'includes git-hooks' do
    expect(chef_run).to include_recipe('sprout-git::git_hooks')
  end

  it 'installs git-secrets' do
    expect(chef_run).to install_package('git-secrets')
  end

  it 'configures git-secrets' do
    expect(chef_run).to run_execute('git secrets --register-aws --global')
  end

  it 'installs git-secrets hooks for all users' do
    global_hooks_dir = '/usr/local/share/githooks'
    hooks = [
      { hook_dir: 'pre-commit', hook_flag: 'pre_commit_hook' },
      { hook_dir: 'commit-msg', hook_flag: 'commit_msg_hook' },
      { hook_dir: 'prepare-commit-msg', hook_flag: 'prepare_commit_msg_hook' }
    ]

    hooks.each do |hook_settings|
      expect(chef_run).to create_directory("#{global_hooks_dir}/#{hook_settings[:hook_dir]}")
      expect(chef_run).to create_template("#{global_hooks_dir}/#{hook_settings[:hook_dir]}/00-git-secrets")
        .with_source('00-git-secrets.erb')
        .with_variables(hook_name: hook_settings[:hook_flag])
    end
  end
end
