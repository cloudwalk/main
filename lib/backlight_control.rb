class BacklightControl
  class << self
    attr_accessor :handler
  end

  def self.setup
    self.setup_event
    BacklightControl.on
  end

  def self.setup_event
    DaFunk::EventListener.new :backlight do |event|
      event.check do
        event.handlers.each do |option, handler|
          handler.perform if self.enabled?
        end
      end
    end

    self.handler = DaFunk::EventHandler.new(:backlight, seconds: self.timeout) do
      BacklightControl.off
    end
  end

  def self.enabled?
    Device::ParamsDat.file["backlight_control"] != "0"
  end

  def self.timeout
    value = Device::ParamsDat.file["backlight_control"].to_s.strip
    if value.empty?
      120
    else
      value.to_i
    end
  end

  def self.on
    self.handler.schedule_timer
    Device::System.backlight = 100
  end

  def self.off
    self.handler.schedule_timer
    Device::System.backlight = 0
  end
end

