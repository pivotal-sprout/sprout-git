require 'unit/spec_helper'

RSpec.describe 'sprout-git::git_hooks_core' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:hooks_dir) do
    File.join(runner.node['sprout']['home'], runner.node['workspace_directory'], 'git-hooks-core')
  end

  before do
    stub_command('which git').and_return(true)
    allow_any_instance_of(Chef::Log).to receive(:warn)
  end

  context 'with default attributes' do
    before do
      runner.converge(described_recipe)
    end

    it 'logs a warning' do
      expect(runner).to write_log(
        'Error: sprout.git.hooks.repository must be set for this recipe to run.'
      ).with_level(:warn)
    end

    it 'includes sprout-git::install' do
      expect(runner).to include_recipe('sprout-git::install')
    end

    it 'does not create a hooks diretory' do
      expect(runner).not_to create_directory(File.dirname(hooks_dir))
    end

    it 'does not clone hooks into the hooks dir' do
      expect(runner).not_to sync_git(hooks_dir)
    end

    it 'does not set the git hooks directory to be the hooks dir' do
      expect(runner).not_to create_sprout_git_global_resource('core.hooksPath')
    end
  end

  context 'when hooks > repository is set' do
    before do
      runner.node.set['sprout']['git']['hooks']['repository'] = 'https://git.example.com'
    end

    context 'with no revision' do
      before do
        runner.converge(described_recipe)
      end

      it 'does not log a warning' do
        expect(runner).not_to write_log('Error: sprout.git.hooks.repository must be set for this recipe to run.')
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

      it 'sets the git hooks directory to be the hooks dir' do
        expect(runner).to create_sprout_git_global_resource('core.hooksPath').with(
          setting_value: hooks_dir
        )
      end

      it 'clones master' do
        expect(runner).to sync_git(hooks_dir).with(
          repository: 'https://git.example.com',
          revision: 'master',
          user: runner.node['sprout']['user'],
          group: runner.node['sprout']['group']
        )
      end
    end

    context 'with a revision' do
      before do
        runner.node.set['sprout']['git']['hooks']['repository'] = 'https://git.example.com'
        runner.node.set['sprout']['git']['hooks']['revision'] = 'example-branch'

        runner.converge(described_recipe)
      end

      it 'does not log a warning' do
        expect(runner).not_to write_log('Error: sprout.git.hooks.repository must be set for this recipe to run.')
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

      it 'sets the git hooks directory to be the hooks dir' do
        expect(runner).to create_sprout_git_global_resource('core.hooksPath').with(
          setting_value: hooks_dir
        )
      end

      it 'clones what it was told to' do
        expect(runner).to sync_git(hooks_dir).with(
          repository: 'https://git.example.com',
          revision: 'example-branch',
          user: runner.node['sprout']['user'],
          group: runner.node['sprout']['group']
        )
      end
    end
  end
end
