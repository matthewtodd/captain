require 'pathname'
require 'tmpdir'

class ShellHelper
  attr_reader :cwd

  def initialize(basename)
    @cwd = Pathname.new(Dir.tmpdir).join(basename)

    if @cwd.exist?
      FileUtils.remove_entry_secure(@cwd)
    end

    @cwd.mkpath
  end

  def create_file(path, contents)
    chdir do
      path = Pathname.new(path)
      path.parent.mkpath
      path.open('w') do |stream|
        stream.write(contents)
      end
    end
  end

  def run(command, environment={})
    chdir do
      overriding_environment(environment) do
        system(command)
      end
    end
  end

  private

  def chdir(&block)
    Dir.chdir(cwd, &block)
  end

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
