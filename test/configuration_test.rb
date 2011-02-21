require 'test_helper'

class ConfigurationTest < Test::Unit::TestCase
  extend DeclarativeTests

  attr_reader :subject

  def setup
    @subject = Captain::Configuration.new
  end

  should 'have default architecture' do
    assert_equal 'i386', subject.architecture
  end

  should 'have default bundle_directory' do
    assert_equal 'bundle', subject.bundle_directory
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

  should 'accept new architecture' do
    subject.architecture = 'amd64'
    assert_equal 'amd64', subject.architecture
  end

  should 'accept new bundle_directory' do
    subject.bundle_directory = 'vendor'
    assert_equal 'vendor', subject.bundle_directory
  end

  should 'accept new include packages' do
    subject.include_packages += ['some-additional-package']
    assert subject.include_packages.include?('some-additional-package')
  end

  should 'ensure linux-server is in include packages' do
    subject.include_packages = ['some-package']
    assert subject.include_packages.include?('linux-server')
  end

  should 'ensure language-support-en is in include packages' do
    subject.include_packages = ['some-package']
    assert subject.include_packages.include?('language-support-en')
  end

  should 'ensure grub is in include packages' do
    subject.include_packages = ['some-package']
    assert subject.include_packages.include?('grub')
  end

  should 'prohibit clearing include packages' do
    subject.include_packages = ['some-package']
    subject.include_packages.clear
    assert subject.include_packages.include?('some-package')
  end

  should 'accept new install packages' do
    subject.install_packages = ['some-package']
    assert subject.install_packages.include?('some-package')
  end

  should 'accept new label' do
    subject.label = 'New Label'
    assert_equal 'New Label', subject.label
  end

  should 'accept new output directory' do
    subject.output_directory = 'path/to/output'
    assert_equal 'path/to/output', subject.output_directory
  end

  should 'accept new post install commands' do
    subject.post_install_commands = ['do this']
    assert subject.post_install_commands.include?('do this')
  end

  should 'accept new repositories' do
    subject.repositories = ['http://example.com zippy main']
    assert_equal ['http://example.com zippy main'], subject.repositories
  end

  should 'accept new tasks' do
    subject.tasks += ['some-task']
    assert subject.tasks.include?('some-task')
  end

  should 'ensure minimal is in tasks' do
    subject.tasks = ['some-task']
    assert subject.tasks.include?('minimal')
  end

  should 'ensure standard is in tasks' do
    subject.tasks = ['some-task']
    assert subject.tasks.include?('standard')
  end

  should 'prohibit clearing tasks' do
    subject.tasks = ['some-task']
    subject.tasks.clear
    assert subject.tasks.include?('some-task')
  end

  should 'accept new tag' do
    subject.tag = 'chef-0.7.16'
    assert_equal 'chef-0.7.16', subject.tag
  end

  should 'accept new version' do
    subject.version = '1.10'
    assert_equal '1.10', subject.version
  end

  should 'accept new working directory' do
    subject.working_directory = 'path/to/working'
    assert_equal 'path/to/working', subject.working_directory
  end

  should 'generate installer repository mirror and codename' do
    subject.repositories = ['http://example.com zippy main restricted']
    assert_equal ['http://example.com', 'zippy'],
                 subject.installer_repository_mirror_and_codename
  end

  should 'generate iso image path, in canonical form' do
    subject.output_directory = 'subdirectory/../output'

    subject.label        = 'LABEL'
    subject.version      = 'VERSION'
    subject.tag          = 'TAG'
    subject.architecture = 'ARCHITECTURE'

    assert_equal 'output/label-version-tag-architecture.iso',
                 subject.iso_image_path
  end
end
