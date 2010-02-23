Feature: Rake ISO Task
  In order to install a custom Ubuntu system
  As a perennial yak-shaver
  I want to assemble my own installer CD

  Scenario: Running from rake
    Given the following Gemfile:
      """
      source :rubygems
      gem 'captain'
      gem 'rake'
      """

    And the following Rakefile:
      """
      require 'captain'

      Captain::Rake::IsoTask.new do |task|
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
