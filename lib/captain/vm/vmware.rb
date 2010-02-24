require 'erb'

module Captain
  module VM
    class VMware
      attr_accessor :name
      attr_accessor :operating_system
      attr_accessor :iso_image

      def initialize(name='vm', operating_system='ubuntu')
        @name             = name
        @operating_system = operating_system
      end

      def path
        Pathname.new("#{name}.vmwarevm")
      end

      def prerequisites
        [iso_image].compact
      end

      def create
        path.rmtree if path.exist?
        path.mkpath

        path.join(config_path).open('w') do |stream|
          stream.write(config_contents)
        end

        system "vmware-vdiskmanager -c -s 2GB -a lsilogic -t 0 #{path}/#{hard_disk_path}"
      end

      private

      def config_contents
        ERB.new(config_template).result(binding)
      end

      def config_template
        <<-TEMPLATE.gsub(/^\s+/, '').strip
          config.version = "8"
          virtualHW.version = "7"
          scsi0.present = "TRUE"
          scsi0.virtualDev = "lsilogic"
          memsize = "512"
          scsi0:0.present = "TRUE"
          scsi0:0.fileName = "<%= hard_disk_path %>"
          <% if iso_image %>
          ide1:0.present = "TRUE"
          ide1:0.fileName = "<%= iso_image_path %>"
          ide1:0.deviceType = "cdrom-image"
          <% end %>
          floppy0.present = "FALSE"
          ethernet0.present = "TRUE"
          usb.present = "TRUE"
          sound.present = "FALSE"
          displayName = "<%= display_name %>"
          guestOS = "<%= operating_system %>"
          nvram = "<%= nvram_path %>"
          workingDir = "<%= path.expand_path %>"
        TEMPLATE
      end

      def config_path
        "#{name}.vmx"
      end

      def display_name
        name.capitalize
      end

      def hard_disk_path
        "#{name}.vmdk"
      end

      def iso_image_path
        Pathname.new(iso_image).relative_path_from(path)
      end

      def nvram_path
        "#{name}.nvram"
      end
    end
  end
end
