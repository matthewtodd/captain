module Captain
  class Application
    def initialize
      load_default_configuration
    end

    def run

    end

    def method_missing(symbol, *args)
      if args.length > 0
        @configuration[symbol] = args.first
      elsif @configuration.has_key?(symbol)
        @configuration[symbol]
      else
        super
      end
    end

    private

    def load_default_configuration
      @configuration = Hash.new

      output_directory  '.'
      repositories      ['http://us.archive.ubuntu.com/ubuntu jaunty main']
      selectors         ['^standard']
      working_directory 'image'
    end
  end
end