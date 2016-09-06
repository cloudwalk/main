require 'posxml_parser'
require 'funky-emv'

class Main < Device
  include Device::Helper

  def self.call
    Cloudwalk.boot
    DaFunk::Engine.app_loop do
      Device::Display.print_main_image
      Device::Display.print(I18n.t(:time, :time => Time.now), 6, 0)
    end
  end

  def self.version
    "1.0.9"
  end
end

