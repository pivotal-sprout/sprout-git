node.default['sprout']['git']['git_hooks'] = {
  'global_dir' => '/usr/local/share/githooks',
  'hooks' => [
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
}
