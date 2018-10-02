require 'posxml_parser'
require 'funky-emv'
require "funky-simplehttp"

class Main < Device
  include DaFunk::Helper

  def self.call(json = nil)
    DaFunk::PaymentChannel.client = Context::CommunicationChannel
    case self.execute(json)
    when :admin_configuration
      AdminConfiguration.perform
    when :admin_communication
      AdminConfiguration.communication
    when :status_bar
      self.thread_status_bar
    when :communication
      self.thread_communication
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
    unless json
      :normal
    else
      if (hash = JSON.parse(json)) && hash["initialize"] == "admin_configuration"
        :admin_configuration
      elsif (hash = JSON.parse(json)) && hash["initialize"] == "admin_communication"
        :admin_communication
      elsif (hash = JSON.parse(json)) && hash["initialize"] == "status_bar"
        :status_bar
      elsif (hash = JSON.parse(json)) && hash["initialize"] == "communication"
        :communication
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
    loop do
      break if ThreadScheduler.die?(:status_bar)
      DaFunk::Helper::StatusBar.check
      usleep(400_000)
    end
  end

  def self.thread_communication
    DaFunk::PaymentChannel.client = nil
    begin
      attach(false) if Device::Network.configured?
      # TODO Scalone: how to fix notification?
      CloudwalkSetup.setup_communication_listeners
      loop do
        break if ThreadScheduler.die?(:communication)
        DaFunk::EventListener.check(:payment_channel)
        Context::ThreadScheduler.execute(ThreadScheduler::THREAD_COMMUNICATION)

        if buf = Context::ThreadChannel.queue_read(ThreadScheduler::THREAD_COMMUNICATION)
          DaFunk::PaymentChannel.client.write(buf)
        end
        usleep(50_000)
      end
    rescue => e
      ContextLog.exception(e, e.backtrace, "ERRROU")
    end
  end

  def self.version
    "1.87.0"
  end
end

