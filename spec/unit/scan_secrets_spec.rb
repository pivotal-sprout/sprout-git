require 'unit/spec_helper'

describe 'sprout-git::scan_secrets' do
  let(:chef_run) { ChefSpec::SoloRunner.new }
  let(:git_hooks_file_tgz) { '/usr/local/bin/git-hooks.tgz' }
  let(:git_hooks_file) { '/usr/local/bin/git-hooks' }
  let(:git_hooks_uri) do
    'https://github.com/git-hooks/git-hooks/releases/download/v1.1.3/git-hooks_darwin_amd64.tar.gz'
  end
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(git_hooks_file_tgz).and_return(false)
    allow(File).to receive(:exist?).with(git_hooks_file).and_return(false)
  end

  it 'downloads git_hooks_file_tgz as a tarball' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_remote_file(git_hooks_file_tgz).with(
      source: git_hooks_uri
    )
  end

  it 'untars the the git_hooks file' do
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute("tar -xf #{git_hooks_file_tgz} -O > #{git_hooks_file}")
  end
end
