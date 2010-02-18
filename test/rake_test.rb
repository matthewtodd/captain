require 'test_helper'
require 'rake'

class RakeTest < Test::Unit::TestCase
  attr_reader :rake

  def setup
    @rake = Rake.application = Rake::Application.new.extend(RakeAssertions)
    @rake.test = self
  end


  subject do
    Captain::Rake
  end

  should 'define a file task' do
    subject.new do |task|
      task.label        = 'a'
      task.version      = 'b'
      task.tag          = 'c'
      task.architecture = 'd'
    end

    rake.should_have_task('a-b-c-d.iso').of_type(Rake::FileTask)
  end

  should 'define a captain task that depends on the file' do
    subject.new do |task|
      task.label        = 'a'
      task.version      = 'b'
      task.tag          = 'c'
      task.architecture = 'd'
    end

    rake.should_have_task('captain').depending_on('a-b-c-d.iso')
  end


  module RakeAssertions
    attr_accessor :test

    def should_have_task(name)
      task = lookup(name)

      test.assert(task)

      task.extend(TaskAssertions)
      task.test = test
      task
    end
  end

  module TaskAssertions
    attr_accessor :test

    def of_type(type)
      test.assert_kind_of type, self
      self
    end

    def depending_on(name)
      test.assert_equal [name], prerequisites
      self
    end

    def with_description(string)
      test.assert_equal string, comment
      self
    end
  end
end
