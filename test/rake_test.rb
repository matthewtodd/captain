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
    task = subject.new

    rake.should_have_task(task.config.iso_image_path).
                  of_type(Rake::FileTask)
  end

  should 'define a captain task that depends on the file' do
    task = subject.new

    rake.should_have_task('captain').
             depending_on(task.config.iso_image_path).
         with_description('Build the iso image')
  end

  should 'accept a custom name for the captain task' do
    task = subject.new('CUSTOM NAME')

    rake.should_not_have_task('captain')
    rake.should_have_task('CUSTOM NAME')
  end

  should 'accept a custom description for the captain task' do
    task = subject.new('captain', 'CUSTOM DESCRIPTION')

    rake.should_have_task('captain').
         with_description('CUSTOM DESCRIPTION')
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

    def should_not_have_task(name)
      test.assert_nil lookup(name)
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