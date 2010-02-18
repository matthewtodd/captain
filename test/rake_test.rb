require 'test_helper'
require 'rake'

class RakeTest < Test::Unit::TestCase
  subject do
    Captain::Rake
  end

  attr_accessor :rake

  context 'with a fake Rake' do
    setup do
      self.rake = Rake.application = flexmock('Rake')
    end

    should 'define a file task' do
      rake.should_receive(:define_task).with(Rake::Task, Hash)

      rake.should_receive(:define_task).
                     with(Rake::FileTask, 'a-b-c-d.iso', Proc).
                     once

      subject.new do |task|
        task.label        = 'a'
        task.version      = 'b'
        task.tag          = 'c'
        task.architecture = 'd'
      end
    end

    should 'define a captain task that depends on the file' do
      rake.should_receive(:define_task).with(Rake::FileTask, String, Proc)

      rake.should_receive(:define_task).
                     with(Rake::Task, :captain => 'a-b-c-d.iso').
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
