class AdminConfiguration
  include DaFunk::Helper

  KEEP_FILES = %w(background_gpos400.bmp battery100.png battery75.png gprs_gpos400.bmp main_mp20.bmp mobile20.png wifi0.png wifi_gpos400.bmp background_mp20.bmp battery100c.png battery_gpos400.bmp gprs_mp20.bmp main_s920.bmp mobile40.png wifi100.png wifi_mp20.bmp battery0.png battery25.png battery_mp20.bmp main.bmp mobile0.png mobile60.png wifi30.png battery0c.png battery50.png cw_apns.dat main_gpos400.bmp mobile100.png mobile80.png wifi60.png)

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
    selected = true
    while(selected) do
      selected = menu(I18n.t(:admin_menu_description), {
        "CLOUDWALK"                => :cloudwalk_menu,
        I18n.t(:admin_device_menu) => :device_menu,
        I18n.t(:admin_about)       => :about,
        I18n.t(:admin_exit)        => false
      })
      self.send(selected) if selected
    end
  end

  def self.cloudwalk_menu
    selected = true
    while(selected) do
      selected = menu("CLOUDWALK", {
        I18n.t(:admin_logical_number) => :logical_number,
        I18n.t(:admin_update)         => :update_menu,
        I18n.t(:admin_clear)          => :clear,
        "LOGS"                        => :logs_menu,
        I18n.t(:admin_back)           => false
      })
      self.send(selected) if selected
    end
  end

  def self.device_menu
    selected = true
    while(selected) do
      selected = menu(I18n.t(:admin_device_menu), {
        I18n.t(:admin_communication) => :communication,
        I18n.t(:admin_magstripe)     => :magstripe,
        I18n.t(:admin_serial_number) => :serial_number,
        I18n.t(:admin_back)          => false
      })
      self.send(selected) if selected
    end
  end

  def self.update_menu
    selected = true
    while(selected) do
      selected = menu(I18n.t(:admin_update), {
        I18n.t(:admin_clear)         => :clear,
        I18n.t(:admin_update_apps)   => :apps_update,
        I18n.t(:admin_update_system) => :system_update,
        I18n.t(:admin_update_check)  => :apps_update_check,
        I18n.t(:admin_update_force)  => :apps_update_force,
        I18n.t(:admin_clear_zip)     => :clear_zip,
        I18n.t(:admin_back)          => false
      })
      self.send(selected) if selected
    end
  end

  def self.logs_menu
    LogsMenu.perform
  end

  def self.logical_number
    Device::Setting.logical_number = form(
      I18n.t(:admin_logical_number), :min => 0, :max => 15,
      :default => Device::Setting.logical_number, :mode => :alpha)
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
    if Device::Network.connected?
      show = I18n.t(:attach_connected)
    else
      show = I18n.t(:attach_fail, :args => Device::Network.code)
    end

    if Device::Setting.media == Device::Network::MEDIA_WIFI
      show << "\nAUTH: #{Device::Setting.authentication}"
      show << "\nESSID: #{Device::Setting.essid}"
      show << "\nCHANNEL: #{Device::Setting.channel}"
      show << "\nCHIPER: #{Device::Setting.cipher}"
    else
      show << "\nAPN: #{Device::Setting.apn}"
      show << "\nUSER: #{Device::Setting.user}"
      show << "\nPW: #{Device::Setting.apn_password}"
    end

    Device::Display.clear
    puts show
    getc
  end

  def self.communication_configure
    media = menu(I18n.t(:admin_select_media), {"WIFI" => :wifi, "GPRS" => :gprs})
    if media == :wifi
      MediaConfiguration.wifi
    elsif media == :gprs
      MediaConfiguration.gprs
    end
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
      DaFunk::ParamsDat.parse
      files = KEEP_FILES.collect {|f| "./shared/#{f}"}
      DaFunk::ParamsDat.format!(true, files)
    end
  end

  def self.clear_zip
    Device::Display.clear
    I18n.pt(:admin_question_clear_zip)
    if getc == Device::IO::ENTER
      Dir.entries("./shared/").each do |f|
        path = "./shared/#{f}"
        File.delete(path) if f.include?(".zip") && File.file?(path)
      end
    end
  end

  def self.apps_update
    DaFunk::ParamsDat.update_apps(true) if attach
  end

  def self.apps_update_check
    DaFunk::ParamsDat.update_apps(true, true) if attach
  end

  def self.apps_update_force
    DaFunk::ParamsDat.update_apps(true, true, true) if attach
  end

  def self.system_update
    SystemUpdate.new.start
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
    key = getc
    if key == Device::IO::F2 || key == Device::IO::FUNC || key == Device::IO::ALPHA
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

