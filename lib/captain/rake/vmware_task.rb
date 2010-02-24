module Captain
  module Rake
    class VMwareTask
      attr_reader :virtual_machine
      attr_reader :name
      attr_reader :description

      def initialize(name='vmware', description='Build a VMware virtual machine')
        @virtual_machine = Captain::VM::VMware.new

        @name        = name
        @description = description

        yield virtual_machine if block_given?

        define
      end

      def define
        file virtual_machine.path => virtual_machine.prerequisites do
          virtual_machine.create
        end

        desc description
        task name => virtual_machine.path
      end
    end
  end
end
