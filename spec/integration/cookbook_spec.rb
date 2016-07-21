require 'spec_helper'
require 'yaml'

describe 'sprout-git recipes' do
  before :all do
    expect(File).not_to exist('/usr/local/bin/git-pair')
    expect(Dir).to_not exist(File.expand_path('~/workspace'))
    expect(Dir).to_not exist(File.expand_path('~/go'))

    create_workspace
    create_go_project

    expect(system('soloist')).to eq(true)
  end

  def create_workspace
    `mkdir -p ~/workspace`
    `cd ~/workspace/ &&
      git clone https://github.com/pivotal-sprout/sprout-git.git old-git-repo &&
      cd old-git-repo && git reset --hard master~52`
    `cd ~/workspace/ &&
      mkdir -p hooks-test-repo &&
      cd hooks-test-repo &&
      git init &&
      mkdir -p .git/hooks && touch .git/hooks/fake-hook`
    `touch ~/workspace/errant_file2`
  end

  def create_go_project
    `mkdir -p ~/go/src/github.com/testorg/testproject`
    `pushd ~/go/src/github.com/testorg/testproject &&
      git init &&
      mkdir -p .git/hooks &&
      touch .git/hooks/fake-hook &&
      popd`
    `touch ~/go/src/github.com/testorg/errant_file1`
    `touch ~/go/src/github.com/errant_file2`
  end

  it 'install: installs git via homebrew' do
    expect(File).to exist('/usr/local/bin/git')
  end

  it 'aliases: installs the base aliases' do
    expect(`git config --get-all alias.st`.strip).to eq('status')
    fmt = %{--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'}
    expect(`git config --get-all alias.lg`.strip).to eq(%(log --graph --abbrev-commit #{fmt}))
    expect(`git config --get-all alias.blog`.strip).to eq('log origin/master... --left-right')
  end

  it 'aliases: installs custom aliases' do
    expect(`git config --get-all alias.cfbb`.strip).to eq('commit --with-custom-flags bar baz')
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

  it 'default_editor: installs the git-duet_rotate_author script into bash-it' do
    template_filename = File.expand_path('./templates/default/git-duet_rotate_author.bash')
    expect(`diff ~/.bash_it/custom/git-duet_rotate_author.bash #{template_filename}`)
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

  it 'git_scripts: installs git-duet via homebrew' do
    expect(File).to exist('/usr/local/bin/git-duet')
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
    verify_cloned_project('~/personal_projects/custom-name')
  end

  it 'projects: runs a post-clone command to create a file' do
    verify_cloned_project('~/workspace/with-post-clone')
    expect(File).to exist(File.expand_path('~/workspace/with-post-clone/touched.txt'))
    world_file = File.expand_path('~/workspace/with-post-clone/world.txt')
    expect(File).to exist(world_file)
    f = File.open(world_file, 'rb')
    expect(f.read).to eq("hello\n")
  end

  it 'projects: updates projects that are already checked out' do
    verify_cloned_project('~/workspace/old-git-repo')
  end

  it 'git_hooks: installs git-hooks via homebrew' do
    expect(File).to exist('/usr/local/bin/git-hooks')
  end

  it 'git_hooks: configures a global git-hooks directory' do
    expect(`git config --get-all hooks.global | head -1`.strip).to eq('/usr/local/share/githooks')
  end

  it 'git_hooks: backup existing hooks' do
    expect(File).to exist(File.expand_path('~/workspace/hooks-test-repo/githooks/fake-hook/recovered-hook'))
    expect(File).to exist(File.expand_path('~/go/src/github.com/testorg/testproject/githooks/fake-hook/recovered-hook'))
  end

  it 'git_hooks: ensures git-hooks are used for git init and git clone' do
    `cd ~/workspace &&
      mkdir init-test-repo &&
      git clone https://github.com/pivotal-sprout/sprout-git.git clone-test-repo &&
      cd init-test-repo &&
      git init`

    files = [
      'applypatch-msg',
      'commit-msg',
      'post-update',
      'pre-applypatch',
      'pre-commit',
      'pre-push',
      'pre-rebase',
      'prepare-commit-msg',
      'update'
    ]

    files.each do |file|
      expect(File).to exist(File.expand_path("~/workspace/init-test-repo/.git/hooks/#{file}"))
      expect(File).to exist(File.expand_path("~/workspace/clone-test-repo/.git/hooks/#{file}"))
    end
  end

  it 'git_secrets: configures git-secrets' do
    Dir.chdir(File.dirname(__FILE__)) do
      pattern_test_file = './git-secrets-pattern-tests.txt'
      expected_match_count = File.open(pattern_test_file).grep(/should_match/).length
      match_count = `git secrets --scan #{pattern_test_file} | grep -c should_match`.chomp.to_i
      false_positive_count = `git secrets --scan #{pattern_test_file} | grep -c should_not_match`.chomp.to_i

      expect(match_count).to eq(expected_match_count)
      expect(false_positive_count).to eq(0)
    end
  end

  it 'git_secrets: installs git-secrets hooks for all users' do
    expect(File).to exist('/usr/local/share/githooks/pre-commit/00-git-secrets')
    expect(File).to exist('/usr/local/share/githooks/commit-msg/00-git-secrets')
    expect(File).to exist('/usr/local/share/githooks/prepare-commit-msg/00-git-secrets')
  end
end
