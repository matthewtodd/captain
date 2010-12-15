require 'erb'
require 'virtualbox'

module Captain
  module VM
    class VirtualBox
      attr_accessor :name
      attr_accessor :operating_system
      attr_accessor :config
      attr_accessor :vm

      def initialize(name='vm', operating_system='ubuntu')
        @name             = name
        @operating_system = operating_system
      end

      def iso_image
        config.iso_image_path
      end

      def prerequisites
        [iso_image].compact
      end

      def path
        Pathname.new(File.expand_path("~/Library/VirtualBox/Machines/#{name}/#{name}.xml"))
      end

      def os_type_id
        operating_system.capitalize << "_64" if config.architecture == "amd64"
      end

      def vm
        @vm ||= ::VirtualBox::VM.find(name)
      end

      def create
        `VBoxManage createvm --name #{name} --register`
        vm.os_type_id = os_type_id

        vm.memory_size = 512
        vm.network_adapters[0].enabled = true
        vm.network_adapters[0].attachment_type = :nat
        vm.boot_order = [:dvd, :hard_disk, :null, :null]
        vm.bios.acpi_enabled = true
        vm.save

        `VBoxManage createvdi -filename #{hard_disk} -size 10000 -register`
        `VBoxManage storagectl #{name} --name 'SATA Controller' --add sata`
        `VBoxManage storagectl #{name} --name 'IDE Controller' --add ide`
        `VBoxManage storageattach #{name} --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium #{hard_disk_path}`
        `VBoxManage storageattach #{name} --storagectl 'IDE Controller' --port 0 --device 0 --type dvddrive --medium #{iso_image_path}`
      end

      private

      def output_path
        Pathname.new(File.expand_path('.')).relative_path_from(iso_image_path)
      end

      def ovf_path
        File.join(output_path, "#{name}.ovf")
      end

      def display_name
        name.capitalize
      end

      def iso_image_path
        Pathname.new(File.expand_path(iso_image))
      end

      def vboxguestadditions_iso_path
        "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
      end

      def hard_disk_path
        "~/Library/VirtualBox/HardDisks/#{hard_disk}"
      end

      def hard_disk
        "#{name}.vdi"
      end

    end
  end
end
