class BundlerHelper
  def initialize
    @local_paths = {}
  end

  def add_path_for(name, path)
    @local_paths[name] = path
    self
  end

  def munge_gemfile(contents)
    @local_paths.each do |name, path|
      contents = contents.sub(/gem '#{name}'$/, "gem '#{name}', :path => '#{path}'")
    end

    contents
  end

  def exec(command)
    "env -i HOME=#{ENV['HOME']} PATH=#{ENV['PATH']} bundle exec #{command}"
  end
end
