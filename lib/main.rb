require 'posxml_parser'
require 'funky-emv'

class Main < Device
  include Device::Helper

  def self.call
    Cloudwalk.boot
    DaFunk::Engine.app_loop do
      Device::Display.print_main_image
      Device::Display.print(I18n.t(:time, :time => Time.now), STDOUT.max_y - 1, 0)
    end
  end

  def self.version
    "1.1.2"
  end
end

