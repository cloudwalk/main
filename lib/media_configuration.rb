class MediaConfiguration
  include DaFunk::Helper

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

  CW_APNS_FILE = "./shared/cw_apns.dat"

  def self.wifi
    ThreadScheduler.pausing_communication do
      ret = menu(I18n.t(:scan_wifi), {I18n.t(:yes) => true, I18n.t(:no) => false})
      return if ret.nil?
      if ret
        Device::Display.clear
        I18n.pt(:scanning)
        Device::Network.shutdown
        Device::Setting.media = Device::Network::MEDIA_WIFI
        DaFunk::Helper::StatusBar.check
        aps = Device::Network.scan
        selection = aps.inject({}) do |selection, hash|
          selection[hash[:essid]] = hash; selection
        end

        if selected = menu(I18n.t(:select_ssid), selection)
          selected[:cipher] ||= Device::Network::PARE_CIPHERS_TKIP
          selected[:media_primary] = Device::Network::MEDIA_WIFI
          if menu(I18n.t(:add_password), {I18n.t(:yes) => true, I18n.t(:no) => false})
            selected[:wifi_password] = form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.wifi_password)
          else
            selected[:wifi_password] = ""
          end
          self.persist_communication(selected)
        else
          return
        end
      else
        self.persist_communication({
          :authentication => menu(I18n.t(:authentication), WIFI_AUTHENTICATION_OPTIONS, default: Device::Setting.authentication),
          :essid          => form("ESSID", :min => 0, :max => 127, :default => Device::Setting.essid),
          :wifi_password  => form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.wifi_password),
          :channel        => form("CHANNEL", :min => 0, :max => 127, :default => Device::Setting.channel),
          :cipher         => menu("CIPHER", WIFI_CIPHERS_OPTIONS, default: Device::Setting.cipher),
          :mode           => menu("MODE", WIFI_MODE_OPTIONS, default: Device::Setting.mode),
          :media          => Device::Network::MEDIA_WIFI,
          :media_primary  => Device::Network::MEDIA_WIFI
        })
      end
    end
    Context::ThreadPubSub.publish('communication_update')
  end

  def self.gprs
    ThreadScheduler.pausing_communication do
      if File.exists?(CW_APNS_FILE)
        apn, user, password = self.gprs_menu
      else
        apn, user, password = self.gprs_manual
      end

      self.persist_communication({
        :apn => apn, :user => user, :apn_password => password,
        :media => Device::Network::MEDIA_GPRS,
        :media_primary => Device::Network::MEDIA_GPRS
      })
    end
    Context::ThreadPubSub.publish('communication_update')
  end

  def self.parse_apn_operators(hash)
    if hash.include?('imsi_name') && hash.include?('imsi_id')
      operators = {}
      hash['imsi_name'].split(';').each_with_index do |item, index|
        operators[item] = hash['imsi_id'].split(';')[index]
      end
      hash['imsi_name'] = operators
      hash.delete('imsi_id')
    end
    hash
  end

  def self.gprs_menu
    file = FileDb.new(CW_APNS_FILE)
    apns = file.each.inject([]) { |apns, values| apns << parse_apn_line(values[1]) }
    apns = apns.inject([]) { |apns, hash| apns << parse_apn_operators(hash) }
    apns = apns.inject({}) {|hash, apn| hash[apn[check_apn("name")]] = apn; hash}

    input = menu("APNS", apns, default: Device::Setting.apn)
    if input.nil? || input["name"] == "DEFINE_APN" || input["name"] == "DEFINIR_APN"
      self.gprs_manual

    elsif input.include?('imsi_name')
      if menu(I18n.t(:media_select_operator), {I18n.t(:yes) => true, I18n.t(:no) => false})
        imsi_id = menu(I18n.t(:networks), input['imsi_name'], default: Device::Setting.apn)
        unless imsi_id.nil? || imsi_id.empty?
          self.select_network(imsi_id, input["apn"], input["user"], input["password"])
        end
      end
      [input["apn"], input["user"], input["password"]]
    else
      [input["apn"], input["user"], input["password"]]
    end
  end

  def self.select_network(imsi_id, apn, user, password)
    Device::Display.clear
    print_line(I18n.t(:attach_network), 3, 0)

    unless Device::Network.connected?
      Device::Network.init(:gprs, apn: apn, user: user, pass: password)
      Device::Network::Gprs.power(1)
    end

    response = Network::Gprs.select_attach_network(imsi_id)
    Device::Display.clear
    if response.nil? || response[:result] != "OK"
      print_line(I18n.t(:attach_registration_fail).to_s.gsub("%d",'').strip!, 3, 0)
    else
      print_line(I18n.t(:attach_connected), 3, 0)
    end
    getc(3000)
  end

  def self.check_apn(name)
    if name == "DEFINE_APN"
      I18n.t(:admin_define_apn)
    else
      name
    end
  end

  def self.parse_apn_line(txt)
    cleaned_string = txt.to_s.gsub('", "', '","').gsub("\"", "").split(',')
    cleaned_string.inject({}) do |hash, string|
      parts = string.split("=");
      hash[parts[0]] = parts[1]
      hash
    end
  end

  def self.gprs_manual
    [
      form("APN", :min => 0, :max => 127, :default => Device::Setting.apn),
      form("USER", :min => 0, :max => 127, :default => Device::Setting.user),
      form("PASSWORD", :min => 0, :max => 127, :default => Device::Setting.apn_password)
    ]
  end

  def self.persist_communication(config)
    DaFunk::Helper::StatusBar.check
    Device::Display.clear
    I18n.pt(:setup_booting)
    value = menu(I18n.t(:media_try_connection), {I18n.t(:media_reboot) => true,
      I18n.t(:media_connect) => false})

    if value
      Device::Display.clear
      self.configure(config)
      I18n.pt(:admin_communication_success)
      getc(2000)
      Device::System.restart
    else
      Device::Display.clear
      print_last(I18n.t(:media_check_connection))
      Device::Network.shutdown
      self.configure(config)
      if attach
        Device::Display.clear
        I18n.pt(:admin_communication_success)
        getc(2000)
      else
        Device::Setting.network_configured = "0" unless DaFunk::ConnectionManagement.conn_automatic_management?
        getc(0)
      end
    end
  end

  def self.configure(config)
    Device::Setting.update_attributes(config)
    Device::Setting.network_configured = "1"
  end

  def self.gprs_default(options)
    return if Device::Setting.network_configured == '1'

    Device::Network.init(:gprs, options)
    Device::Network::Gprs.power(1)

    if Device::Network.sim_id.to_s[0..3] == '8944'
      options[:apn] = 'hologram'
      options[:user] = 'user'
      options[:pass] = 'pass'

      Device::Network.init(:gprs, options)
      Device::Network::Gprs.power(1)
    end

    unless Device::Network.sim_id.to_s.empty?
      configure(options.merge({
        media: Device::Network::MEDIA_GPRS,
        media_primary: Device::Network::MEDIA_GPRS
      }))
    end
  end
end
