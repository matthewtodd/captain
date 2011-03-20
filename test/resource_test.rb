require 'test_helper'

class ResourceTest < Test::Unit::TestCase
  extend DeclarativeTests
  include IsolatedWorkingDirectory
  include Captain

  def setup
    super

    Resource.finder = Finder.new('a')

    Dir.mkdir('a')
    File.open('a/one', 'w') { |stream| stream.write('CONTENTS') }
  end

  it 'reads it contents from the path given by its finder' do
    assert_equal 'CONTENTS', Resource.file('one').contents
  end
end
