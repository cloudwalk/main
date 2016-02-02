class AdminConfiguration
  include Device::Helper

  def self.perform
    Device::Display.clear
    Device::Display.print("ADMIN PASSWORD:", 0, 0)
    password = Device::IO.get_format(1, 5, options = {:mode => :secret})

    if password == "55555"
      main_menu
    else
      Device::Display.clear
      Device::Display.print("INCORRECT PASSWORD", 1, 0)
      getc
      true
    end
  end

  def self.main_menu
    selected = menu(nil, {
      "LOGICAL NUMBER"     => :logical_number,
      "COMMUNICATION"      => :communication,
      "MAGSTRIPE SETTINGS" => :magstripe,
      "CHECK S. NUMBER"    => :serial_number,
      "CLEAR THIS DEVICE"  => :clear,
      "CLOUDWALK UPDATE"   => :update,
      "ABOUT"              => :about,
    })

    self.send(selected) if selected
  end

  def self.logical_number
    Device::Setting.logical_number = form("Logical Number", :min => 0,
                                          :max => 127, :default => Device::Setting.logical_number)
  end

  def self.communication
    if menu("COMMUNICATION MENU:", {"CONFIGURE" => true, "SHOW" => false})
      communication_configure
    else
      communication_show
    end
  end

  def self.communication_show
    if Device::Network.connected? == 0
      show = "STATUS: Connected"
    else
      show = "STATUS: Disconnected"
    end

    if Device::Setting.media == Device::Network::MEDIA_WIFI
      show << "\nAUTH: #{Device::Setting.authentication}"
      show << "\nESSID: #{Device::Setting.essid}"
      show << "\nCHANNEL: #{Device::Setting.channel}"
      show << "\nCHIPER: #{Device::Setting.cipher}"
      getc
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
    media = menu("Select Media:", {"WIFI" => :wifi, "GPRS" => :gprs})
    if media == :wifi
      ret = MediaConfiguration.wifi
    elsif media == :gprs
      ret = MediaConfiguration.gprs
    end

    Device::Setting.network_configured = "1" if ret
  end

  def self.magstripe
  end

  def self.clear
    Device::Display.clear
    I18n.pt(:question_clear)
    if getc == Device::IO::ENTER
      Device::ParamsDat.parse
      Device::ParamsDat.format!
    end
  end

  def self.update
    if attach
      Device::ParamsDat.update_apps
    end
  end

  def self.serial_number
    Device::Display.clear
    puts "SERIAL NUMBER:\n\n#{Device::System.serial}"
    getc
  end

  def self.about
    show = "ABOUT\n"
    show << "\nAPI: #{Device.api_version}"
    show << "\nFRAMEWORK: #{Device.version}"
    show << "\nAPPLICATION: #{Main.version}"
    Device::Display.clear
    puts show
    if getc == Device::IO::F2
      keys = Device::IO.get_format(1, 6, options = {:mode => :secret})
      if keys == "999999"
        env = menu("SELECT:", {
          "PRODUCTION" => :to_production!,
          "STAGING"    => :to_staging!
        })
        restart if Device::Setting.send(env)
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
    year   = form("Input the year:"       , :min => 0 , :max => 4 , :default => Time.now.year)
    month  = form("Input the month:"      , :min => 0 , :max => 2 , :default => Time.now.month)
    day    = form("Input the day:"        , :min => 0 , :max => 2 , :default => Time.now.day)
    hour   = form("Input the hour:"       , :min => 0 , :max => 2 , :default => Time.now.hour)
    minute = form("Input the minutes:"    , :min => 0 , :max => 2 , :default => Time.now.min)
    second = form("Input the seconds:"    , :min => 0 , :max => 4 , :default => Time.now.sec)
    Time.new(year,month,day,hour,minute,second).hwclock
  end
end

