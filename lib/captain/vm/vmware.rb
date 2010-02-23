require 'erb'

module Captain
  module VM
    class VMware
      attr_reader :display_name
      attr_reader :operating_system
      attr_reader :base_path
      attr_reader :config_path
      attr_reader :hard_disk_path
      attr_reader :nvram_path
      attr_reader :cdrom_image_path

      def initialize(base_path, cdrom_image_path, name='cucumber', operating_system='ubuntu')
        @display_name     = name.capitalize
        @operating_system = operating_system

        @base_path        = Pathname.new(base_path)
        @config_path      = "#{name}.vmx"
        @hard_disk_path   = "#{name}.vmdk"
        @nvram_path       = "#{name}.nvram"
        @cdrom_image_path = Pathname.new(cdrom_image_path)
      end

      def create
        base_path.mkpath

        base_path.join(config_path).open('w') do |stream|
          stream.write(config_contents)
        end

        system "vmware-vdiskmanager -c -s 2GB -a lsilogic -t 0 #{base_path}/#{hard_disk_path}"
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
          ide1:0.present = "TRUE"
          ide1:0.fileName = "<%= cdrom_image_path.relative_path_from(base_path) %>"
          ide1:0.deviceType = "cdrom-image"
          floppy0.present = "FALSE"
          ethernet0.present = "TRUE"
          usb.present = "TRUE"
          sound.present = "FALSE"
          displayName = "<%= display_name %>"
          guestOS = "<%= operating_system %>"
          nvram = "<%= nvram_path %>"
          workingDir = "<%= base_path.expand_path %>"
        TEMPLATE
      end
    end
  end
end
