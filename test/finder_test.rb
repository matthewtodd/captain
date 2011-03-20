require 'test_helper'

class FinderTest < Test::Unit::TestCase
  extend DeclarativeTests
  include IsolatedWorkingDirectory

  attr_reader :subject

  def setup
    super

    @subject = Captain::Finder.new('a', 'b')

    Dir.mkdir('a')
    FileUtils.touch('a/one')
    Dir.mkdir('b')
    FileUtils.touch('b/one')
    FileUtils.touch('b/two')
  end

  it 'finds files in the lookup path' do
    assert_equal 'b/two', subject.path('two')
  end

  it 'prefers files earlier in the lookup path' do
    assert_equal 'a/one', subject.path('one')
  end

  it 'raises when path does not exist' do
    assert_raise Errno::ENOENT do
      subject.path('DOES NOT EXIST')
    end
  end
end
