require 'posxml_parser'
require 'funky-emv'
require "funky-simplehttp"

class Main < Device
  include DaFunk::Helper

  def self.call(json = nil)
    case self.execute(json)
    when :admin_configuration
      AdminConfiguration.perform
    when :admin_communication
      AdminConfiguration.communication
    when :normal
      perform
    else
      perform
    end
  end

  def self.perform
    CloudwalkSetup.boot
    DaFunk::Engine.app_loop do
      Device::System.klass = "main"
      Device::Display.print_main_image
      MerchantName.display
      if DaFunk::ParamsDat.file["disable_datetime"] != "1"
        print_last(I18n.t(:time, :time => Time.now))
      end
    end
  end

  def self.execute(json)
    unless json
      :normal
    else
      if (hash = JSON.parse(json)) && hash["initialize"] == "admin_configuration"
        :admin_configuration
      elsif (hash = JSON.parse(json)) && hash["initialize"] == "admin_communication"
        :admin_communication
      else
        :normal
      end
    end
  rescue ArgumentError => e
    if e.messsage == "invalid json"
      :normal
    else
      raise
    end
  end

  def self.version
    "1.85.0"
  end
end

