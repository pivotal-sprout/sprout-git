class Chef::Recipe::PostCommitHook
  def self.install_post_commit_hook(git_repo_dirs)
    git_repo_dirs.each do |git_repo_dir|
      Dir.chdir(git_repo_dir) do
        if ::File.directory?('.git')
          if !::File.directory?(::File.join('.git', 'hooks.old'))
            Chef::Log.info("Installing git-secrets hooks for #{git_repo_dir}")
            potential_hook_files = Dir.glob(::File.join('.git', 'hooks', '*'))
            hook_files = potential_hook_files.select do |potential_hook_file|
              !!potential_hook_file[/.sample$/]
            end
            unapplied_hook_files = hook_files.reject do |hook_file|
              ::File.open(hook_file).grep(/git-hook/)
            end
            unapplied_hook_files.each do |unapplied_hook_file|
              hook_dir = ::File.join('githooks', ::File.basename(unapplied_hook_file))
              Dir.mkdir_p hook_dir
              ::File.cp unapplied_hook_file, ::File.join(hook_dir, 'recovered_hook')
            end

            cmd = Mixlib::ShellOut.new('git hooks install', user: owner)
            cmd.run_command
            cmd.error!
          else
            Chef::Log.info("#{git_repo_dir} appears to already have git-hooks installed, skipping")
          end
        else
          Chef::Log.info("#{git_repo_dir} doesn't appear to be a git repository, skipping")
        end
      end
    end
  end
end
