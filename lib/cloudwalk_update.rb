class CloudwalkUpdate
  def self.application
    return unless Device::Network.connected?

    Device::Display.clear
    I18n.pt(:system_update_check, :line => 0)
    I18n.pt(:system_update_cancel, :line => 3)
    I18n.pt(:system_update_x_to_cancel, :line => 4)
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

    Device::Display.clear
    I18n.pt(:system_update, :line => 0)
    I18n.pt(:system_update_cancel, :line => 3)
    I18n.pt(:system_update_x_to_cancel, :line => 4)
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
        Device::Display.clear
        I18n.pt(:system_update, :line => 0)
        Device::Display.clear(3)
        I18n.pt(:system_update_start, :line => 3)
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
    key = Device::IO::KEY_TIMEOUT

    10.times do |i|
      Device::Display.print((10 - i).to_s, 5, 11)
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

    Device::Display.clear
    I18n.pt(:system_update, :line => 0)
    I18n.pt(:attach_network, :line => 3)
    loop do
      if Device::Network.connected?
        break
      elsif time < Time.now && !Device::Network.connected?
        break
      elsif getc(100)== Device::IO::CANCEL
        File.delete('./shared/system_update') if File.exists?('./shared/system_update')
        break
      end
    end
  end
end

