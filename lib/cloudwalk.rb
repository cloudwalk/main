class Cloudwalk
  include DaFunk::Helper

  def self.boot(start_attach = true)
    I18n.configure("main", Device::Setting.locale)
    I18n.pt(:setup_booting)
    self.setup_notifications
    self.setup_listeners
    self.setup_events
    PosxmlParser.setup
    if Device::Network.configured? && start_attach
      if attach
        I18n.pt(:setup_notifications)
        Device::Notification.start
      end
    end
  end

  def self.setup_listeners
    DaFunk::EventListener.new :key_main do |event|
      event.check do
        key = getc(400)
        handler = event.handlers[key]
        handler.perform if handler
      end
    end

    DaFunk::EventListener.new :magnetic do |event|
      event.start do
        @mag = Device::Magnetic.new
        @mag.open?
      end

      event.check do
        if @mag && @mag.swiped?
          handler = event.handlers.find { |option, h| @mag.bin?(h.option) }
          handler[1].perform(@mag.track2) if handler
          event.finish
          event.start
        end
      end

      event.finish do @mag.close if @mag end
    end

    DaFunk::EventListener.new :schedule do |event|
      event.check do
        handler = event.handlers.find { |option, h| h.execute? }
        handler.perform if handler
      end
    end

    DaFunk::EventListener.new :emv do |event|
      event.start do
        if File.exists? "./shared/emv_acquirer_aids_04.dat"
          EmvTransaction.open("01")
          EmvTransaction.clean
          EmvTransaction.load("4")
        end
        true
      end

      event.check do
        if EmvTransaction.opened? && Device::ParamsDat.file["emv_enabled"] == "1"
          EmvTransaction.initialize do |emv|
            time = Time.now
            emv.init_data.date = ("%s%02d%02d" % [time.year.to_s[2..3], time.month, time.day])
            emv.init_data.initial_value = "000000000000"
            if emv.icc.detected?
              handler = event.handlers.first
              handler[1].perform(emv.select) if handler && handler[1]
            end
          end
        else
          if File.exists?("./shared/emv_acquirer_aids_04.dat") && Device::ParamsDat.file["emv_enabled"] == "1"
            EmvTransaction.open("01")
            EmvTransaction.clean
            EmvTransaction.load("4")
          end
        end
      end

      event.finish do
        EmvTransaction.clean
      end
    end
  end

  def self.setup_events
    DaFunk::EventHandler.new :key_main, Device::IO::ENTER do Cloudwalk.start end
    DaFunk::EventHandler.new :key_main, Device::IO::F1 do AdminConfiguration.perform end
    DaFunk::EventHandler.new :key_main, Device::IO::F2 do DaFunk::Engine.stop! end
    DaFunk::EventHandler.new :key_main, Device::IO::FUNC do AdminConfiguration.perform end #PAX s920
    DaFunk::EventHandler.new :key_main, Device::IO::ALPHA do DaFunk::Engine.stop! end #PAX s920
    DaFunk::EventHandler.new :key_main, Device::IO::CLEAR do Device::Printer.paperfeed end
  end

  def self.setup_notifications
    Device::NotificationCallback.new "APP_UPDATE", :on => Proc.new { Device::ParamsDat.update_apps(true) }
    Device::NotificationCallback.new "SETUP_DEVICE_CONFIG", :on => Proc.new { Device::ParamsDat.update_apps(true) }
    Device::NotificationCallback.new "RESET_DEVICE_CONFIG", :on => Proc.new { Device::ParamsDat.format! }

    Device::NotificationCallback.new "SYSTEM_UPDATE", :on => Proc.new { |file| }
    Device::NotificationCallback.new "CANCEL_SYSTEM_UPDATE", :on => Proc.new { }
    Device::NotificationCallback.new "TIMEZONE_UPDATE", :on => Proc.new { Device::Setting.cw_pos_timezone = "" }
    Device::NotificationCallback.new "SHOW_MESSAGE", :on => Proc.new { |message, datetime|
      Device::Display.clear
      date = datetime.sub(" ", "-").split("-")
      Device::Display.print_line("#{date[1]}/#{date[0]}/#{date[2]} #{date[3]}", 0)
      Device::Display.print_line("#{message}", 2)
      getc(0)
    }
  end

  def self.execute
    unless application = Device::ParamsDat.executable_app
      application = Device::ParamsDat.application_menu
    end
    application.execute if application
  end

  def self.start
    if Device::ParamsDat.ready?
      self.execute
    elsif Device::ParamsDat.exists?
      Device::ParamsDat.update_apps
    else
      CloudwalkWizard.new.start
    end
  end
end

