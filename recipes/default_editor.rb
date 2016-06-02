include_recipe 'sprout-base::bash_it'

sprout_base_bash_it_custom_plugin 'bash_it/custom/git-export_editor.bash' do
  variables editor: node['sprout']['git']['editor']
end
