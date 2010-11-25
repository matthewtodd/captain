require 'erb'
require 'virtualbox'

module Captain
  module VM
    class VirtualBox
      attr_accessor :name
      attr_accessor :operating_system
      attr_accessor :iso_image

      def initialize(name='vm', operating_system='ubuntu')
        @name             = name
        @operating_system = operating_system
      end

      def prerequisites
        [iso_image].compact
      end

      def path
        Pathname.new(File.expand_path("~/Library/VirtualBox/Machines/#{name}/#{name}.xml"))
      end

      def create
        `VBoxManage createvm --name #{name} --ostype Ubuntu_64 --register`
        vm = ::VirtualBox::VM.find(name)

        vm.memory_size = 256
        vm.network_adapters[0].enabled = true
        vm.boot_order = [:dvd, :hard_disk, :null, :null]
        vm.bios.acpi_enabled = true
        vm.save

        `VBoxManage createvdi -filename #{hard_disk} -size 10000 -register`
        `VBoxManage storagectl #{name} --name 'SATA Controller' --add sata`
        `VBoxManage storagectl #{name} --name 'IDE Controller' --add ide`
        `VBoxManage storageattach #{name} --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium #{hard_disk_path}`
        `VBoxManage storageattach #{name} --storagectl 'IDE Controller' --port 0 --device 0 --type dvddrive --medium #{iso_image_path}`
        `VBoxManage storageattach #{name} --storagectl 'IDE Controller' --port 0 --device 1 --type dvddrive --medium #{vboxguestadditions_iso_path}`
        
        vm.start("gui")

        puts "Waiting for installation to finish and box to shutdown"
        until vm.powered_off?
          sleep 15
          print "."
        end

        vm.medium_attachments.reject{|ma| ma.type == :hard_disk }.each {|ma| ma.detach }
        vm.save

        vm.export(ovf_path)
        vm.destroy(:destroy_medium => :delete)
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
