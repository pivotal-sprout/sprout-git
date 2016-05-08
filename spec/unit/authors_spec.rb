require 'unit/spec_helper'

describe 'sprout-git::authors' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  it 'installs a template in ~/.git-authors' do
    chef_run.node.set['sprout']['git']['authors'] = [
      { initials: 'eg', name: 'El Gringo', email: 'gringo@custom.example.com' },
      { initials: 'hh', name: 'Hagar the Horrible' },
      { initials: 'lg', name: 'Lady Godiva', username: 'lgodiva' }
    ]
    chef_run.node.set['sprout']['git']['domain'] = 'default.example.com'
    chef_run.node.set['sprout']['git']['prefix'] = 'unused'

    chef_run.converge(described_recipe)
    expected = <<-EOF
authors:
  eg: El Gringo
  hh: Hagar the Horrible
  lg: Lady Godiva; lgodiva
email:
  domain: default.example.com
email_addresses:
  eg: gringo@custom.example.com
EOF
    expect(chef_run).to render_file('/home/fauxhai/.git-authors').with_content(/#{expected}/)
  end
end
