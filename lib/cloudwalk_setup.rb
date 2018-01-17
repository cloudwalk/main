class CloudwalkSetup
  include DaFunk::Helper

  def self.boot(start_attach = true)
    I18n.configure("main", Device::Setting.locale)
    I18n.pt(:setup_booting)
    Device::Setting.boot = "1"
    self.setup_notifications
    self.setup_listeners
    self.setup_events
    CloudwalkFont.setup
    PosxmlParser.setup
    BacklightControl.setup
    DaFunk::EventHandler.new :magnetic, nil do end
    if Device::Network.configured? && start_attach
      attach
    end
  end

  def self.setup_listeners
    DaFunk::EventListener.new :key_main do |event|
      event.check do
        handler = event.handlers[getc(100)]
        if handler
          BacklightControl.on
          handler.perform
          BacklightControl.on
        end
      end
    end

    DaFunk::EventListener.new :magnetic do |event|
      event.start do
        @mag = Device::Magnetic.new
        true
      end

      event.check do
        @mag = Device::Magnetic.new unless @mag.open?
        if @mag.open? && @mag && @mag.swiped?
          handler = event.handlers.find { |option, h| @mag.bin?(h.option) }
          if handler
            BacklightControl.on
            if check_connection
              handler[1].perform(@mag.track2)
            end
            BacklightControl.on
          end
          event.finish
          event.start
        end
      end

      event.finish do @mag.close if @mag end
    end

    DaFunk::EventListener.new :schedule do |event|
      event.check do
        handler = event.handlers.find { |option, h| h.execute? }
        handler[1].perform if handler
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
        if EmvTransaction.opened? && DaFunk::ParamsDat.file["emv_enabled"] == "1"
          if EmvTransaction.detected?
            BacklightControl.on
            if CloudwalkSetup.check_connection
              EmvTransaction.clean
              EmvTransaction.initialize do |emv|
                FunkyEmv::Ui.display(:emv_processing, :line => 2, :column => 1)
                time = Time.now
                emv.init_data.date = ("%s%02d%02d" % [time.year.to_s[2..3], time.month, time.day])
                emv.init_data.initial_value = "000000000000"
                handler = event.handlers.first
                handler[1].perform(emv.select) if handler && handler[1]
                EmvTransaction.close
                EmvTransaction.open("01")
              end
            end
            BacklightControl.on
          end
        else
          if File.exists?("./shared/emv_acquirer_aids_04.dat") && DaFunk::ParamsDat.file["emv_enabled"] == "1"
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

    DaFunk::EventListener.new :payment_channel do |event|
      event.start do
        PaymentChannel.check(false)
        true
      end

      event.check do
        if (payload = PaymentChannel.check)
          payload, notification = DaFunk::Notification.check(payload)
          handler = event.handlers[payload]
          handler.perform(notification) if handler
        end
      end
    end

    DaFunk::EventListener.new :file_exists_once do |event|
      event.start do @file_exists_once = {}; true end

      event.check do
        event.handlers.each do |option, handler|
          if @file_exists_once[option].nil? && File.exists?(option)
            @file_exists_once[option] = true
            handler.perform
          end
        end
      end
    end
  end

  def self.countdown_menu
    (1..5).to_a.reverse.each do |second|
      PaymentChannel.print_info(I18n.t(:attach_registration_fail, :args => second), true)
      if getc(1000) == Device::IO::ENTER
        if (app = DaFunk::ParamsDat.file["countdown_application"])
          Device::Runtime.execute(app)
        else
          AdminConfiguration.perform
        end
      end
    end
  end

  def self.setup_events
    DaFunk::EventHandler.new :key_main, Device::IO::ENTER do CloudwalkSetup.start            end
    DaFunk::EventHandler.new :key_main, Device::IO::F1    do AdminConfiguration.perform end
    DaFunk::EventHandler.new :key_main, Device::IO::FUNC  do AdminConfiguration.perform end #PAX s920
    DaFunk::EventHandler.new :key_main, Device::IO::CLEAR do Device::Printer.paperfeed  end
    if Context.development?
      DaFunk::EventHandler.new :key_main, Device::IO::F2    do DaFunk::Engine.stop!       end
      DaFunk::EventHandler.new :key_main, Device::IO::ALPHA do DaFunk::Engine.stop!       end #PAX s920
    end
    DaFunk::EventHandler.new :payment_channel, :attach_registration_fail do
      BacklightControl.on
      self.countdown_menu
      attach
      BacklightControl.on
    end
    DaFunk::EventHandler.new :payment_channel, :fallback_communication do
      if ConnectionManagement.fallback_valid?
        BacklightControl.on
        PaymentChannel.close!
        Device::Network.shutdown
        if ConnectionManagement.recover_fallback
          PaymentChannel.print_info(I18n.t(:attach_configure_fallback), true)
          self.countdown_menu unless attach
        end
        BacklightControl.on
      end
    end

    DaFunk::EventHandler.new :payment_channel, :primary_communication do
      if ConnectionManagement.fallback_valid?
        BacklightControl.on
        PaymentChannel.close!
        Device::Network.shutdown
        if ConnectionManagement.recover_primary
          unless attach
            Device::Network.shutdown
            if ConnectionManagement.recover_fallback
              attach
            end
          end
        end
        BacklightControl.on
      end
    end
    DaFunk::EventHandler.new :payment_channel, :notification do |notification|
      BacklightControl.on
      notification.perform
      BacklightControl.on
    end
  end

  def self.setup_notifications
    DaFunk::NotificationCallback.new "APP_UPDATE", :on => Proc.new { DaFunk::ParamsDat.update_apps(true) }
    DaFunk::NotificationCallback.new "SETUP_DEVICE_CONFIG", :on => Proc.new { DaFunk::ParamsDat.update_apps(true) }
    DaFunk::NotificationCallback.new "RESET_DEVICE_CONFIG", :on => Proc.new { DaFunk::ParamsDat.format! }

    DaFunk::NotificationCallback.new "SYSTEM_UPDATE", :on => Proc.new { SystemUpdate.new.start }
    DaFunk::NotificationCallback.new "CANCEL_SYSTEM_UPDATE", :on => Proc.new { }
    DaFunk::NotificationCallback.new "TIMEZONE_UPDATE", :on => Proc.new { Device::Setting.cw_pos_timezone = "" }
    DaFunk::NotificationCallback.new "SHOW_MESSAGE", :on => Proc.new { |message, datetime|
      Device::Display.clear
      date = datetime.sub(" ", "-").split("-")
      Device::Display.print_line("#{date[1]}/#{date[0]}/#{date[2]} #{date[3]}", 0)
      Device::Display.print_line("#{message}", 2)
      getc(0)
    }
    DaFunk::NotificationCallback.new "PROCESSING", :on => Proc.new { |app,params|
      file, ext = app.split(".")
      if ext == "posxml"
        FileDb.new("./shared/#{file}.dat")["notification"] = params
        Device::Runtime.execute(app)
      else
        Device::Runtime.execute(app, params)
      end
    }
  end

  def self.check_connection
    if DaFunk::ParamsDat.file["transaction_conn_check"] == "1"
      if Device::Network.connected?
        true
      else
        Device::Display.clear
        I18n.pt(:transaction_no_connection)
        getc(5000)
        false
      end
    else
      true
    end
  end

  def self.execute
    unless application = DaFunk::ParamsDat.executable_app
      application = DaFunk::ParamsDat.application_menu
    end
    application.execute if application
  end

  def self.start
    if DaFunk::ParamsDat.ready?
      self.execute
    elsif DaFunk::ParamsDat.exists?
      DaFunk::ParamsDat.update_apps
    else
      CloudwalkWizard.new.start
    end
  end
end

