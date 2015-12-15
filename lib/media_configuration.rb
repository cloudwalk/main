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
    if menu("Scan Wifi?", {"Yes" => true, "No" => false})
      aps = Device::Network.scan
      selection = aps.inject({}) do |selection, hash|
        selection[hash[:essid]] = hash; selection
      end
      selected = menu("Select SSID:", selection)

      Device::Setting.password       = form("Password", :min => 0, :max => 127, :default => Device::Setting.password)
      Device::Setting.authentication = selected[:authentication]
      Device::Setting.essid          = selected[:essid]
      Device::Setting.channel        = selected[:channel]
      Device::Setting.cipher         = selected[:cipher]
      Device::Setting.mode           = selected[:mode]
    else
      Device::Setting.authentication = menu("Authentication", WIFI_AUTHENTICATION_OPTIONS, default: Device::Setting.authentication)
      Device::Setting.essid          = form("Essid", :min => 0, :max => 127, :default => Device::Setting.essid)
      Device::Setting.password       = form("Password", :min => 0, :max => 127, :default => Device::Setting.password)
      Device::Setting.channel        = form("Channel", :min => 0, :max => 127, :default => Device::Setting.channel)
      Device::Setting.cipher         = menu("Cipher", WIFI_CIPHERS_OPTIONS, default: Device::Setting.cipher)
      Device::Setting.mode           = menu("Mode", WIFI_MODE_OPTIONS, default: Device::Setting.mode)
    end

    Device::Setting.media = Device::Network::MEDIA_WIFI
  end

  def self.gprs
    Device::Setting.media    = Device::Network::MEDIA_GPRS
    Device::Setting.apn      = form("Apn", :min => 0, :max => 127, :default => Device::Setting.apn)
    Device::Setting.user     = form("User", :min => 0, :max => 127, :default => Device::Setting.user)
    Device::Setting.password = form("Password", :min => 0, :max => 127, :default => Device::Setting.password)
  end
end
