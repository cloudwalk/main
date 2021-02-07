class CloudwalkUpdate
  extend DaFunk::Helper

  SYSTEM_UPDATE_FILE_PATH = './shared/system_update'
  NETWORK_START_IMAGE_PATH = [
    './shared/network_conectar_init1.bmp',
    './shared/network_conectar_init2.bmp',
    './shared/network_conectar_init3.bmp',
    './shared/network_conectar_init4.bmp',
    './shared/network_conectar_init5.bmp',
    './shared/network_conectar_init6.bmp'
  ]
  UPDATE_CANCEL_IMAGE_PATH = [
    './shared/update_10.bmp',
    './shared/update_9.bmp',
    './shared/update_8.bmp',
    './shared/update_7.bmp',
    './shared/update_6.bmp',
    './shared/update_5.bmp',
    './shared/update_4.bmp',
    './shared/update_3.bmp',
    './shared/update_2.bmp',
    './shared/update_1.bmp',
  ]
  UPDATE_RESTART_IMAGE_PATH = './shared/init_reboot.bmp'
  SCREEN_ABORT_SEARCH_UPDATE_KEYS_MAP = {
    Device::IO::ENTER  => {:x => 30..239, :y => 117..152},
    Device::IO::CANCEL => {:x => 38..230, :y => 180..203}
  }

  def self.application
    return unless Device::Network.connected?

    key = count_down
    if File.exists?("./shared/application_update")
      File.delete("./shared/application_update")
    end

    if key != Device::IO::CANCEL
      DaFunk::ParamsDat.update_apps(true, true, false, false)
      Device::System.restart
    end
  end

  def self.system
    BacklightControl.on
    wait_connection if Device::Setting.boot == '1'
    return unless Device::Network.connected?
    key = Device::IO::KEY_TIMEOUT

    if File.exists?(SYSTEM_UPDATE_FILE_PATH)
      restart = File.read(SYSTEM_UPDATE_FILE_PATH).split("\n")[1] == 'RESTART DEVICE'
      key = count_down if restart
    else
      restart = false
      key = count_down
    end

    if key != Device::IO::CANCEL
      if restart
        File.open(SYSTEM_UPDATE_FILE_PATH, 'w') do |f|
          f.write("DONE\nDO NOT RESTART DEVICE")
        end

        if File.exists?(UPDATE_RESTART_IMAGE_PATH)
          Device::Display.print_bitmap(UPDATE_RESTART_IMAGE_PATH)
        else
          Device::Display.clear
          I18n.pt(:system_update, :line => 0)
          Device::Display.clear(3)
          I18n.pt(:system_update_start, :line => 3)
        end
        getc(7000)
        Device::System.restart
      else
        SystemUpdate.new.start
      end
    else
      File.delete(SYSTEM_UPDATE_FILE_PATH) if File.exists?(SYSTEM_UPDATE_FILE_PATH)
    end
  end

  def self.count_down
    image_exists = true
    unless File.exists?(UPDATE_CANCEL_IMAGE_PATH[0])
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_cancel, :line => 3)
      I18n.pt(:system_update_x_to_cancel, :line => 4)
      image_exists = false
    end

    key = Device::IO::KEY_TIMEOUT
    special_keys = {special_keys: [Device::IO::ENTER, Device::IO::CANCEL]}
    10.times do |i|
      if image_exists
        Device::Display.print_bitmap(UPDATE_CANCEL_IMAGE_PATH[i])
        event, key = wait_touchscreen_or_keyboard_event(SCREEN_ABORT_SEARCH_UPDATE_KEYS_MAP, 1_000, special_keys)
      else
        Device::Display.print((10 - i).to_s, 5, 11)
        key = getc(1000)
      end
      break if key != Device::IO::KEY_TIMEOUT
    end
    key
  end

  def self.system_in_progress?
    if File.exists?(SYSTEM_UPDATE_FILE_PATH)
      File.read(SYSTEM_UPDATE_FILE_PATH).split("\n")[0] == 'DONE'
    else
      false
    end
  end

  def self.wait_connection
    time = Time.now + 180

    unless File.exists?(NETWORK_START_IMAGE_PATH[0])
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:attach_network, :line => 3)
    end

    images_loop = 0
    loop do
      image = NETWORK_START_IMAGE_PATH[images_loop]
      Device::Display.print_bitmap(image) if File.exists?(image)
      if Device::Network.connected?
        break
      elsif time < Time.now && !Device::Network.connected?
        break
      elsif getc(100)== Device::IO::CANCEL
        File.delete(SYSTEM_UPDATE_FILE_PATH) if File.exists?(SYSTEM_UPDATE_FILE_PATH)
        break
      end
      images_loop += 1
      images_loop = 0 if images_loop > 5
    end
  end
end

