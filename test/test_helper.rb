require 'captain'
require 'test/unit'
require 'shoulda/test_unit'

if $stdout.tty? || ENV.has_key?('AUTOTEST')
  require 'redgreen'
end

class Test::Unit::TestCase
  include Captain
end
