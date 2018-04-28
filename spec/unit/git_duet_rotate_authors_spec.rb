# frozen_string_literal: true

require 'unit/spec_helper'

RSpec.describe 'sprout-git::git_duet_rotate_authors' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  it 'includes sprout-base::bash_it' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-base::bash_it')
  end

  it 'installs a bash-it custom plugin' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_bash_it_custom_plugin('bash_it/custom/git-duet_rotate_authors.bash')
  end
end
