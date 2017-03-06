class MediaConfiguration
  include Device::Helper

  WIFI_AUTHENTICATION_OPTIONS = {
    "None"         => Device::Network::AUTH_NONE_OPEN,
    "WEP"          => Device::Network::AUTH_NONE_WEP,
    "WEP Shared"   => Device::Network::AUTH_NONE_WEP_SHARED,
    "WPA PSK"      => Device::Network::AUTH_WPA_PSK,
    "WPA/WPA2 PSK" => Device::Network::AUTH_WPA_WPA2_PSK,
    "WPA2 PSK"     => Device::Network::AUTH_WPA2_PSK
  }

  WIFI_CIPHERS_OPTIONS = {
    "None"    => Device::Network::PARE_CIPHERS_NONE,
    "WEP 64"  => Device::Network::PARE_CIPHERS_WEP64,
    "WEP 128" => Device::Network::PARE_CIPHERS_WEP128,
    "CCMP"    => Device::Network::PARE_CIPHERS_CCMP,
    "TKIP"    => Device::Network::PARE_CIPHERS_TKIP
  }

  WIFI_MODE_OPTIONS = {
    "IBSS (Ad-hoc)" => Device::Network::MODE_IBSS,
    "Station (AP)"  => Device::Network::MODE_STATION
  }

  def self.wifi
    ret = menu(I18n.t(:scan_wifi), {I18n.t(:yes) => true, I18n.t(:no) => false})
    return if ret.nil?
    if ret
      Device::Display.clear
      I18n.pt(:scanning)
      Device::Setting.media = Device::Network::MEDIA_WIFI
      aps = Device::Network.scan
      selection = aps.inject({}) do |selection, hash|
        selection[hash[:essid]] = hash; selection
      end
      if selected = menu(I18n.t(:select_ssid), selection)
        selected[:cipher] ||= Device::Network::PARE_CIPHERS_TKIP
        if menu(I18n.t(:add_password), {I18n.t(:yes) => true, I18n.t(:no) => false})
          selected[:password] = form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.password)
        else
          selected[:password] = ""
        end
        self.persist_communication(selected)
      else
        return
      end
    else
      self.persist_communication({
        :authentication => menu(I18n.t(:authentication), WIFI_AUTHENTICATION_OPTIONS, default: Device::Setting.authentication),
        :essid          => form("ESSID", :min => 0, :max => 127, :default => Device::Setting.essid),
        :password       => form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.password),
        :channel        => form("CHANNEL", :min => 0, :max => 127, :default => Device::Setting.channel),
        :cipher         => menu("CIPHER", WIFI_CIPHERS_OPTIONS, default: Device::Setting.cipher),
        :mode           => menu("MODE", WIFI_MODE_OPTIONS, default: Device::Setting.mode),
        :media          => Device::Network::MEDIA_WIFI
      })
    end
  end

  def self.gprs
    apn      = form("APN", :min => 0, :max => 127, :default => Device::Setting.apn)
    user     = form("USER", :min => 0, :max => 127, :default => Device::Setting.user)
    password = form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.password)

    self.persist_communication({
      :apn => apn, :user => user, :password => password,
      "media" => Device::Network::MEDIA_GPRS
    })
  end

  def self.persist_communication(config)
    ContextLog.info config.inspect
    if menu(I18n.t(:media_try_connection), {I18n.t(:yes) => true, I18n.t(:no) => false})
      Device::Display.clear
      I18n.pt(:media_check_connection)
      if Device::Network.connected? == 0
        Device::Network.disconnect
        Device::Network.power(0)
      end
      Device::Setting.update_attributes(config)
      Device::Setting.network_configured = "1"
      Device::Setting.network_configured = "0" unless attach
    else
      Device::Setting.update_attributes(config)
      Device::Setting.network_configured = "1"
    end
  end
end

