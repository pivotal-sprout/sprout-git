# sprout-git cookbook

[![Build Status](https://travis-ci.org/pivotal-sprout/sprout-git.svg?branch=master)](https://travis-ci.org/pivotal-sprout/sprout-git)

Recipes to install git related tools on OS X.

## Usage

### Prerequisites

- [system ruby](.ruby-version)
- [bundler](http://bundler.io/)

### Quickstart

```
bundle
bundle exec soloist
```

## Cookbook Usage

### Attributes

*NOTE:* All preferences are namespaced under `sprout => git` they include:

* `prefix` &mdash; the email prefix to used by git-pair &mdash; default is `pair`
* `domain` &mdash; email address domain to be used by git-pair &mdash; default is `example.com`
* `authors` &mdash; a list of authors to install either into the ~/.pairs or ~/.git-authors files &mdash; default is _2 example sprout maintainers to use as a reference_
* `global_config` A set of configurations to be installed globally by the `global_config` recipe. &mdash; _see [config.rb](attributes/config.rb)_
* `base_aliases` A set of git aliases like `ci`,`br`, etc to install. Used by the `aliases` recipe &mdash; dfault is empty. _see the [soloistrc](soloistrc) or [aliases.rb](attributes/aliases.rb) files for examples._
* `aliases` &mdash; an additional set of custom aliases to be installed in addition to the `base_aliases`. Used by the `aliases` recipe &mdash; dfault is empty. _see the [soloistrc](soloistrc) or [aliases.rb](attributes/aliases.rb) files for examples._
* `projects` &mdash; The list of repositories to automatically clone into the `workspace_directory`. Used by the `projects` recipe &mdash; this is empty by default see the [soloistrc](soloistrc) or the [projects.rb](attributes/project.rb) files for examples
* `workspace_directory` &mdash; the location under the users home to clone the projects. Used by the `projects` recipe &mdash; default is `workspace`

### Recipes

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

