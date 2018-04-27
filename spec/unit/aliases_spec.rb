# frozen_string_literal: true

require 'unit/spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'sprout-git::aliases' do
  let(:chef_run) { ChefSpec::SoloRunner.new }
  let(:foo_missing) { true }
  let(:custom_aliases) { [] }

  before do
    stub_command('which git').and_return(true)
    chef_run.node.override['sprout']['git']['base_aliases'] = ['foo "bar baz"', 'bar "baz bat"']
  end

  it 'includes the install recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-git::install')
  end

  it 'installs git aliases' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_sprout_git_global_resource('alias.bar').with(setting_value: '"baz bat"')
  end

  context 'with custom aliases defined as well' do
    before do
      chef_run.node.override['sprout']['git']['aliases'] = ['one custom', 'other custom']
    end

    it 'installs the custom aliases as well' do
      chef_run.converge(described_recipe)
      expect(chef_run).to create_sprout_git_global_resource('alias.foo').with(setting_value: '"bar baz"')
      expect(chef_run).to create_sprout_git_global_resource('alias.bar').with(setting_value: '"baz bat"')
      expect(chef_run).to create_sprout_git_global_resource('alias.one').with(setting_value: 'custom')
      expect(chef_run).to create_sprout_git_global_resource('alias.other').with(setting_value: 'custom')
    end
  end
end
# rubocop:enable Metrics/BlockLength
