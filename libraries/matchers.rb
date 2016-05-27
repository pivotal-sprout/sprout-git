if defined?(ChefSpec)
  ChefSpec.define_matcher(:sprout_git_global_config)

  def create_sprout_git_global_resource(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:sprout_git_global_config, :create, resource)
  end
end
