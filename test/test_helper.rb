require 'captain'
require 'test/unit'
require 'shoulda/test_unit'

if $stdout.tty?
  require 'redgreen'
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
