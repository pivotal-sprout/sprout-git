require 'unit/spec_helper'
require 'ostruct'

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
      OpenStruct.new(name: 'pre-commit', git_secrets_hook: 'pre_commit_hook'),
      OpenStruct.new(name: 'commit-msg', git_secrets_hook: 'commit_msg_hook'),
      OpenStruct.new(name: 'prepare-commit-msg', git_secrets_hook: 'prepare_commit_msg_hook')
    ]

    hooks.each do |hook|
      expect(chef_run).to create_directory("#{global_hooks_dir}/#{hook.name}")
      expect(chef_run).to create_template("#{global_hooks_dir}/#{hook.name}/00-git-secrets")
        .with_source('00-git-secrets.erb')
        .with_variables(hook_name: hook.git_secrets_hook)
    end
  end
end
