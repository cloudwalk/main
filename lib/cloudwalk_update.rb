class CloudwalkUpdate
  NETWORK_START_IMAGE_PATH = [
    './shared/network_conectar_init1.bmp',
    './shared/network_conectar_init2.bmp',
    './shared/network_conectar_init3.bmp',
    './shared/network_conectar_init4.bmp',
    './shared/network_conectar_init5.bmp',
    './shared/network_conectar_init6.bmp'
  ]
  UPDATE_CANCEL_IMAGE_PATH = [
    './shared/uptade_1.bmp',
    './shared/uptade_2.bmp',
    './shared/uptade_3.bmp',
    './shared/uptade_4.bmp',
    './shared/uptade_5.bmp',
    './shared/uptade_6.bmp',
    './shared/uptade_7.bmp',
    './shared/uptade_8.bmp',
    './shared/uptade_9.bmp',
    './shared/uptade_10.bmp'
  ]
  UPDATE_RESTART_IMAGE_PATH = './shared/init_reboot.bmp'

  def self.application
    return unless Device::Network.connected?

    key = count_down
    if File.exists?("./shared/application_update")
      File.delete("./shared/application_update")
    end

    if key != Device::IO::CANCEL
      DaFunk::ParamsDat.update_apps(true)
      Device::System.restart
    end
  end

  def self.system
    BacklightControl.on
    wait_connection if Device::Setting.boot == '1'
    return unless Device::Network.connected?
    key = Device::IO::KEY_TIMEOUT

    if File.exists?('./shared/system_update')
      restart = File.read('./shared/system_update').split("\n")[1] == 'RESTART DEVICE'
      key = count_down if restart
    else
      restart = false
      key = count_down
    end

    if key != Device::IO::CANCEL
      if restart
        File.open('./shared/system_update', 'w') do |f|
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
      File.delete('./shared/system_update') if File.exists?('./shared/system_update')
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
    10.times do |i|
      if image_exists
        Device::Display.print_bitmap(UPDATE_CANCEL_IMAGE_PATH[i])
      else
        Device::Display.print((10 - i).to_s, 5, 11)
      end
      key = getc(1000)
      break if key != Device::IO::KEY_TIMEOUT
    end
    key
  end

  def self.system_in_progress?
    if File.exists?('./shared/system_update')
      File.read('shared/system_update').split("\n")[0] == 'DONE'
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
        File.delete('./shared/system_update') if File.exists?('./shared/system_update')
        break
      end
      images_loop += 1
      images_loop = 0 if images_loop > 5
    end
  end
end

