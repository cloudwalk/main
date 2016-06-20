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
    Device::Setting.media = Device::Network::MEDIA_WIFI
    ret = menu(I18n.t(:scan_wifi), {I18n.t(:yes) => true, I18n.t(:no) => false})
    return if ret.nil?
    if ret
      Device::Display.clear
      I18n.pt(:scanning)
      aps = Device::Network.scan
      selection = aps.inject({}) do |selection, hash|
        selection[hash[:essid]] = hash; selection
      end
      if selected = menu(I18n.t(:select_ssid), selection)
        Device::Setting.authentication = selected[:authentication]
        Device::Setting.essid          = selected[:essid]
        Device::Setting.channel        = selected[:channel]
        Device::Setting.cipher         = selected[:cipher] || Device::Network::PARE_CIPHERS_TKIP
        Device::Setting.mode           = selected[:mode]
        if menu(I18n.t(:add_password), {I18n.t(:yes) => true, I18n.t(:no) => false})
          Device::Setting.password = form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.password)
        else
          Device::Setting.password = ""
        end
      else
        return
      end
    else
      Device::Setting.authentication = menu(I18n.t(:authentication), WIFI_AUTHENTICATION_OPTIONS, default: Device::Setting.authentication)
      Device::Setting.essid          = form("ESSID", :min => 0, :max => 127, :default => Device::Setting.essid)
      Device::Setting.password       = form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.password)
      Device::Setting.channel        = form("CHANNEL", :min => 0, :max => 127, :default => Device::Setting.channel)
      Device::Setting.cipher         = menu("CIPHER", WIFI_CIPHERS_OPTIONS, default: Device::Setting.cipher)
      Device::Setting.mode           = menu("MODE", WIFI_MODE_OPTIONS, default: Device::Setting.mode)
    end
  end

  def self.gprs
    apn      = form("APN", :min => 0, :max => 127, :default => Device::Setting.apn)
    user     = form("USER", :min => 0, :max => 127, :default => Device::Setting.user)
    password = form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.password)

    Device::Setting.update_attributes(
      "apn" => apn, "user" => user, "password" => password,
      "media" => Device::Network::MEDIA_GPRS)
  end
end
