class Cloudwalk
  include Device::Helper


  def self.boot
    if Device::Network.configured?
      if attach
        Device::Notification.start
      end
    end
  end

  def self.start
    if application = Device::ParamsDat.executable_app
      application.execute
    elsif Device::ParamsDat.apps.size > 1
      application = Device::ParamsDat.application_menu
      application.execute if application
    else
      self.wizard
    end
  end

  def self.wizard
    self.logical_number
    self.communication
    if Device::ParamsDat.update_apps
      Device::Notification.start
      Device::ParamsDat.application_menu.execute
    end
  end

  def self.logical_number
    Device::Setting.logical_number = form("Logical Number", :min => 0,
                                          :max => 127, :default => Device::Setting.logical_number)
  end

  def self.communication
    configure = menu("Would like to configure communication?",
                     {"Yes" => true, "No" => false})
    if (configure)
      media = menu("Select Media:", {"WIFI" => :wifi, "GPRS" => :gprs})
      if media == :wifi
        MediaConfiguration.wifi
      elsif media == :gprs
        MediaConfiguration.gprs
      end

      Device::Setting.network_configured = "1"
    end
  end

  def self.set_wifi_config
    #WIFI
    Device::Setting.media          = Device::Network::MEDIA_WIFI
    Device::Setting.mode           = Device::Network::MODE_STATION

    #Device::Setting.authentication = Device::Network::AUTH_WPA_WPA2_PSK
    #Device::Setting.cipher         = Device::Network::PARE_CIPHERS_CCMP
    #Device::Setting.password       = "desgracapelada"
    #Device::Setting.essid          = "Barril do Chaves"
    #Device::Setting.channel        = "0"

    # WIFI Office
    Device::Setting.authentication = Device::Network::AUTH_WPA_WPA2_PSK
    Device::Setting.cipher         = Device::Network::PARE_CIPHERS_TKIP
    Device::Setting.password       = "cloudwalksemfio"
    Device::Setting.essid          = "CloudWalk"
    Device::Setting.channel        = "0"

    #GPRS
    #Device::Setting.mode           = Network::MEDIA_GPRS
    #Device::Setting.logical_number = "1"
    #Device::Setting.apn            = "zap.vivo.com.br"
    #Device::Setting.user           = "vivo"
    #Device::Setting.pass           = "vivo"
    Device::Setting.network_configured = "1"
  end
end
