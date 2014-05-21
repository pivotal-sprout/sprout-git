require 'spec_helper'
require 'yaml'

describe 'sprout-git recipes' do
  before :all do
    expect(`which git-pair`).to be_empty
    expect(system('soloist')).to be_true
  end

  it 'install: installs git via homebrew' do
    expect(File).to exist('/usr/local/bin/git')
  end

  it 'aliases: installs the base aliases' do
    expect(`git config --get-all alias.st`.strip).to eq('status')
    fmt = %q{--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'}
    expect(`git config --get-all alias.lg`.strip).to eq(%Q(log --graph #{fmt} --abbrev-commit --date=relative))
    expect(`git config --get-all alias.blog`.strip).to eq('log origin/master... --left-right')
  end

  it 'aliases: installs custom aliases' do
    expect(`git config --get-all alias.cfbb`.strip).to eq('commit --foo bar baz')
  end

  it 'aliases: overrides base aliases with custom aliases if there is a collision' do
    expect(`git config --get-all alias.ci`.strip).to eq('pair-commit')
  end

  it 'global_config: installs global configurations' do
    excludesfile = File.expand_path('~/.gitignore_global')
    expect(`git config --get-all core.excludesfile`.strip).to eq(excludesfile)
    expect(`git config --get-all color.branch`.strip).to eq('auto')
  end

  it 'git_ignore: adds a global git ignroe' do
    filename = File.expand_path('~/.gitignore_global')
    expect(File).to exist(filename)
  end

  it 'git_scripts: install pivotal git pair' do
    expect(`which git-pair`).not_to be_empty
  end

  it 'git_scripts: installs a ~/.pairs file properly' do
    filename = File.expand_path '~/.pairs'
    expect(File).to exist(filename)
    expect(YAML.load_file(filename)).to eq(
      'pairs' => {
        'jrhb' => 'Jonathan Barnes',
        'bc' => 'Brian Cunnie; cunnie',
        'ah' => 'Abhi Hiremagalur'
      },
      'email' => {
        'prefix' => 'pair',
        'domain' => 'pivotallabs.com'
      },
      'global' => true
    )
  end

  it 'authors: installs a ~/.git-authors file properly' do
    filename = File.expand_path '~/.git-authors'
    expect(File).to exist(filename)
    expect(YAML.load_file(filename)).to eq(
      'authors' => {
        'jrhb' => 'Jonathan Barnes',
        'bc' => 'Brian Cunnie; cunnie',
        'ah' => 'Abhi Hiremagalur'
      },
      'email' => {
        'domain' => 'pivotallabs.com'
      },
      'email_addresses' => {
        'ah' => 'abhijit@hiremaga.com'
      }
    )
  end
end
