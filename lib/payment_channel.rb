class PaymentChannel
  DEFAULT_HEARBEAT = "180"
  class << self
    attr_reader :client
  end
  attr_reader :client, :host, :port, :handshake_response

  def self.ready?
    Device::ParamsDat.file["check_sum"] && Device::Setting.logical_number
  end

  def self.handshake_message
    {
      "token"     => Device::ParamsDat.file["check_sum"],
      "id"        => Device::Setting.logical_number.to_s,
      "heartbeat" => Device::Setting.heartbeat || DEFAULT_HEARBEAT
    }.to_json
  end

  def self.handshake_success_message
    {"token" => Device::ParamsDat.file["check_sum"]}.to_json
  end

  def self.client
    if self.dead? && self.ready?
      @client = PaymentChannel.new
    end
    @client
  end

  def self.check
    PaymentChannel.client if self.dead?
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
    @client.read
  end

  def close
    @client.close
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
    if self.connected? && self.handshake?
      self.client.read
    end
  end

  private
  def handshake
    if self.connected?
      @client.write(PaymentChannel.handshake_message)
    end
  end
end

