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
    DaFunk::ParamsDat.parameters_load
    DaFunk::EventHandler.new :magnetic, nil do end
    ThreadScheduler.start
  end

  def self.setup_listeners
    DaFunk::EventListener.new :key_main do |event|
      event.check do
        key = getc(1000)
        if key != Device::IO::KEY_TIMEOUT
          BacklightControl.on
          handler = event.handlers[key]
          if handler
            handler.perform
            BacklightControl.on
          end
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

    DaFunk::EventListener.new :payment_channel do |event|
      event.start do
        true
      end

      event.check do
        if (payload = DaFunk::PaymentChannel.client.check)
          payload, notification = DaFunk::Notification.check(payload)
          if notification && notification.reply
            DaFunk::PaymentChannel.client.write(notification.reply)
          end
          handler = event.handlers[payload]
          handler.perform(notification) if handler
        end
      end
    end
  end

  def self.setup_communication_listeners
    DaFunk::EventListener.new :payment_channel do |event|
      event.start do
        DaFunk::PaymentChannel.check(false)
        true
      end

      event.check do
        if (payload = DaFunk::PaymentChannel.check(false))
          handler = event.handlers[payload]
          if handler
            handler.perform
          else
            Context::ThreadChannel.queue_write(ThreadScheduler::THREAD_COMMUNICATION, payload) if payload.is_a?(String)
          end
        end
      end
    end

    DaFunk::EventHandler.new :payment_channel, :attach_registration_fail do
      attach(print_last: false)
    end

    DaFunk::EventHandler.new :payment_channel, :fallback_communication do
      if DaFunk::ConnectionManagement.fallback_valid?
        DaFunk::PaymentChannel.close!
        Device::Network.shutdown
        if DaFunk::ConnectionManagement.recover_fallback
          attach(print_last: false)
        end
      end
    end

    DaFunk::EventHandler.new :payment_channel, :primary_communication do
      if DaFunk::ConnectionManagement.fallback_valid?
        DaFunk::PaymentChannel.close!
        Device::Network.shutdown
        if DaFunk::ConnectionManagement.recover_primary
          unless attach(print_last: false)
            Device::Network.shutdown
            if DaFunk::ConnectionManagement.recover_fallback
              attach(print_last: false)
            end
          end
        end
      end
    end
  end

  def self.countdown_menu
    if timeout = DaFunk::ParamsDat.file["countdown_max_timeout"] && timeout.integer?
      timeout = timeout.to_i
    end
    (1..(timeout || 5)).to_a.reverse.each do |second|
      DaFunk::PaymentChannel.print_info(I18n.t(:attach_registration_fail, :args => second), true)
      key = getc(1000)
      if key == Device::IO::ENTER
        if (app = DaFunk::ParamsDat.file["countdown_application"])
          Device::Runtime.execute(app)
        else
          AdminConfiguration.perform
        end
      elsif key == Device::IO::F1 || key == Device::IO::FUNC
        AdminConfiguration.perform
      end
    end
  end

  def self.setup_events
    DaFunk::EventHandler.new :key_main, Device::IO::ENTER do CloudwalkSetup.start            end
    DaFunk::EventHandler.new :key_main, Device::IO::F1    do AdminConfiguration.perform      end
    if Device::System.model == "link2500"
      DaFunk::EventHandler.new :key_main, Device::IO::ALPHA    do AdminConfiguration.perform end
    end
    DaFunk::EventHandler.new :key_main, Device::IO::FUNC  do AdminConfiguration.perform      end
    DaFunk::EventHandler.new :key_main, Device::IO::CLEAR do Device::Printer.paperfeed       end
    if Context.development?
      DaFunk::EventHandler.new :key_main, Device::IO::F2    do DaFunk::Engine.stop!          end
      if Device::System.model != "link2500"
        DaFunk::EventHandler.new :key_main, Device::IO::ALPHA do DaFunk::Engine.stop!        end
      end
    end

    DaFunk::EventHandler.new :payment_channel, :notification do |notification|
      BacklightControl.on
      notification.perform
      BacklightControl.on
    end

    value = DaFunk::ParamsDat.file["update_interval"]
    interval = (value.to_s.empty? ? 168 : value.to_i)
    DaFunk::EventHandler.new :schedule, hours: interval, slot: "update_interval" do
      CloudwalkUpdate.perform
    end
  end

  def self.setup_notifications
    DaFunk::NotificationCallback.new "APP_UPDATE", :on => Proc.new { DaFunk::ParamsDat.update_apps(true); Device::System.reboot }
    DaFunk::NotificationCallback.new "SETUP_DEVICE_CONFIG", :on => Proc.new { DaFunk::ParamsDat.update_apps(true) }
    DaFunk::NotificationCallback.new "RESET_DEVICE_CONFIG", :on => Proc.new { DaFunk::ParamsDat.format! }
    DaFunk::NotificationCallback.new "REBOOT", :on => Proc.new { Device::System.reboot }

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

  def self.execute(application = nil)
    application ||= DaFunk::ParamsDat.executable_app
    unless application
      application = DaFunk::ParamsDat.application_menu
    end
    application.execute if application
  end

  def self.start
    applications = DaFunk::ParamsDat.executable_apps
    application = DaFunk::ParamsDat.executable_app
    if DaFunk::ParamsDat.exists?
      if (applications && applications.size > 1) || (application && application.exists?)
        return self.execute
      end
    end
    CloudwalkWizard.new.start
  end
end

