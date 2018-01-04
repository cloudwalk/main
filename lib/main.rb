require 'posxml_parser'
require 'funky-emv'
require "funky-simplehttp"

class Main < Device
  include DaFunk::Helper

  def self.call
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

  def self.version
    "1.47.0"
  end
end

