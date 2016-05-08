require 'unit/spec_helper'

describe 'sprout-git::git_scripts' do
  let(:chef_run) { ChefSpec::SoloRunner.new }
  let(:which_pair) { nil }
  let(:untar_command) do
    'tar --strip=2 -xzf /var/chef/cache/git_scripts.tgz -C /usr/local/bin'
  end
  before { stub_command('which git-pair').and_return(which_pair) }

  it 'includes sprout-base::user_owns_usr_local' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-base::user_owns_usr_local')
  end

  it 'downloads git_scripts as a tarball' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_remote_file('/var/chef/cache/git_scripts.tgz').with(
      source: 'https://github.com/pivotal/git_scripts/tarball/master'
    )
  end

  it 'installs git_scripts' do
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute(untar_command).with(user: 'fauxhai')
  end

  context 'when the git scripts have previously been installed' do
    let(:which_pair) { '/path/to/git-pair' }

    it 'does not install the git scripts' do
      chef_run.converge(described_recipe)
      expect(chef_run).to_not run_execute(untar_command)
    end
  end

  it 'installs a template in ~/.pairs' do
    chef_run.node.set['sprout']['git']['authors'] = [
      { initials: 'eg', name: 'El Gringo', email: 'gringo@custom.example.com' },
      { initials: 'hh', name: 'Hagar the Horrible' },
      { initials: 'lg', name: 'Lady Godiva', username: 'lgodiva' }
    ]
    chef_run.node.set['sprout']['git']['domain'] = 'default.example.com'
    chef_run.node.set['sprout']['git']['prefix'] = 'lord'
    chef_run.converge(described_recipe)
    expected = <<-EOF
pairs:
  eg: El Gringo
  hh: Hagar the Horrible
  lg: Lady Godiva; lgodiva

email:
  prefix: lord
  domain: default.example.com

email_addresses:
  eg: gringo@custom.example.com

global: true
EOF
    expect(chef_run).to render_file('/home/fauxhai/.pairs').with_content(/#{expected}/)
  end

  it 'overwrites the pairs file if it already exists' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/home/fauxhai/.pairs')
    expect(chef_run).to_not create_template_if_missing('/home/fauxhai/.pairs')
  end
end
