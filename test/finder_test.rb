require 'test_helper'
require 'tempfile'

class FinderTest < Test::Unit::TestCase
  extend DeclarativeTests

  attr_reader :subject

  def setup
    @original_directory = Dir.pwd
    @working_directory  = Dir.mktmpdir
    Dir.chdir(@working_directory)

    Dir.mkdir('a')
    Dir.mkdir('b')
    @subject = Captain::Finder.new('b', 'a')
  end

  def teardown
    Dir.chdir(@original_directory)
    FileUtils.remove_entry_secure(@working_directory)
  end

  should 'raise when path does not exist' do
    assert_raise Errno::ENOENT do
      subject.path('DOES NOT EXIST')
    end
  end

  should 'find files in the lookup path' do
    FileUtils.touch %w( a/path )
    assert_equal 'a/path', subject.path('path')
  end

  should 'prefer files earlier in the lookup path' do
    FileUtils.touch %w( a/path b/path )
    assert_equal 'b/path', subject.path('path')
  end
end
