require 'captain'
require 'tempfile'
require 'test/unit'

module DeclarativeTests
  def should(name, &block)
    define_method("test should #{name}", &block)
  end
end

module IsolatedWorkingDirectory
  def setup
    super
    @original_directory = Dir.pwd
    Dir.chdir(working_directory = Dir.mktmpdir)
    at_exit { FileUtils.remove_entry_secure(working_directory) }
  end

  def teardown
    Dir.chdir(@original_directory)
    super
  end
end

module RakeAssertions
  attr_accessor :test

  # rakefile won't have been set, since we're not actually invoking rake.
  def rakefile
    'Rakefile'
  end

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

  def depending_on(*tasks)
    test.assert_equal tasks.map { |t| t.to_s }, prerequisites
    self
  end

  def with_description(string)
    test.assert_equal string, comment
    self
  end
end
