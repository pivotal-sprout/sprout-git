require 'unit/spec_helper'

describe 'sprout-git::default' do
  let(:runner) { ChefSpec::Runner.new }
  before do
    stub_command('which git').and_return(true)
    stub_command(/\[ -z `git config --global alias\.\w+` \]/).and_return(false)
    runner.converge(described_recipe)
  end

  it 'includes the install recipe' do
    expect(runner).to include_recipe('sprout-git::install')
  end

  it 'includes the default_editor recipe' do
    expect(runner).to include_recipe('sprout-git::default_editor')
  end

  it 'includes the global_ignore recipe' do
    expect(runner).to include_recipe('sprout-git::global_ignore')
  end

  it 'includes the aliases recipe' do
    expect(runner).to include_recipe('sprout-git::aliases')
  end

  it 'includes the global_config recipe' do
    expect(runner).to include_recipe('sprout-git::global_config')
  end
end
