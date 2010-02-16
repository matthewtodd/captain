require 'test_helper'

class ConfigurationTest < Test::Unit::TestCase
  should 'default architecture to i386' do
    assert_equal 'i386', Captain::Configuration.new.architecture
  end
end
