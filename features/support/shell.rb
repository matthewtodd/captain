require 'pathname'
require 'tmpdir'

class ShellHelper
  ROOT = Pathname.new('../../..').expand_path(__FILE__)

  def initialize
    @cwd = Dir.mktmpdir
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
    Dir.chdir(@cwd, &block)
  end

  def open(path)
    puts "Opening #{path}. Cucumber will resume once the application quits."
    run "open -W -n #{path}"
  end

  def run(command)
    chdir { system with_rubylib(command) }
  end

  private

  def system(*args)
    super || raise('Command failed!')
  end

  def with_rubylib(command)
    "/usr/bin/env RUBYLIB=#{ROOT.join('lib')} #{command}"
  end
end
