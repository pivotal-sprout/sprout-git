class Chef
  class Recipe
    # methods to help install git-hooks, which allows more than one git-hook
    # only class methods, not instance methods, as no objects are being created
    class PostCommitHook
      def self.install_post_commit_hook(git_repo_dirs, owner)
        git_repo_dirs.each do |git_repo_dir|
          Dir.chdir(git_repo_dir) do
            check_and_install_git_hooks(owner)
          end
        end
      end

      def self.check_and_install_git_hooks(owner)
        if ::File.directory?('.git')
          if !::File.directory?(::File.join('.git', 'hooks.old'))
            install_git_hooks(owner)
          else
            Chef::Log.info("#{::Dir.pwd} appears to already have git-hooks installed, skipping")
          end
        else
          Chef::Log.info("#{::Dir.pwd} doesn't appear to be a git repository, skipping")
        end
      end

      def self.install_git_hooks(owner)
        Chef::Log.info("Installing git-hooks for #{::Dir.pwd}")
        unapplied_hook_files = get_unapplied_hook_files(::Dir.glob(::File.join('.git', 'hooks', '*')))
        unapplied_hook_files.each do |unapplied_hook_file|
          hook_dir = ::File.join('githooks', ::File.basename(unapplied_hook_file))
          FileUtils.mkdir_p hook_dir
          FileUtils.cp unapplied_hook_file, ::File.join(hook_dir, 'recovered-hook')
        end
        install_git_hooks_in_current_repo(owner)
      end

      def self.get_unapplied_hook_files(potential_hook_files)
        hook_files = potential_hook_files.reject do |potential_hook_file|
          potential_hook_file[/.sample$/]
        end
        hook_files.select do |hook_file|
          ::File.open(hook_file).grep(/git-hooks/).empty?
        end
      end

      def self.install_git_hooks_in_current_repo(owner)
        cmd = Mixlib::ShellOut.new('git hooks install', user: owner)
        cmd.run_command
        cmd.error!
      end
    end
  end
end
