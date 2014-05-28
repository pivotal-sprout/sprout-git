require 'unit/spec_helper'

describe 'sprout-git::aliases' do
  let(:chef_run) { ChefSpec::Runner.new }
  let(:foo_missing) { true }
  let(:custom_aliases) { [] }

  before do
    stub_command('which git').and_return(true)
    stub_command('[ -z `git config --global alias.foo` ]').and_return(foo_missing)
    stub_command('[ -z `git config --global alias.bar` ]').and_return(true)
    chef_run.node.set['sprout']['git']['base_aliases'] = ['foo "bar baz"', 'bar "baz bat"']
  end

  it 'includes the install recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-git::install')
  end

  it 'installs git aliases' do
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git config --global alias.foo "bar baz"').with(user: 'fauxhai')
    expect(chef_run).to run_execute('git config --global alias.bar "baz bat"').with(user: 'fauxhai')
  end

  context 'when the alias exists' do
    let(:foo_missing) { false }

    it 'does not try to re-install it' do
      chef_run.converge(described_recipe)
      expect(chef_run).to_not run_execute('git config --global alias.foo "bar baz"')
    end

    it 'does install missing entries' do
      chef_run.converge(described_recipe)
      expect(chef_run).to run_execute('git config --global alias.bar "baz bat"').with(user: 'fauxhai')
    end
  end

  context 'with custom aliases defined as well' do
    before do
      chef_run.node.set['sprout']['git']['aliases'] = ['one custom', 'other custom']
      stub_command('[ -z `git config --global alias.one` ]').and_return(true)
      stub_command('[ -z `git config --global alias.other` ]').and_return(true)
    end

    it 'installs the custom aliases as well' do
      chef_run.converge(described_recipe)
      expect(chef_run).to run_execute('git config --global alias.foo "bar baz"').with(user: 'fauxhai')
      expect(chef_run).to run_execute('git config --global alias.bar "baz bat"').with(user: 'fauxhai')
      expect(chef_run).to run_execute('git config --global alias.one custom').with(user: 'fauxhai')
      expect(chef_run).to run_execute('git config --global alias.other custom').with(user: 'fauxhai')
    end
  end
end
