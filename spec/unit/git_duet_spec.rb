require 'unit/spec_helper'

describe 'sprout-git::git_duet' do
  let(:chef_run) { ChefSpec::Runner.new }

  it 'includes the homebrew recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('homebrew')
  end

  it 'includes the git_duet_global recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-git::git_duet_global')
  end

  it 'includes the git_duet_rotate_authors recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-git::git_duet_rotate_authors')
  end

  it 'includes the authors recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-git::authors')
  end

  it 'taps git-duet/homebrew-tap' do
    chef_run.converge(described_recipe)
    expect(chef_run).to tap_homebrew_tap('git-duet/tap')
  end

  it 'brew installs git-duet' do
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('git-duet')
  end
end
