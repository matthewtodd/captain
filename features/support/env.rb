require 'pathname'
require 'tmpdir'

class DirectoryHelper
  class << self
    MEMO = Pathname.new('.directories')

    def clean_up_last_run
      return unless MEMO.exist?

      MEMO.readlines.each do |dir|
        dir.strip!
        if File.directory?(dir) && dir.index(ENV['TMPDIR']) == 0
          FileUtils.remove_entry_secure(dir)
        else
          abort "Corrupt line in #{MEMO}:\n#{dir}"
        end
      end

      MEMO.delete
    end

    def remember(dir)
      MEMO.open('a') do |stream|
        stream.puts(dir)
      end
    end
  end

  def temp
    dir = Dir.mktmpdir
    self.class.remember(dir)
    Pathname.new(dir)
  end
end

# "before all"
DirectoryHelper.clean_up_last_run

module DirectoryWorld
  attr_accessor :directory
end

World(DirectoryWorld)

Before do
  self.directory = DirectoryHelper.new
end
