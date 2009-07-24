require 'set'

module Captain
  class Package
    attr_reader :name

    def initialize(manifest)
      @manifest     = manifest
      @dependencies = Set.new
      @provides     = Set.new
      @recommends   = Set.new
      @tasks        = Set.new

      @manifest.each_line do |line|
        case line
        when /^Depends:(.*)$/
          @dependencies.merge(parse_list($1))
        when /^Package:(.*)$/
          @name = $1.strip
        when /^Provides:(.*)$/
          @provides.merge(parse_list($1))
        when /^Recommends:(.*)$/
          @recommends.merge(parse_list($1))
        when /^Task:(.*)$/
          @tasks.merge(parse_list($1))
        end
      end
    end

    def tasks
      @tasks
    end

    def name_and_provides
      @name_and_provides ||= @provides.dup.add(@name)
    end

    def required_and_recommended_dependencies
      @required_and_recommended_dependencies ||= @dependencies.dup.merge(@recommends)
    end

    private

    def parse_list(string)
      string.split(/[,|]/).map { |versioned| versioned.strip.split(' ').first }
    end
  end
end
