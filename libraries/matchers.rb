if defined?(ChefSpec)
  ChefSpec.define_matcher(:sprout_git_global_config)

  def create_sprout_git_global_resource(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:sprout_git_global_config, :create, resource)
  end

  def create_githooks_template_dir(template_dir)
    ChefSpec::Matchers::ResourceMatcher.new(:sprout_git_githooks_template_dir, :create, template_dir)
  end
end
