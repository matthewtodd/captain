require 'test_helper'
require 'rake'

class RakeTest < Test::Unit::TestCase
  subject do
    Captain::Rake
  end

  context 'with a fake Rake' do
    setup do
      Rake.application = flexmock('Rake::Application')
    end

    should 'define a file task' do
      Rake.application.
        should_receive(:define_task).
                  with(Rake::FileTask, 'a-b-c-d.iso', Proc).
                  once

      subject.new do |task|
        task.label        = 'a'
        task.version      = 'b'
        task.tag          = 'c'
        task.architecture = 'd'
      end
    end
  end
end
