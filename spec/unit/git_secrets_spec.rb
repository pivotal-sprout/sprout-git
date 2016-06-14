require 'unit/spec_helper'

describe 'sprout-git::git_secrets' do
  let(:chef_run) { ChefSpec::SoloRunner.new }
  let(:global_hooks_dir) { '/usr/local/share/githooks' }

  before { chef_run.converge(described_recipe) }

  it 'includes git-hooks' do
    expect(chef_run).to include_recipe('sprout-git::git_hooks')
  end

  it 'installs git-secrets' do
    expect(chef_run).to install_package('git-secrets')
  end

  it 'resets git-secrets configuration' do
    expect(chef_run).to run_execute("git config --global -l | grep 'secrets\.' >~/.git-secrets-patterns.bak")
    expect(chef_run).to run_execute('git config --global --remove-section secrets')
  end

  it 'configures git-secrets' do
    expect(chef_run).to run_execute('git secrets --add --global "AKIA[A-Z0-9]{16}"')
    expect(chef_run).to run_execute([
      'git secrets --add --global ',
      %q("(\"|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)),
      %q((\"|')?\\s*(:|=>|=)\\s*(\"|')?[A-Za-z0-9/\\+=]{40}(\"|')?")
    ].join(''))

    expect(chef_run).to run_execute([
      'git secrets --add --global ',
      %q("(\"|')?(AWS|aws|Aws)?_?(ACCOUNT|account|Account)_?(ID|id|Id)?),
      %q((\"|')?\\s*(:|=>|=)\\s*(\"|')?[0-9]{4}\\-?[0-9]{4}\\-?[0-9]{4}(\"|')?")
    ].join(''))

    expect(chef_run).to run_execute([
      'git secrets --add --global ',
      %q("(\"|')*[A-Za-z0-9_-]*),
      '([sS]ecret|[pP]rivate[-_]?[Kk]ey|[Pp]assword|[sS]alt|SECRET|PRIVATE[-_]?KEY|PASSWORD|SALT)',
      %q([\"']*\\s*(=|:|\\s|:=|=>)\\s*[\"'][A-Za-z0-9.$+=&\\/_\\\\\\-]{12,}(\"|')")
    ].join(''))

    expect(chef_run).to run_execute('git secrets --add --allowed --global "[\"]\\\\$"')
    expect(chef_run).to run_execute('git secrets --add --allowed --global "[fF][aA][kK][eE]"')
    expect(chef_run).to run_execute('git secrets --add --allowed --global "[eE][xX][aA][mM][pP][lL][eE]"')
  end

  it 'installs git-secrets hooks for all users' do
    global_hooks_dir = '/usr/local/share/githooks'
    hooks = [
      { hook_dir: 'pre-commit', hook_flag: 'pre_commit_hook' },
      { hook_dir: 'commit-msg', hook_flag: 'commit_msg_hook' },
      { hook_dir: 'prepare-commit-msg', hook_flag: 'prepare_commit_msg_hook' }
    ]

    hooks.each do |hook_settings|
      expect(chef_run).to create_directory("#{global_hooks_dir}/#{hook_settings[:hook_dir]}")
      expect(chef_run).to create_template("#{global_hooks_dir}/#{hook_settings[:hook_dir]}/00-git-secrets")
        .with_source('00-git-secrets.erb')
        .with_variables(hook_name: hook_settings[:hook_flag])
    end
  end
end
