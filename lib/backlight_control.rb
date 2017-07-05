class BacklightControl
  class << self
    attr_accessor :managment, :handler
  end

  def self.setup
    self.setup_event
    self.managment = true
    BacklightControl.on
  end

  def self.setup_event
    DaFunk::EventListener.new :backlight do |event|
      event.check do
        event.handlers.each do |option, handler|
          handler.perform
        end
      end
    end

    self.handler = DaFunk::EventHandler.new(:backlight, seconds: 120) do
      BacklightControl.off
    end
  end

  def self.on
    if self.managment
      self.handler.schedule_timer
      Device::System.backlight = 100
    end
  end

  def self.off
    if self.managment
      self.handler.schedule_timer
      Device::System.backlight = 0
    end
  end
end

