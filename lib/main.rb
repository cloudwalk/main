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
    when :status_bar
      self.thread_status_bar
    when :communication
      self.thread_communication
    when :apps_update
      AdminConfiguration.apps_update
    when :system_update
      AdminConfiguration.system_update
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
      InputTransactionAmount.display if InputTransactionAmount.enabled?
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
      elsif options["initialize"] == "status_bar"
        :status_bar
      elsif options["initialize"] == "communication"
        :communication
      elsif options["initialize"] == "apps_update"
        :apps_update
      elsif options["initialize"] == "system_update"
        :system_update
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
  end

  def self.thread_status_bar
    id = Context::ThreadPubSub.subscribe
    time = nil
    loop do
      break if ThreadScheduler.die?(:status_bar)
      DaFunk::Helper::StatusBar.check
      if Context::ThreadPubSub.listen(id) == "communication_update"
        Device::Runtime.system_reload
      end

      if time.nil? || time < Time.now
        time = (Time.now + 600)
        GC.start
      end
      usleep(1000_000)
    end
  end

  def self.thread_communication
    DaFunk::PaymentChannel.client = nil
    begin
      id = Context::ThreadPubSub.subscribe
      attach(print_last: false) if Device::Network.configured?
      CloudwalkSetup.setup_communication_listeners
      loop do
        break if ThreadScheduler.die?(:communication)
        if (! ThreadScheduler.pause?(:communication))
          if Context::ThreadPubSub.listen(id) == "communication_update"
            media_before = Device::Network.config
            Device::Runtime.system_reload
            media_after = Device::Network.config
            DaFunk::PaymentChannel.close! if media_before != media_after
          end
          DaFunk::EventListener.check(:communication)
          DaFunk::EventListener.check(:payment_channel)
          Context::ThreadScheduler.execute(ThreadScheduler::THREAD_COMMUNICATION)

          if buf = Context::ThreadChannel.queue_read(ThreadScheduler::THREAD_COMMUNICATION)
            DaFunk::PaymentChannel.connect(false) unless (DaFunk::PaymentChannel.client && DaFunk::PaymentChannel.client.connected?)
            DaFunk::PaymentChannel.client.write(buf)
          end
        end
        usleep(50_000)
      end
    rescue => e
      ContextLog.exception(e, e.backtrace, "Communication thread")
    end
  end

  def self.version
    "3.22.0"
  end
end

