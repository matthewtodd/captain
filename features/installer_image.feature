Feature: Installer Image
  In order to install a custom Ubuntu system
  As a perennial yak-shaver
  I want to assemble my own installer CD

  Background:
    Given the following Gemfile:
      """
      source :gemcutter
      gem 'captain'
      gem 'rake'
      """

  Scenario: Running from the command line (deprecated!)
     When I run "captain" inside the bundle
     Then I should be able to launch the resulting image "ubuntu-9.04-captain-i386.iso"

  Scenario: Running from rake
    Given the following Rakefile:
      """
      require 'captain'

      Captain::Rake.new do |task|
        task.label        = 'Ubuntu'
        task.version      = '9.04'
        task.tag          = 'captain'
        task.architecture = 'i386'

        task.repositories = [
          'http://us.archive.ubuntu.com/ubuntu jaunty main restricted'
        ]
      end
      """
    When I run "rake captain" inside the bundle
    Then I should be able to launch the resulting image "ubuntu-9.04-captain-i386.iso"
