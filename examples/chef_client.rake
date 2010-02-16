# This file is lifted from my first use case for Captain, bringing up a server
# with the chef gems installed, so that I can then run something like
#
#  SERVER=https://my-chef-server chef-client --config /cdrom/bundle/client.rb --token ${MY_CHEF_VALIDATION_TOKEN}
#
# to get the party started. (Although, now that I think about it, maybe that
# would be more appropriately as a post-install command.) I'm eagerly awaiting
# the Ubuntu packages for chef!
require 'captain'

Captain::Rake.new do |task|
  # This tag will be appended to the iso filename, to help me remember.
  task.tag = 'chef-0.7.4'

  # These packages (and their dependencies) will be included in the ISO image.
  # The chef::client recipe configures chef-client to run under runit.
  task.include_packages = ['runit']

  # These packages will be included in the ISO image *and* installed at the end
  # of the installation process.
  #
  # These are roughly the packages mentioned at
  # http://wiki.opscode.com/pages/viewpage.action?pageId=2457665 for
  # bootstrapping a chef client. I've removed the 1.8 version suffixes so we'll
  # depend on the default provided packages. I've also excluded wget (since we
  # install rubygems as a package, below) and ssl-cert (since we won't need to
  # generate any certificates).
  #
  # Opscode suggest building rubygems from source, but I'm going to risk
  # installing it as a debian package here for convenience.
  task.install_packages = ['ruby', 'ruby-dev', 'libopenssl-ruby', 'rdoc', 'ri', 'irb', 'build-essential', 'rubygems']

  # Here we take advantage of the fact that captain automatically includes the
  # bundle directory in the ISO image.
  task.post_install_commands = [
    'in-target gem install /cdrom/bundle/gems/chef-0.7.4.gem --local'
  ]
end
