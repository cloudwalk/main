class AdminConfiguration
  include Device::Helper

  def self.perform
    Device::Display.clear
    Device::Display.print("Admin Password:", 0, 0)
    password = Device::IO.get_format(1, 5, options = {:mode => :secret})

    if password == "55555"
      menu
    else
      Device::Display.clear
      Device::Display.print("Incorrect Password", 0, 1)
      getc
      true
    end
  end

  def self.menu
    Device::Display.clear
    Device::Display.print("Configuration Menu", 0, 0)
    Device::Display.print(" 1 - Communication", 1, 0)
    Device::Display.print(" 2 - Update Apps", 2, 0)
    Device::Display.print(" 3 - Logical Number", 3, 0)
    Device::Display.print(" 4 - Set Clock", 4, 0)
    Device::Display.print(" 5 - Show Config",5,0)
    Device::Display.print(" 6 - Versions",6,0)
    key = getc
    if key == "1"
      Cloudwalk.communication
    elsif key == "2"
      Device::ParamsDat.update_apps
    elsif key == Device::IO::F2
      puts ""
      keys = Device::IO.get_format(1, 6, options = {:mode => :secret})
      if keys == "999999"
        Device::Display.clear
        Device::Display.print("Select:", 0, 7)
        Device::Display.print(" 1 - Production",1, 3)
        Device::Display.print(" 2 - Staging", 2, 3)

        if getc == "1"
            Device::Setting.environment = "production"
            closing
            Device::System.restart
        elsif getc == "2"
          Device::Setting.environment = "staging"
          closing
          Device::System.restart
        end
      else
        menu
      end
    elsif key == "3"
      Device::Display.clear
      Cloudwalk.logical_number
    elsif key == "4"
      year   = form("Input the year:"       , :min => 0 , :max => 4 , :default => Time.now.year)
      month  = form("Input the month:"      , :min => 0 , :max => 2 , :default => Time.now.month)
      day    = form("Input the day:"        , :min => 0 , :max => 2 , :default => Time.now.day)
      hour   = form("Input the hour:"       , :min => 0 , :max => 2 , :default => Time.now.hour)
      minute = form("Input the minutes:"    , :min => 0 , :max => 2 , :default => Time.now.min)
      second = form("Input the seconds:"    , :min => 0 , :max => 4 , :default => Time.now.sec)
      Time.new(year,month,day,hour,minute,second).hwclock
    elsif key == "5"
      show_config
    elsif key == "6"
      versions
    end
    Device::Display.clear
  end

  def self.closing
    Device::Display.clear
    i = 3
    loop do
      Device::Display.print("Rebooting...",3,3)
      Device::Display.print("#{i}")
      sleep(1)
      i -= 1
      break if i < 1
    end
  end

  def self.show_config
    Device::Display.clear

    if Device::Network.connected?
      connected = "Connected"
    else
      connected = "Not Connected"
    end

    if Device::Setting.media == Device::Network::MEDIA_WIFI
      Device::Display.print("Status:#{connected}", 0, 0)
      Device::Display.print("Auth:#{Device::Setting.authentication}", 1, 0)
      Device::Display.print("Essid:#{Device::Setting.essid}", 2, 0)
      Device::Display.print("PW:#{Device::Setting.password}", 3, 0)
      Device::Display.print("Channel:#{Device::Setting.channel}", 4, 0)
      Device::Display.print("Chiper:#{Device::Setting.cipher}", 5, 0)
      Device::Display.print("Mode:#{Device::Setting.mode}", 6,0)
      getc
    else
      Device::Display.print("Connected?:#{connected}", 0, 0)
      Device::Display.print("Apn:#{Device::Setting.apn}", 1, 0)
      Device::Display.print("User:#{Device::Setting.user}", 2, 0)
      Device::Display.print("PW:#{Device::Setting.password}", 3, 0)
      getc
    end
  end

  def self.versions
    Device::Display.clear
    Device::Display.print("Versions",0,0)
    Device::Display.print("Application:#{Main.version}", 2, 0)
    Device::Display.print("API:#{Device.api_version}", 3, 0)
    Device::Display.print("Framework:#{Device.version}", 4, 0)
    getc
  end
end
