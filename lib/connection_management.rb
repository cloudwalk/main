class ConnectionManagement
  class << self
    attr_accessor :drops, :primary_timeout
  end
  self.drops = 0
  DEFAULT_DROP_LIMIT = 2

  def self.fallback?
    if ! Device::Network.connected? && self.fallback_valid? && self.conn_automatic_management? &&
      Device::Setting.media_primary == Device::Setting.media
      self.drops += 1
      if self.drops >= self.conn_fallback_drops_limit
        return true
      end
    end
    false
  end

  def self.conn_automatic_management?
    Device::ParamsDat.file["connection_management"] != "0"
  end

  def self.conn_fallback_drops_limit
    value = Device::ParamsDat.file["conn_fallback_drops_limit"]
    if value && ! value.empty?
      value.to_i
    else
      DEFAULT_DROP_LIMIT
    end
  end

  def self.conn_fallback_config
    value = Device::ParamsDat.file["conn_fallback_config"]
    if value && !value.empty?
      value
    end
  end

  def self.conn_fallback_timer
    value = Device::ParamsDat.file["conn_fallback_timer"]
    if value && ! value.empty?
      return value.to_i
    end
    0
  end

  class << self
    alias :config :conn_fallback_config
  end

  def self.primary_try?
    if ! Device::Setting.media_primary.to_s.empty? && Device::Setting.media_primary != Device::Setting.media
      if self.primary_timeout.nil?
        self.schedule_primary_timeout
      else
        if Time.now > self.primary_timeout
          self.schedule_primary_timeout
          return true
        end
      end
    end
    false
  end

  def self.fallback_valid?
    self.conn_fallback_config && self.conn_fallback_timer &&
      (self.config.include?("WIFI") || self.config.include?("GPRS"))
  end

  def self.recover_fallback
    if self.fallback_valid?
      self.schedule_primary_timeout
      media, parameters = self.conn_fallback_config.to_s.split("|", 2)

      if media ==  "WIFI"
        # WIFI|uclwifinetwork|uclwifisecurity|uclwifichannel|uclwifikey
        essid, authentication, channel, password = parameters.split("|")
        configuration = {
          :network_configured => "1",
          :authentication     => authentication,
          :essid              => essid,
          :wifi_password      => password,
          :channel            => channel,
          :cipher             => Device::Network::PARE_CIPHERS_TKIP,
          :mode               => Device::Network::MODE_STATION,
          :media              => Device::Network::MEDIA_WIFI
        }
        # elsif TODO # ETHERNET|DHCP
      else
        # GPRS|APN|USER|PASSWORD
        apn, user, password = parameters.split("|")
        configuration = {
          :network_configured => "1",
          :apn                => apn,
          :user               => user,
          :apn_password       => password,
          :media              => Device::Network::MEDIA_GPRS
        }
      end
      Device::Setting.update_attributes(configuration)
    end
  end

  def self.recover_primary
    Device::Setting.update_attributes({media: Device::Setting.media_primary})
  end

  private
  def self.schedule_primary_timeout
    self.primary_timeout = (Time.now + self.conn_fallback_timer)
  end
end

