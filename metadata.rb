# frozen_string_literal: true

chef_version     '>= 12.6.0'
name             'sprout-git'
maintainer       'Pivotal'
maintainer_email 'sprout-maintainers@googlegroups.com'
source_url       'https://github.com/pivotal-sprout/sprout-git'
issues_url       'https://github.com/pivotal-sprout/sprout-git/issues'
license          'MIT'
description      'Installs/Configures sprout-git'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.0'
supports         'mac_os_x'
depends          'sprout-base'
depends          'homebrew'
