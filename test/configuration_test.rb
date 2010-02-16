require 'test_helper'

class ConfigurationTest < Test::Unit::TestCase
  subject do
    Configuration.new
  end

  should 'have default architecture' do
    assert_equal 'i386', subject.architecture
  end

  should 'have default include packages' do
    assert_equal ['linux-server', 'language-support-en', 'grub'],
                 subject.include_packages
  end

  should 'have default install packages' do
    assert_equal [], subject.install_packages
  end

  should 'have default label' do
    assert_equal 'Ubuntu', subject.label
  end

  should 'have default output directory' do
    assert_equal '.', subject.output_directory
  end

  should 'have default post install commands' do
    assert_equal [], subject.post_install_commands
  end

  should 'have default repositories' do
    assert_equal ['http://us.archive.ubuntu.com/ubuntu jaunty main restricted'],
                 subject.repositories
  end

  should 'have default tasks' do
    assert_equal ['minimal', 'standard'], subject.tasks
  end

  should 'have default tag' do
    assert_equal 'captain', subject.tag
  end

  should 'have default version' do
    assert_equal '9.04', subject.version
  end

  should 'have default working directory' do
    assert_match /^#{Regexp.escape(ENV['TMPDIR'])}/, subject.working_directory
  end
end
