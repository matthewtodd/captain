require 'test_helper'
require 'rake'

class ISOTest < Test::Unit::TestCase
  extend DeclarativeTests

  attr_reader :rake
  attr_reader :subject

  def setup
    @rake = Rake.application = Rake::Application.new.extend(RakeAssertions)
    @rake.test = self
    @subject = Captain::Rake::ISO
  end

  it 'defines a file task' do
    task = subject.new

    rake.should_have_task(task.config.iso_image_path).
                  of_type(Rake::FileTask).
             depending_on(rake.rakefile)
  end

  it 'has the file task depend on the files that will be bundled on the disk' do
    task = subject.new do |config|
      config.bundle_directory = 'lib'
    end

    rake.should_have_task(task.config.iso_image_path).
             depending_on(rake.rakefile, *Dir.glob('lib/**/*'))
  end

  it 'defines a captain task that depends on the file' do
    task = subject.new

    rake.should_have_task('captain').
             depending_on(task.config.iso_image_path).
         with_description('Build the iso image')
  end

  it 'accepts a custom name for the captain task' do
    task = subject.new('CUSTOM NAME')

    rake.should_not_have_task('captain')
    rake.should_have_task('CUSTOM NAME')
  end

  it 'accepts a custom description for the captain task' do
    task = subject.new('captain', 'CUSTOM DESCRIPTION')

    rake.should_have_task('captain').
         with_description('CUSTOM DESCRIPTION')
  end
end
