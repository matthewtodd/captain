module Captain
  class Rake
    attr_reader :application
    attr_reader :config
    attr_reader :name
    attr_reader :description

    def initialize(name='captain', description='Build the iso image')
      @application = Application.new
      @config      = @application.configuration
      @name        = name
      @description = description

      yield config if block_given?

      define
    end

    def define
      file config.iso_image_path do
        application.run
      end

      desc description
      task name => config.iso_image_path
    end
  end
end
