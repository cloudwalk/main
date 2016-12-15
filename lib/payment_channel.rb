class PaymentChannel
  DEFAULT_HEARBEAT = "180"
  class << self
    attr_accessor :client
  end
  attr_reader :client, :host, :port, :handshake_response

  def self.ready?
    Device::Network.connected? == 0 && Device::ParamsDat.file["access_token"] &&
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

  def self.connect
    if self.dead? && self.ready?
      @client = PaymentChannel.new
    end
    @client
  end

  def self.check
    PaymentChannel.connect if self.dead?
    @client.check if @client
  end

  def self.dead?
    ! self.alive?
  end

  def self.alive?
    @client && @client.connected?
  end

  def initialize
    @host   = Device::Setting.host
    @port   = (Device::Setting.apn == "gprsnac.com.br") ? 32304 : 443
    @client = CwWebSocket::Client.new(@host, @port)

    self.handshake
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
    if Device::Network.connected? == 0 && self.connected? && self.handshake?
      self.read
    end
  end

  private
  def handshake
    if self.connected?
      @client.write(PaymentChannel.handshake_message)
    end
  end
end

