module Captain
  module Rake
    class IsoTask
      attr_reader :config
      attr_reader :name
      attr_reader :description

      def initialize(name='captain', description='Build the iso image')
        @config      = Configuration.new
        @name        = name
        @description = description

        yield config if block_given?

        define
      end

      def define
        file config.iso_image_path => prerequisites do
          Application.new(config).run
        end

        desc description
        task name => config.iso_image_path
      end

      private

      def prerequisites
        ::Rake::FileList[
          ::Rake.application.rakefile,
          "#{config.bundle_directory}/**/*"
        ]
      end
    end
  end
end
