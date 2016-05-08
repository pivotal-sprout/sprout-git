require 'unit/spec_helper'

describe 'sprout-git::projects' do
  let(:chef_run) { ChefSpec::SoloRunner.new }
  let(:repo_base_url) { 'http://example.com/some/repo' }
  before do
    chef_run.node.set['workspace_directory'] = 'some_workspace'
  end

  it 'includes sprout-base::workspace_directory' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('sprout-base::workspace_directory')
  end

  it 'can clone projects with only the url specified' do
    chef_run.node.set['sprout']['git']['projects'] = [
      { 'url' => "#{repo_base_url}1.git" },
      { 'url' => "#{repo_base_url}2" }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo1.git repo1').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo2 repo2').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
  end

  it 'can clone projects with a custom name if specified' do
    chef_run.node.set['sprout']['git']['projects'] = [
      {
        'url' => "#{repo_base_url}1.git",
        'name' => 'custom'
      }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo1.git custom').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
  end

  it 'can clone from github using github key instead of url' do
    chef_run.node.set['sprout']['git']['projects'] = [
      { 'github' => 'foo/bar' },
      { 'github' => 'baz/bat', 'name' => 'my_bat', 'branch' => 'other' }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master git@github.com:foo/bar.git bar').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
    expect(chef_run).to run_execute('git clone -b other git@github.com:baz/bat.git my_bat').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
  end

  it 'can clone using --recursive per project' do
    chef_run.node.set['sprout']['git']['projects'] = [
      { 'github' => 'foo/bar', 'recursive' => true },
      { 'github' => 'baz/bat', 'recursive' => true, 'name' => 'my_bat', 'branch' => 'other' }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master --recursive git@github.com:foo/bar.git bar').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
    expect(chef_run).to run_execute('git clone -b other --recursive git@github.com:baz/bat.git my_bat').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
  end

  it 'can clone using --recursive for all projectcs' do
    chef_run.node.set['sprout']['git']['projects_settings'] = { 'recursive' => true }
    chef_run.node.set['sprout']['git']['projects'] = [
      { 'github' => 'foo/bar' },
      { 'github' => 'quick/quack', 'recursive' => false },
      { 'github' => 'baz/bat', 'name' => 'my_bat', 'branch' => 'other' }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master --recursive git@github.com:foo/bar.git bar').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
    expect(chef_run).to run_execute('git clone -b master git@github.com:quick/quack.git quack').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
    expect(chef_run).to run_execute('git clone -b other --recursive git@github.com:baz/bat.git my_bat').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
  end

  it 'can clone custom branch of project if specified' do
    chef_run.node.set['sprout']['git']['projects'] = [
      {
        'url' => "#{repo_base_url}1.git",
        'branch' => 'develop'
      }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b develop http://example.com/some/repo1.git repo1').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )
  end

  it 'can clone projects into an absolute custom directory' do
    chef_run.node.set['sprout']['git']['projects'] = [
      {
        'url' => "#{repo_base_url}1.git",
        'workspace_path' => '/some/non-home-based/workspace'
      }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo1.git repo1').with(
      user: 'fauxhai',
      cwd: '/some/non-home-based/workspace'
    )
  end

  it 'can clone projects into a relative custom directory' do
    chef_run.node.set['sprout']['git']['projects'] = [
      {
        'url' => "#{repo_base_url}1.git",
        'workspace_path' => '~/personal_projects'
      }
    ]
    allow(File).to receive(:expand_path).with(any_args).and_call_original
    allow(File).to receive(:expand_path).with('~/personal_projects').and_return('/home/fauxhai/personal_projects')

    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo1.git repo1').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/personal_projects'
    )
  end

  it 'does not clone the repo if it already exists' do
    chef_run.node.set['sprout']['git']['projects'] = [
      { 'url' => "#{repo_base_url}1.git" },
      { 'url' => "#{repo_base_url}2" }
    ]
    ::File.stub(:exist?).with(anything).and_call_original
    ::File.stub(:exist?).with('/home/fauxhai/some_workspace/repo1').and_return true
    chef_run.converge(described_recipe)
    expect(chef_run).to_not run_execute('git clone -b master http://example.com/some/repo1.git repo1')
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo2 repo2')
  end

  it 'creates the workspace if it is missing' do
    chef_run.node.set['sprout']['git']['projects'] = [
      { 'url' => "#{repo_base_url}1.git" },
      {
        'url' => "#{repo_base_url}3.git",
        'workspace_path' => '/totally/custom/path'
      }
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_directory('/home/fauxhai/some_workspace').with(
      user: 'fauxhai',
      mode: '0755',
      recursive: true
    )
    expect(chef_run).to create_directory('/totally/custom/path').with(
      user: 'fauxhai',
      mode: '0755',
      recursive: true
    )
  end

  it 'execute post-clone commands' do
    chef_run.node.set['sprout']['git']['projects'] = [
      {
        'url' => "#{repo_base_url}1.git",
        'post_clone_commands' => [
          '/foo/bar baz',
          'something else'
        ]
      }
    ]
    chef_run.converge(described_recipe)

    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo1.git repo1').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )

    expect(chef_run).to run_execute('/foo/bar baz').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace/repo1',
      ignore_failure: true
    )

    expect(chef_run).to run_execute('something else').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace/repo1',
      ignore_failure: true
    )
  end

  it 'can update projects that were previously checked out' do
    chef_run.node.set['sprout']['git']['projects'] = [
      {
        'url' => "#{repo_base_url}1.git",
        'update' => true
      }
    ]

    ::File.stub(:exist?).with(anything).and_call_original
    ::File.stub(:exist?).with('/home/fauxhai/some_workspace/repo1').and_return true

    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git pull -r').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace/repo1'
    )
  end

  it 'supports legacy attribute syntax' do
    chef_run.node.set['sprout']['git']['projects'] = [
      ['renamed', 'http://example.com/some/repo1.git']
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('git clone -b master http://example.com/some/repo1.git renamed').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace'
    )

    expect(chef_run).to run_execute('git submodule update --init --recursive').with(
      user: 'fauxhai',
      cwd: '/home/fauxhai/some_workspace/renamed',
      ignore_failure: true
    )
  end
end
