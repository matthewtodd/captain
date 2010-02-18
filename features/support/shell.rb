class ShellHelper
  attr_reader :cwd

  def initialize(cwd)
    @cwd = cwd
  end

  def create_file(path, contents)
    full = cwd.join(path)
    full.parent.mkpath
    full.open('w') do |stream|
      stream.write(contents)
    end
  end

  def run(command, environment={})
    Dir.chdir(cwd) do
      overriding_environment(environment) do
        system(command)
      end
    end
  end

  private

  def overriding_environment(overrides)
    original = {}

    overrides.each do |key, value|
      key = key.to_s.upcase
      original[key] = ENV.delete(key)
      ENV[key]      = value
    end

    yield
  ensure
    original.each do |key, value|
      ENV[key] = value
    end
  end
end

module ShellWorld
  attr_accessor :shell
end

World(ShellWorld)

Before do
  self.shell = ShellHelper.new(directory.temp)
end
