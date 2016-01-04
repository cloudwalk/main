
module PosxmlParser
  class PosxmlSetting
    FILE_PATH         = "./shared/config.dat"
    LICENSE_FILE_PATH = "./shared/license.dat"

    DEFAULT = {
      "nomeaplicativo"                => "",
      "primeiravez"                   => "",
      "tiposcartao"                   => "",
      "retentativas"                  => "",
      "qtdetentativasenvio"           => "",
      "withssl"                       => "",
      "myip"                          => "",
      "mygateway"                     => "",
      "dnsprimario"                   => "",
      "dnssecundario"                 => "",
      "iphost"                        => "",
      "portahost"                     => "",
      "subnet"                        => "",
      "uclmedia"                      => "",
      "uclapn"                        => "",
      "uclapn2"                       => "",
      "uclprotocol"                   => "",
      "uclphoneno"                    => "",
      "uclusername"                   => "",
      "uclusername2"                  => "",
      "uclpassword"                   => "",
      "uclpassword2"                  => "",
      "uclvelocidademodem"            => "",
      "gprs_pin"                      => "",
      "autooffmodem"                  => "",
      "versaoframework"               => "",
      "crcpaginawalkserver"           => "",
      "keypaperfeed"                  => "",
      "keyalpha"                      => "",
      "keypound"                      => "",
      "keystar"                       => "",
      "touchscreen"                   => "",
      "epack"                         => "",
      "uclwifinetwork"                => "",
      "uclwifisecurity"               => "",
      "uclwifikey"                    => "",
      "walkserver3companyname"        => "",
      "timeoutinput"                  => "",
      "iskeytimeout"                  => "",
      "ctls"                          => "",
      "dualsim"                       => "",
      "iso8583transactmessageretries" => "",
      "gprs_comm_tmo"                 => "",
      "dukptslot"                     => "",
      "cw_switch_version"             => "",
      "cw_pos_timezone"               => "",
      "uclreceivetimeout"             => "",
      "usedualsim"                    => "",
      "inputcancel"                   => "",
      "enablevlib"                    => "",
      "enablebypasspinvlib"           => "",
      "notificationSocketTimeout"     => "",
      "brand"                         => "",
      "trackisoformat"                => ""
    }

    DA_FUNK_ALIAS = {
      "nomeaplicativo"                => "funk_api",
      "versaoframework"               => "funk_api",
      "crcpaginawalkserver"           => "funk_api",
      "keypaperfeed"                  => "funk_api",
      "keyalpha"                      => "funk_api",
      "keypound"                      => "funk_api",
      "keystar"                       => "funk_api",
      "timeoutinput"                  => "funk_api",
      "iskeytimeout"                  => "funk_api",
      "sn_terminal"                   => "funk_api",
      # "sn_walk"                       => "", #ignore
      # "inputcancel"                   => "", #ignore
      # "enablevlib"                    => "", #ignore
      # "enablebypasspinvlib"           => "", #ignore
      # "trackisoformat"                => "", #ignore
      # "primeiravez"                   => "", #ignore
      # "tiposcartao"                   => "", #ignore
      # "qtdetentativasenvio"           => "", #ignore
      # "autooffmodem"                  => "", #ignore
      # "epack"                         => "", #ignore
      "myip"                          => "ip",
      "mygateway"                     => "gateway",
      "dnsprimario"                   => "dns1",
      "dnssecundario"                 => "dns2",
      "iphost"                        => "host",
      "portahost"                     => "host_port",
      "subnet"                        => "subnet",
      "uclmedia"                      => "media",
      "uclapn"                        => "apn",
      "uclphoneno"                    => "phone",
      "uclusername"                   => "user",
      "uclpassword"                   => "password",
      "uclvelocidademodem"            => "modem_speed",
      "gprs_pin"                      => "sim_pin",
      "usedualsim"                    => "sim_dual",
      "dualsim"                       => "sim_slot",
      "touchscreen"                   => "touchscreen",
      "uclwifinetwork"                => "essid",
      "uclwifisecurity"               => "authentication",
      "uclwifikey"                    => "password",
      "walkserver3companyname"        => "company_name",
      "gprs_comm_tmo"                 => "attach_gprs_timeout",
      "iso8583transactmessageretries" => "iso8583_send_tries",
      "dukptslot"                     => "crypto_dukpt_slot",
      "cw_switch_version"             => "cw_switch_version",
      "cw_pos_timezone"               => "cw_pos_timezone",
      "uclreceivetimeout"             => "tcp_recv_timeout",
      "notificationSocketTimeout"     => "notification_socket_timeout",
      "ctls"                          => "ctls",
      "brand"                         => "brand",
      "retentativas"                  => "attach_tries",
      "model"                         => "model",
      "numerodestepos"                => "logical_number"
    }

    LICENSE_DEFAULT = {
      "sn_walk"        => "",
      "numerodestepos" => "",
      "sn_terminal"    => "",
      "model"          => ""
    }

    # TODO Scalone implement
    def self.set_funk_api(parameter, value)
      case parameter
      when "nomeaplicativo"
        # Nothing
      when "versaoframework"
        # Nothing
      when "timeoutinput"
        Device::IO.timeout = value.to_i
      when "iskeytimeout"
        # Nothing
      # when "sn_terminal" # ignore
      # when "crcpaginawalkserver"
      # when "keypaperfeed"
      # when "keyalpha"
      # when "keypound"
      # when "keystar"
      else
        nil
      end
    end

    # TODO Scalone implement
    def self.get_funk_api(parameter)
      case parameter
      when "nomeaplicativo"
        Device::System.app
      when "versaoframework"
        Device.version
      when "timeoutinput"
        Device::IO.timeout
      when "iskeytimeout"
        return "0" if Device::IO.timeout > 0
        "1"
      when "sn_terminal"
        Device::System.serial
      # when "crcpaginawalkserver"
      # when "keypaperfeed"
      # when "keyalpha"
      # when "keypound"
      # when "keystar"
      else
        nil
      end
    end

    def self.setup
      @file    = FileDb.new(FILE_PATH, DEFAULT)
      @license = FileDb.new(LICENSE_FILE_PATH, LICENSE_DEFAULT)
    end

    def self.set(parameter, value)
      self.set_posxml(parameter, set_funk(parameter, value))
    end

    def self.get(parameter)
      self.set_posxml(parameter, get_funk(parameter))
      self.get_posxml(parameter)
    end

    def self.get_funk(parameter)
      if (alias_parameter = DA_FUNK_ALIAS[parameter])
        begin
          if alias_parameter == "funk_api"
            self.get_funk_api(parameter)
          else
            Device::Setting.send(alias_parameter)
          end
        rescue
        end
      end
    end

    def self.set_funk(parameter, value)
      if (alias_parameter = DA_FUNK_ALIAS[parameter])
        begin
          if alias_parameter == "funk_api"
            self.set_funk_api(parameter, value)
          else
            Device::Setting.send("#{alias_parameter}=", value)
          end
        rescue
        end
      end
    end

    def self.get_posxml(parameter)
      if LICENSE_DEFAULT[parameter]
        @license[parameter]
      else
        @file[parameter]
      end
    end

    def self.set_posxml(parameter, value)
      if value
        if LICENSE_DEFAULT[parameter]
          @license[parameter] = value
        else
          @file[parameter]    = value
        end
      end
    end

    def self.method_missing(method, *args, &block)
      setup unless @file
      param = method.to_s
      if get_posxml(param)
        self.get(param)
      elsif (param[-1..-1] == "=")
        self.set(param[0..-2], args.first)
      else
        super
      end
    end
  end
end

