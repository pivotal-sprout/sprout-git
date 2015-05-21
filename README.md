# sprout-git cookbook

[![Build Status](https://travis-ci.org/pivotal-sprout/sprout-git.svg?branch=master)](https://travis-ci.org/pivotal-sprout/sprout-git)

Recipes to install git related tools on OS X.

### Prerequisites

- [system ruby](.ruby-version)
- [bundler](http://bundler.io/)

### Quickstart

```
bundle
bundle exec soloist
```

## Cookbook Usage

### Recent changes:

* #### Adds git_duet_global recipe:
  this will add a custom bash_it plugin that causes git-duet to set global git properties. see the [git-duet repo](https://github.com/meatballhat/git-duet)

* #### the projects attributes have changed from an array of tuples:
  ```
  node_attributes:
    sprout:
      git:
        projects:
          - # e.g. ~/workspace/foo
            - foo
            - https://github.com/pivotal-sprout/sprout-git.git
  ```
  to an array of hashes:

  ```
  node_attributes:
    sprout:
      git:
        projects:
          - # e.g. ~/workspace/foo
            url: https://github.com/pivotal-sprout/sprout-git.git
            name: foo
  ```
  the tuple syntax is deprecated but will continue to work for the near term until enough people have transitioned.  See the Attributes section for more details an the new syntax.

* #### the projects attributes now include a way to run arbitrary commands on the freshly cloned repo:
The commands will be run in sequence.  If one of the commands fails (retunrs non-zero) subsequen commands continue to run and the Sprout run is not affected.  Future runs of sprout would not re-run these commands unless the repo was previously deleted. i.e. they only get run on a fresh clone of the project.

  ```
  node_attributes:
    sprout:
      git:
        projects:
          - # an example that initializes submodules, installs all gems, sets up the databases, runs rspec, and executes other arbitrary commands even with some failing
            url: https://github.com/pivotal-sprout/sprout-git.git
            post_clone_commands:
              - git submodule update --init
              - gem install bundler
              - bundle
              - rake db:create db:migrate
              - RAILS_ENV=test rake db:create db:migrate
              - rake spec
              - false
              - echo "I'm still run even though the last command failed"
  ```

* #### Projects no longer explicity set master's upstream branch to origin/master
This is done when the repo is cloned so sprout does not need to explicitly do this.

* #### Projects using the new hash syntax no longer automatically do a `git submodule update --init`
If the project needs to have submodules initialized then those entries should include the command as a post-clone command.  If the soloistrc is still using the legacy tuple syntax which cannot specify post_clone_commands then we continue to run the submodule update --init on all projects regardless of whether they have submodules.

### Attributes:

*NOTE:* All preferences are namespaced under `sprout => git` they include:

* `prefix` &mdash; the email prefix to used by git-pair &mdash; default is `'pair'`
* `domain` &mdash; email address domain to be used by git-pair &mdash; default is `'example.com'`
* `authors` &mdash; a list of authors to install either into the ~/.pairs or ~/.git-authors files &mdash; default is empty. _see the [soloistrc](soloistrc) file for examples._
* `global_config` A set of configurations to be installed globally by the `global_config` recipe. &mdash; _see [config.rb](attributes/config.rb)_
* `base_aliases` A set of git aliases like `ci`,`br`, etc to install. Used by the `aliases` recipe &mdash; dfault is empty. _see the [soloistrc](soloistrc) or [aliases.rb](attributes/aliases.rb) files for examples._
* `aliases` &mdash; an additional set of custom aliases to be installed in addition to the `base_aliases`. Used by the `aliases` recipe &mdash; default is empty. _see the [soloistrc](soloistrc) or [aliases.rb](attributes/aliases.rb) files for examples._
* `projects` &mdash; The list of repositories to automatically clone. Used by the `projects` recipe &mdash; this is empty by default see the [soloistrc](soloistrc) or the [attributes/projects.rb](attributes/project.rb) files for examples. it contains an array of project hashes with the following keys:
  * `url` &mdash; ***required*** &mdash; The repo url to clone clone. &mdash; e.g. `https://example.com/some/repo.git`
  * `name` &mdash; *optional* &mdash; The name of the local folder containing the repo. &mdash; e.g. `my_repo`  
  * `workspace_path` &mdash; *optional* &mdash; The path to clone into. &mdash; e.g. `~/personal_projects` or `/abs/path/to/personal_projects`
  * `post_clone_commands` &mdash; *optional* &mdash; A list of commands to run on the freshly cloned repository. Note this is only run on a fresh clone.  Future runs of sprout will not cause these commands to be re-run. &mdash; Some example commands could include: 
    * `gem install bundler`
    * `bundle`
    * `rake db:create:all db:test:prepare default`
    * `pod install`
    * `git submodule update --init`
* `workspace_directory` &mdash; the location under the users home to clone the projects unless otherwise specified by the project config. Used by the `projects` recipe &mdash; default is `'workspace'`

### Recipes:

* `sprout-git` &mdash; default recipe
* `sprout-git::aliases` &mdash; installs common git aliases such as `git st`
* `sprout-git::authors` &mdash; install ~/.git-authors file used by [git-duet](https://github.com/modcloth/git-duet) ; _**note:** this is not in the default recipe_
* `sprout-git::default_editor` &mdash; installs [bash-it](https://github.com/revans/bash-it) plugin to set default git editor
* `sprout-git::git_scripts` &mdash; installs pivotal [git_scripts] onto to the system using system ruby.  Also installs/overwrites the ~/.pairs file. ; _**note:** this is not in the default recipe_
* `sprout-git::global_config` &mdash; adds global git configurations defined by the `sprout => git => global_config` node attributes
* `sprout-git::global_ignore` &mdash; adds basic global git ignore file
* `sprout-git::install` &mdash; install git using [homebrew](http://brew.sh)
* `sprout-git::projects` &mdash; clones all projects defined byt the `sprout => git => projects` node attribute ; _**note:** this is not in the default recipe_

## Contributing

### Before committing

```
bundle
bundle exec rake
```

The default rake task includes rubocop, foodcritic, unit specs

### [Rubocop](https://github.com/bbatsov/rubocop)

```
bundle
bundle exec rake rubocop
```

### [FoodCritic](http://acrmp.github.io/foodcritic/)

```
bundle
bundle exec rake foodcritic
```

### Unit specs

Unit specs use [ServerSpec](http://serverspec.org/)

```
bundle
bundle exec rake spec:unit
```

### Integration specs

Integrations specs will run the default recipe on the host system (destructive) and make assertions on the system after
install.

*Note:* It has a precondition that git-pair is _not_ already installed on the system.

```
bundle
bundle exec rake spec:integration
```

foo
