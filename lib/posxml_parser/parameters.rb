module PosxmlParser
  module Parameters
    CONFIG_FILE = "config.dat"
    DEFAULT     = {
      "ipHost"                 => nil,
      "portaHost"              => nil,
      "serialFrameworkWalk"    => nil,
      "nomeAplicativo"         => nil,
      "numeroLogico"           => nil,
      "tiposCartao"            => nil,
      "qtdeTentativasEnvio"    => nil,
      "serialTerminal"         => nil,
      "model"                  => nil,
      "withSSL"                => nil,
      "myIp"                   => nil,
      "myGateway"              => nil,
      "dnsPrimario"            => nil,
      "dnsSecundario"          => nil,
      "subnet"                 => nil,
      "walkServer3CompanyName" => nil,
      "timeoutInput"           => nil,
      "executingAppName"       => nil,
      "isKeyTimeout"           => nil,
      "workingKey"             => nil,
      "version"                => nil
    }

    STATIC = {
      "ipHost"    => "switch-staging.cloudwalk.io",
      "portaHost" => "31415",
      "version"   => PosxmlParser::VERSION
    }

    def posxml_write_memory_paramter(file_name, key, value)
      if file_name == PosxmlParser::Parameters::CONFIG_FILE
        @posxml_config_dat[key] = value
      end
    end

    def posxml_read_memory_parameter(file_name, key)
      if file_name == PosxmlParser::Parameters::CONFIG_FILE
        @posxml_config_dat[key]
      end
    end

    def posxml_initialize_parameters
      @posxml_config_dat = PosxmlParser::Parameters::DEFAULT.merge(PosxmlParser::Parameters::STATIC)
      @posxml_config_dat.each do |key, value|
        @posxml_config_dat[key] = posxml_read_db_config(key)
      end
    end
  end
end

