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

  def chdir(&block)
    Dir.chdir(cwd, &block)
  end

  def open(path)
    puts "Opening #{path}. Cucumber will resume once the application quits."
    run 'open', '-W', '-n', path
  end

  def run(*args)
    chdir do
      system(*args)
    end
  end
end
