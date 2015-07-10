require 'spec_helper'
require 'yaml'

describe 'sprout-git recipes' do
  before :all do
    expect(`which git-pair`).to be_empty
    expect(system('soloist')).to be_true
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

  it 'git_ignore: adds a global git ignore' do
    filename = File.expand_path('~/.gitignore_global')
    expect(File).to exist(filename)
  end

  it 'default_editor: installs the git-export_editor script into bash-it' do
    template_filename = File.expand_path('./templates/default/git-export_editor.bash')
    expect(`diff ~/.bash_it/custom/git-export_editor.bash #{template_filename}`)
  end

  it 'default_editor: installs the git-duet_global script into bash-it' do
    template_filename = File.expand_path('./templates/default/git-duet_global.bash')
    expect(`diff ~/.bash_it/custom/git-duet_global.bash #{template_filename}`)
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
        'domain' => 'pivotal.io'
      },
      'email_addresses' => {
        'ah' => 'abhijit@hiremaga.com'
      }
    )
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
        'domain' => 'pivotal.io'
      },
      'email_addresses' => {
        'ah' => 'abhijit@hiremaga.com'
      },
      'global' => true
    )
  end

  def verify_cloned_project(path)
    abs_path = File.expand_path(path)
    expect(File).to be_directory(abs_path)
    expect(File).to be_directory("#{abs_path}/.git")
    expect(`cd #{abs_path} && git br -avv|grep '^.\smaster'|awk '{print $4}'`.strip).to eq('[origin/master]')
  end

  it 'projects: clones the projects into the workspace using only url' do
    verify_cloned_project('~/workspace/sprout-git')
  end

  it 'projects: clones the projects into the workspace using url, name' do
    verify_cloned_project('~/workspace/git-repo')
  end

  it 'projects: clones the projects into the workspace using url, workspace_path' do
    verify_cloned_project('/alt/ern/ate/path/sprout-git')
  end

  it 'projects: clones the projects into the workspace using url, name, workspace_path' do
    verify_cloned_project('~/personal_projects/foo')
  end

  it 'projects: runs a post-clone command to create a file' do
    verify_cloned_project('~/workspace/with-post-clone')
    expect(File).to exist(File.expand_path('~/workspace/with-post-clone/touched.txt'))
    world_file = File.expand_path('~/workspace/with-post-clone/world.txt')
    expect(File).to exist(world_file)
    f = File.open(world_file, 'rb')
    expect(f.read).to eq("hello\n")
  end

  it 'projects: clones the projects into the workspace using legacy support' do
    verify_cloned_project('~/workspace/foo')
  end
end
