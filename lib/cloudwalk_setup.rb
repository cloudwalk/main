class CloudwalkSetup
  include DaFunk::Helper

  def self.boot(start_attach = true)
    boot_layout
    self.setup_notifications
    self.setup_listeners
    self.setup_events
    LogControl.purge
    CloudwalkFont.setup
    PosxmlParser.setup
    BacklightControl.setup
    DaFunk::ParamsDat.parameters_load
    self.schedule_routines_from_rb_apps
    self.setup_keyboard_events_from_rb_apps
    self.pre_load_applications
    DaFunk::EventHandler.new :magnetic, nil do end
    Context::ThreadScheduler.start
  end

  def self.setup_listeners
    DaFunk::EventListener.new :key_main do |event|
      event.check do
        key = getc(100)
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

    DaFunk::EventListener.new :touchscreen do |event|
      event.check do
        touch_clear
        x, y = getxy_stream(800)
        if x && y
          event.handlers.each do |option, handler|
            if option.is_a?(Hash)
              if option.include?(:x) && option.include?(:y)
                if option[:x].include?(x) && option[:y].include?(y)
                  BacklightControl.on
                  Device::Audio.beep(7, 60)
                  handler.perform
                end
              end
            end
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
          DaFunk::PaymentChannel.connect(false) if DaFunk::PaymentChannel.channel_limit_exceed?
          handler = event.handlers.find { |option, h| @mag.bin?(h.option) }
          if handler
            BacklightControl.on
            if check_connection
              handler[1].perform(@mag)
            end
            BacklightControl.on
          end
          DaFunk::PaymentChannel.close! if DaFunk::PaymentChannel.transaction_http?
          event.finish
          event.start
        end
      end

      event.finish do
        @mag.close
        EmvTransaction.reboot
      end
    end

    DaFunk::EventListener.new :schedule do |event|
      event.check do
        handler = event.handlers.find { |option, h| h.execute? }
        handler[1].perform if handler
      end
    end

    DaFunk::EventListener.new :emv do |event|
      event.start do
        EmvTransaction.boot
        true
      end

      event.check do
        if EmvTransaction.opened? && DaFunk::ParamsDat.file["emv_enabled"] != "0"
          if EmvTransaction.detected?
            if DaFunk::PaymentChannel.channel_limit_exceed?
              DaFunk::PaymentChannel.connect(false)
            end
            BacklightControl.on
            if CloudwalkSetup.check_connection
              EmvTransaction.clean
              EmvTransaction.initialize do |emv|
                FunkyEmv::Ui.display(:emv_processing, :line => 2, :column => 1)
                emv.set_initial_data
                handler = event.handlers.first
                handler[1].perform(emv.select) if handler && handler[1]
              end
              EmvTransaction.reboot
            end
            DaFunk::PaymentChannel.close! if DaFunk::PaymentChannel.transaction_http?
            BacklightControl.on
          end
        else
          EmvTransaction.boot if DaFunk::ParamsDat.file["emv_enabled"] != "0"
        end
      end

      event.finish do
        EmvTransaction.clean
      end
    end

    DaFunk::EventListener.new :file_exists do |event|
      event.start do
        true
      end

      event.check do
        event.handlers.each do |option, handler|
          handler.perform if File.exists?(option)
        end
      end
    end

    DaFunk::EventListener.new :boot do |event|
      event.start do true end

      event.check do
        event.handlers.each do |file_path, handler|
          handler.perform if File.exists?(file_path)
        end
        Device::Setting.boot = "0"
        event.delete
      end
    end

    DaFunk::EventHandler.new :file_exists, "./shared/system_update" do
      if File.read("./shared/system_update") == 'DONE'
        SystemUpdate.new.start
      end
    end

    DaFunk::EventHandler.new :file_exists, "./shared/application_update" do
      CloudwalkUpdate.application
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
        @id ||= Context::ThreadPubSub.subscribe
        true
      end

      event.check do
        if Context::ThreadPubSub.listen(@id) == "communication_update"
          Device::Runtime.system_reload
        end

        if (! ThreadScheduler.pause?(ThreadScheduler::THREAD_EXTERNAL_COMMUNICATION, 200) &&
            payload = DaFunk::PaymentChannel.current.check)
          payload, notification = DaFunk::Notification.check(payload)
          if notification && notification.reply
            DaFunk::PaymentChannel.current.write(notification.reply)
          end
          handler = event.handlers[payload]
          handler.perform(notification) if handler
        end
      end
    end

    DaFunk::EventHandler.new :schedule, hours: 2, slot: 'battery_check' do
      if Device::System.battery < 20 && ! Device::System.power_supply
        if File.exists?('./shared/battery_low.bmp')
          Device::Display.print_bitmap('./shared/battery_low.bmp')
        else
          Device::Display.clear
          Device::Display.print_line(I18n.t(:battery_low).split("\n")[0], 3, 0)
          Device::Display.print_line(I18n.t(:battery_low).split("\n")[1], 4, 0)
        end

        5.times do
          Device::Audio.beep(0, 180)
          getc(1500)
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
        if (! ThreadScheduler.pause?(ThreadScheduler::THREAD_EXTERNAL_COMMUNICATION, 200) &&
            payload = DaFunk::PaymentChannel.check(false))
          handler = event.handlers[payload]
          if handler
            handler.perform
          else
            Context::ThreadChannel.write(:recv, payload) if payload.is_a?(String)
          end
        end
      end
    end

    # Necessary to enable Listener check
    DaFunk::EventHandler.new :payment_channel, :nothing do
      true
    end

    DaFunk::EventListener.new :communication do |event|
      event.start do
        true
      end

      event.check do
        handler = event.handlers[DaFunk::ConnectionManagement.check]
        handler.perform if handler
      end
    end

    DaFunk::EventHandler.new :communication, :attach_registration_fail do
      attach(print_last: false)
    end

    DaFunk::EventHandler.new :communication, :fallback_communication do
      if DaFunk::ConnectionManagement.fallback_valid?
        DaFunk::PaymentChannel.close!
        Device::Network.shutdown
        if DaFunk::ConnectionManagement.recover_fallback
          attach(print_last: false)
        end
      end
    end

    DaFunk::EventHandler.new :communication, :primary_communication do
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

    DaFunk::EventListener.new :schedule do |event|
      event.start do
        true
      end

      event.check do
        handler = event.handlers.find { |option, h| h.execute? }
        handler[1].perform if handler
      end
    end

    DaFunk::EventListener.new :background_system_update do |event|
      event.start do true end

      event.check do
        if SystemUpdate.current
          handler = event.handlers.first
          handler[1].perform if handler
        end
      end
    end

    DaFunk::EventHandler.new :background_system_update, :nothing do
      SystemUpdate.current&.bg_check
    end

    DaFunk::EventListener.new :file_exists do |event|
      event.start do
        true
      end

      event.check do
        event.handlers.each do |option, handler|
          handler.perform if File.exists?(option)
        end
      end
    end

    DaFunk::EventHandler.new :file_exists, "./shared/system_update" do
      SystemUpdate.bg_start
    end

    DaFunk::EventHandler.new :schedule, minutes: 2 do
      GC.start
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

  def self.setup_keyboard_events_from_rb_apps
    DaFunk::ParamsDat.ruby_executable_apps.each do |app|
      if File.exists?("#{app.dir}/cw_keys.json")
        app_keys = JSON.parse(File.read("#{app.dir}/cw_keys.json"))
        app_keys.each do |key, options|
          DaFunk::EventHandler.new :key_main, key do
            app       = options["app"]
            operation = options["initialization"]
            Device::Runtime.execute(app, operation.to_json)
          end
        end
      end
    end
  end

  def self.schedule_routines_from_rb_apps
    DaFunk::ParamsDat.ruby_executable_apps.each do |app|
      schedule_path = "#{app.dir}/cw_app_schedule.json"
      if File.exists?(schedule_path)
        schedule_params = JSON.parse(File.read(schedule_path))
        schedule_params["routines"].each do |params|
          ruby_app      = params["app"]
          function      = { :initialize => params["routine"]["initialize"] }
          interval      = params["routine"]["interval"].to_i
          file_check    = params["routine"]["file_check"]
          function_boot = { :initialize => params["routine"]["boot"] }

          DaFunk::EventHandler.new :schedule, seconds: interval do
            Device::Runtime.execute(ruby_app, function.to_json)
          end

          if file_check
            DaFunk::EventHandler.new :file_exists, posxml_file_path(file_check) do
              Device::Runtime.execute(ruby_app, function.to_json)
            end
          end

          if params["routine"].include?("boot")
            DaFunk::EventHandler.new :boot, ruby_app do
              Device::Runtime.execute(ruby_app, function_boot.to_json)
            end
          end
        end
      end
    end
  end

  def self.setup_events
    if InputTransactionAmount.enabled? && InputTransactionAmount.emv_ctls_table_installed?
      DaFunk::EventHandler.new :touchscreen, {:x => 41..199, :y => 179..233} do
        InputTransactionAmount.call
      end

      (1..9).to_a.each do |key|
        DaFunk::EventHandler.new :key_main, key.to_s do InputTransactionAmount.call(key.to_s) end
      end
    end

    DaFunk::EventHandler.new :key_main, Device::IO::ENTER do CloudwalkSetup.start            end
    DaFunk::EventHandler.new :key_main, Device::IO::F1    do AdminConfiguration.perform      end
    if Device::System.model == "link2500"
      DaFunk::EventHandler.new :key_main, Device::IO::ALPHA    do AdminConfiguration.perform end
    end

    if Device::System.model == "s920"
      DaFunk::EventHandler.new :key_main, Device::IO::ALPHA  do AdminConfiguration.perform      end
    end

    DaFunk::EventHandler.new :key_main, Device::IO::CLEAR do Device::Printer.paperfeed       end
    if Context.development?
      DaFunk::EventHandler.new :key_main, Device::IO::F2    do DaFunk::Engine.stop!          end
      if Device::System.model != "link2500"
        if Device::System.model == "s920"
          DaFunk::EventHandler.new :key_main, Device::IO::FUNC do DaFunk::Engine.stop!        end
        else
          DaFunk::EventHandler.new :key_main, Device::IO::ALPHA do DaFunk::Engine.stop!        end
        end
      end
    end

    DaFunk::EventHandler.new :payment_channel, :notification do |notification|
      BacklightControl.on
      notification.perform
      BacklightControl.on
    end

    value = DaFunk::ParamsDat.file["update_interval"]
    interval = (value.to_s.empty? ? 120 : value.to_i)
    DaFunk::EventHandler.new :schedule, hours: interval, slot: "update_interval" do
      CloudwalkUpdate.application
    end

    value = DaFunk::ParamsDat.file["system_update_interval"]
    if value.to_s != "0"
      interval = (value.to_s.empty? ? 360 : value.to_i)
      DaFunk::EventHandler.new :schedule, hours: interval, slot: "system_update_interval" do
        CloudwalkUpdate.system
      end
    end

    value = DaFunk::ParamsDat.file["log_send_interval"] || 24
    DaFunk::EventHandler.new :schedule, hours: value, slot: "log" do
      LogControl.upload
    end

    DaFunk::EventHandler.new :schedule, minutes: 2 do
      GC.start
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

  def self.pre_load_applications
    DaFunk::ParamsDat.ruby_executable_apps.each do |application|
      application.start
    end
  end

  def self.boot_layout
    BOOT_LAYOUT_FILE = {
      :default =>         './shared/boot_welcome.bmp',
      :update_process => './shared/6steps_updating.bmp'
    }

    I18n.configure("main", Device::Setting.locale)

    if update_process_in_progess?
      Device::Display.print_bitmap(BOOT_LAYOUT_FILE[:update_process])
    else
      Device::Display.print_bitmap(BOOT_LAYOUT_FILE[:default])
    end

    Device::Setting.boot = "1"
  end

  def self.update_process_in_progess?
    File.exists?('./shared/cw_update_steps.dat')
  end
end
