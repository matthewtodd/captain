class BundlerHelper
  attr_reader :local_path

  def initialize(local_path)
    @local_path = local_path
  end

  def munge_gemfile_for(name, contents)
    contents.gsub(/gem '#{name}'/, "gem '#{name}', :path => '#{local_path}'")
  end

  def exec(command)
    "env -i HOME=#{ENV['HOME']} PATH=#{ENV['PATH']} bundle exec #{command}"
  end
end

module BundlerWorld
  attr_accessor :bundler
end

World(BundlerWorld)

Before do
  self.bundler = BundlerHelper.new(Pathname.pwd.expand_path)
end
