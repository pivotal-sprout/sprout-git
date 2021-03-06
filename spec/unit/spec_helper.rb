# frozen_string_literal: true

require 'spec_helper'
require 'chefspec'
require 'chefspec/librarian'

RSpec.configure do |config|
  config.platform = 'mac_os_x'
  config.version = '10.13' # via https://github.com/customink/fauxhai/tree/master/lib/fauxhai/platforms/mac_os_x/
  config.before do
    stub_const('ENV', 'SUDO_USER' => 'fauxhai')
    stub_command('which git').and_return(true)
  end
  config.after(:suite) { FileUtils.rm_r('.librarian') }
  config.file_cache_path = '/var/chef/cache'
end
