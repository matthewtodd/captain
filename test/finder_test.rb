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
      subject.contents('DOES NOT EXIST')
    end
  end

  should 'read contents of a file in the lookup path' do
    File.open('a/path', 'w') { |stream| stream.write('CONTENTS') }
    assert_equal 'CONTENTS', subject.contents('path')
  end

  should 'prefer files earlier in the lookup path' do
    File.open('a/path', 'w') { |stream| stream.write('CONTENTS OF A') }
    File.open('b/path', 'w') { |stream| stream.write('CONTENTS OF B') }

    assert_equal 'CONTENTS OF B', subject.contents('path')
  end
end
