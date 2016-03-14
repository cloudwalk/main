class AdminConfiguration
  include Device::Helper

  def self.perform
    Device::Display.clear
    I18n.pt(:admin_password)
    if "55555" == Device::IO.get_format(1, 10, options = {:mode => :secret})
      main_menu
    else
      Device::Display.clear
      I18n.pt(:admin_password_invalid)
      getc
      true
    end
  end

  def self.main_menu
    selected = menu(nil, {
      I18n.t(:admin_logical_number) => :logical_number,
      I18n.t(:admin_communication)  => :communication,
      I18n.t(:admin_magstripe)      => :magstripe,
      I18n.t(:admin_serial_number)  => :serial_number,
      I18n.t(:admin_clear)          => :clear,
      I18n.t(:admin_update)         => :update,
      I18n.t(:admin_about)          => :about,
    })

    self.send(selected) if selected
  end

  def self.logical_number
    Device::Setting.logical_number = form(
      I18n.t(:admin_logical_number), :min => 0,
      :max => 127, :default => Device::Setting.logical_number)
  end

  def self.communication
    if menu(I18n.t(:admin_communication), { I18n.t(:admin_configure) => true,
              I18n.t(:admin_show) => false })
      communication_configure
    else
      communication_show
    end
  end

  def self.communication_show
    if (ret = Device::Network.connected?) == 0
      show = I18n.t(:attach_connected)
    else
      show = I18n.t(:attach_fail, :args => ret)
    end

    if Device::Setting.media == Device::Network::MEDIA_WIFI
      show << "\nAUTH: #{Device::Setting.authentication}"
      show << "\nESSID: #{Device::Setting.essid}"
      show << "\nCHANNEL: #{Device::Setting.channel}"
      show << "\nCHIPER: #{Device::Setting.cipher}"
    else
      show << "\nAPN: #{Device::Setting.apn}"
      show << "\nUSER: #{Device::Setting.user}"
      show << "\nPW: #{Device::Setting.password}"
    end

    Device::Display.clear
    puts show
    getc
  end

  def self.communication_configure
    media = menu(I18n.t(:admin_select_media), {"WIFI" => :wifi, "GPRS" => :gprs})
    if media == :wifi
      ret = MediaConfiguration.wifi
    elsif media == :gprs
      ret = MediaConfiguration.gprs
    end

    Device::Setting.network_configured = "1" if ret
  end

  def self.magstripe
    hash = {
      1 => "0".chr,
      2 => "2".chr,
      3 => "4".chr,
      4 => "255".chr
    }
    selection = {
      "T2/DIGIT/SWIPE"    => 1,
      "T2/SWIPE ONLY"     => 2,
      "T1/T2/DIGIT/SWIPE" => 3,
      "T1/T2/SWIPE ONLY"  => 4
    }
    options = {
      :default => hash.invert[PosxmlParser::PosxmlSetting.tiposcartao]
    }
    value = menu(I18n.t(:admin_magstripe), selection, options)
    PosxmlParser::PosxmlSetting.tiposcartao = hash[value]
  end

  def self.clear
    Device::Display.clear
    I18n.pt(:admin_question_clear)
    if getc == Device::IO::ENTER
      Device::ParamsDat.parse
      Device::ParamsDat.format!
    end
  end

  def self.update
    Device::ParamsDat.update_apps if attach
  end

  def self.serial_number
    Device::Display.clear
    puts "#{I18n.t(:admin_serial_number)}:\n\n#{Device::System.serial}"
    getc
  end

  # TODO Refactoring locale
  def self.about
    show = "#{I18n.t(:admin_about)}\n"
    show << "\nI18n: #{I18n.locale}"
    show << "\nAPI: #{DaFunk::VERSION}"
    show << "\nFRAMEWORK: #{Device.version}"
    show << "\nAPPLICATION: #{Main.version}"
    Device::Display.clear
    puts show
    if getc == Device::IO::F2
      password = Device::IO.get_format(1, 6, options = {:mode => :secret})
      if password == "999999"
        env = menu("SELECT:", {
          "PRODUCTION" => :to_production!,
          "STAGING"    => :to_staging!
        })
        restart if env && Device::Setting.send(env)
      elsif password == "888888"
        if locale = menu("SELECT:", I18n.hash.keys)
          I18n.locale = locale
          Device::Setting.locale = locale
        end
      elsif password == "777777"
        DaFunk::Engine.stop!
      end
    end
  end

  def self.restart
    Device::Display.clear
    3.times do |i|
      Device::Display.print("REBOOTING IN #{3 - i}",3,3)
      sleep(1)
    end
    Device::System.restart
  end

  def self.change_hour
    year   = form("INPUT THE YEAR:"       , :min => 0 , :max => 4 , :default => Time.now.year)
    month  = form("INPUT THE MONTH:"      , :min => 0 , :max => 2 , :default => Time.now.month)
    day    = form("INPUT THE DAY:"        , :min => 0 , :max => 2 , :default => Time.now.day)
    hour   = form("INPUT THE HOUR:"       , :min => 0 , :max => 2 , :default => Time.now.hour)
    minute = form("INPUT THE MINUTES:"    , :min => 0 , :max => 2 , :default => Time.now.min)
    second = form("INPUT THE SECONDS:"    , :min => 0 , :max => 4 , :default => Time.now.sec)
    Time.new(year,month,day,hour,minute,second).hwclock
  end
end

