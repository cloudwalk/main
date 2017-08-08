class PaymentChannel
  DEFAULT_HEARBEAT = "180"
  class << self
    attr_accessor :client
  end
  attr_reader :client, :host, :port, :handshake_response

  def self.ready?
    Device::Network.connected? && Device::ParamsDat.file["access_token"] &&
      Device::ParamsDat.file["payment_channel_enabled"] == "1" &&
      Device::Setting.logical_number
  end

  def self.handshake_message
    {
      "token"     => Device::ParamsDat.file["access_token"],
      "id"        => Device::Setting.logical_number.to_s,
      "heartbeat" => Device::Setting.heartbeat || DEFAULT_HEARBEAT
    }.to_json
  end

  def self.handshake_success_message
    {"token" => Device::ParamsDat.file["access_token"]}.to_json
  end

  def self.connect(display_message = true)
    if self.dead? && self.ready?
      self.print_info(I18n.t(:attach_attaching), display_message)
      @client = PaymentChannel.new
      self.print_info(I18n.t(:attach_authenticate), display_message)
      @client.handshake
    end
    @client
  end

  def self.error
    if ConnectionManagement.fallback?
      :fallback_communication
    elsif ConnectionManagement.conn_automatic_management?
      :attach_registration_fail
    end
  end

  def self.check(display_message = true)
    if self.dead?
      PaymentChannel.connect(display_message)
      if @client
        self.print_info(I18n.t(:attach_waiting), display_message)
        if message = @client.check
          self.print_info(I18n.t(:attach_connected), display_message)
          message
        else
          self.error
        end
      else
        self.error
      end
    else
      if @client
        @client.check
      end
    end
  end

  def self.dead?
    ! self.alive?
  end

  def self.alive?
    Device::Network.connected? && @client && @client.connected?
  end

  def self.print_info(message, display = true)
    print_last(message) if display
  end

  def initialize
    @host   = Device::Setting.host
    @port   = (Device::Setting.apn == "gprsnac.com.br") ? 32304 : 443
    @client = CwWebSocket::Client.new(@host, @port)
  end

  def write(value)
    @client.write(value)
  end

  def read
    begin
      @client.read
    rescue SocketError => e
      ContextLog.exception(e, e.backtrace, "PaymentChannel error")
      PaymentChannel.client = nil
      @client = nil
    end
  end

  def close
    @client.close
    @client = nil
    PaymentChannel.client = nil
  end

  def connected?
    self.client && self.client.connected?
  end

  def handshake?
    if self.connected? && ! @handshake_response
      @handshake_response = self.client.read
    end
    !! @handshake_response
  end

  def check
    if Device::Network.connected? && self.connected? && self.handshake?
      message = self.read
    end
    return :primary_communication if message.nil? && ConnectionManagement.primary_try?
    message
  end

  private
  def handshake
    if self.connected?
      @client.write(PaymentChannel.handshake_message)
    end
  end
end

