require 'fog/tenderfusion'
require 'fog/compute'
require 'base64'
require 'fog/tenderfusion/vmxfile'
require 'pathname'
require 'fileutils'

module Fog
  module Compute
    class Tenderfusion < Fog::Service
      VMRUN = "/Applications/VMware\\ Fusion.app/Contents/Library/vmrun"

      recognizes :loin_dir

      model_path 'fog/tenderfusion/models/compute'
      # model       :server
      # collection  :servers

      request_path 'fog/tenderfusion/requests/compute'
      # fusion interaction
      request :vm_running
      request :start_vm
      request :stop_vm
      request :delete_fusion_vm
      request :vm_ip
      request :share_folder
      # filesystem interaction
      request :list_boxes
      request :list_defined_vms
      request :create_vm

      class Mock

        def initialize(options)
        end

        def request(options)
          raise "Not implemented"
        end
      end

      class Real

        def initialize(options)
          @loin_dir     = options[:loin_dir] || "~/.tenderloin"
        end

        def box_dir
          Pathname.new(File.join(@loin_dir, 'boxes')).expand_path
        end

        def vm_dir
          Pathname.new(File.join(@loin_dir, 'vms')).expand_path
        end

        def vmrun(cmd, args={})
          runcmd = "#{VMRUN} #{cmd} #{args[:vmx]} #{args[:opts]}"
          retrycount = 0
          while true
            res = `#{runcmd}`
            if $? == 0
              return res
            elsif res =~ /The virtual machine is not powered on/
              return
            else
              if res =~ /VMware Tools are not running/
                sleep 1; next unless retrycount > 10
              end
              raise "Error running vmrun command:\n#{runcmd}\nResponse: " + res
            end
          end
        end

        # def to_dotted_hash(source, target = {}, namespace = nil)
        #   prefix = "#{namespace}." if namespace
        #   case source
        #   when Hash
        #     source.each do |key, value|
        #       to_dotted_hash(value, target, "#{prefix}#{key}")
        #     end
        #   when Array
        #     source.each_with_index do |value, index|
        #       to_dotted_hash(value, target, "#{prefix}#{index}")
        #     end
        #   else
        #     target[namespace] = source
        #   end
        #   target
        # end


      end
    end
  end
end
