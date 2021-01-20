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
    when :communication
      self.thread_communication
    when :apps_update
      AdminConfiguration.apps_update
    when :system_update
      AdminConfiguration.system_update
    when :send_logs
      LogControl.upload
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
    if json.nil? || json.to_s.empty?
      :normal
    else
      options = JSON.parse(json)
      if options["initialize"] == "admin_configuration"
        :admin_configuration
      elsif options["initialize"] == "admin_communication"
        :admin_communication
      elsif options["initialize"] == "communication"
        :communication
      elsif options["initialize"] == "apps_update"
        :apps_update
      elsif options["initialize"] == "system_update"
        :system_update
      elsif options["initialize"] == "send_logs"
        :send_logs
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
  ensure
    $thread_name = options['initialize']&.to_sym if options.is_a?(Hash)
  end

  def self.thread_communication
    DaFunk::PaymentChannel.current = nil
    begin
      DaFunk::Helper::StatusBar.check
      CwMetadata.get
      id = Context::ThreadPubSub.subscribe
      attach(print_last: false) if Device::Network.configured?
      CloudwalkSetup.setup_communication_listeners
      ContextLog.info "[I] Thread pubsub id #{id}"
      thread_loop(id)
    rescue => e
      ContextLog.exception(e, e.backtrace, "Communication thread")
    end
  end

  def self.thread_loop(id)
    loop do
      begin
        break if Context::ThreadScheduler.die?(:communication)
        if (! Context::ThreadScheduler.pause?(:communication))
          if Context::ThreadPubSub.listen(id) == "communication_update"
            media_before = Device::Network.config
            Device::Runtime.system_reload
            media_after = Device::Network.config
            DaFunk::PaymentChannel.close! if (!media_before.eql? media_after) && @connected
            if Object.const_defined?(:CwMetadata) && Device::Network.connected?
              CwMetadata.load_variable if CwMetadata.respond_to?(:load_variable)
            end
            ContextLog.info "[I] Thread communication configs updated"
          end

          DaFunk::EventListener.check(:payment_channel)
          unless @connected
            DaFunk::EventListener.check(:communication)
            DaFunk::EventListener.check(:file_exists)
            DaFunk::EventListener.check(:background_system_update)
            DaFunk::EventListener.check(:schedule)
            DaFunk::Helper::StatusBar.check
            Context::ThreadScheduler.execute
          end

          @connected = DaFunk::PaymentChannel.current&.connected?
          if buf = Context::ThreadChannel.read(:send, 0)
            DaFunk::PaymentChannel.connect(false) unless @connected
            DaFunk::PaymentChannel.current.write(buf)
          end
        else
          DaFunk::Helper::StatusBar.current_signal  = nil
          DaFunk::Helper::StatusBar.current_message = :pause
          DaFunk::Helper::StatusBar.current_media   = nil
        end
        usleep(50_000)
      rescue => e
        ContextLog.exception(e, e.backtrace, "Communication thread loop")
      end
    end
  end

  def self.version
    "3.63.3"
  end
end

