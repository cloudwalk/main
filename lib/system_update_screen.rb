class SystemUpdate
  class Screen
    class << self
      attr_accessor :image
    end
    extend DaFunk::Helper
    SCREEN_RESTART_PATH = './shared/init_reboot.bmp'
    UPDATE_FILE_PATH    = './shared/system_update'
    SCREENS = {
      :system_update_check             => './shared/searching_updates.bmp',
      :system_update_available         => './shared/updating_system_00.bmp',
      :system_update_not_available     => './shared/app_uptodate.bmp',
      :attach_device_not_configured    => './shared/network_system_error.bmp',
      :system_update_unpack            => './shared/installing.bmp',
      :system_update_file_not_found    => './shared/install_fail.bmp',
      :system_update_updating          => './shared/installing.bmp',
      :system_update_downloading_parts => './shared/updating_system_00.bmp',
      :system_update_concatenate       => './shared/installing.bmp',
      :system_update_problem           => '/shared/install_fail.bmp'
    }
    SCREEN_ABORT = {
      :system_update_interrupt => './shared/update_cancel.bmp',
    }
    SCREEN_ABORT_KEYS_MAP = {
      Device::IO::ONE_NUMBER => {:x => 30..239, :y => 117..152},
      Device::IO::TWO_NUMBER => {:x => 38..230, :y => 180..203}
    }
    SCREENS_UPATE_PART_SUCCESS = [
      :system_update_success
    ]
    SCREENS_UPATE_PART_FAIL = [
      :system_update_fail
    ]
    SCREENS_UPATE_SUCCESS = {
      :system_update_success_restart => './shared/update_sucess.bmp',
    }
    MAP_PARTS = [
      {:range => 1..9,   :image => './shared/updating_system_00.bmp'},
      {:range => 10..19, :image => './shared/updating_system_01.bmp'},
      {:range => 20..29, :image => './shared/updating_system_02.bmp'},
      {:range => 30..39, :image => './shared/updating_system_03.bmp'},
      {:range => 40..49, :image => './shared/updating_system_04.bmp'},
      {:range => 50..59, :image => './shared/updating_system_05.bmp'},
      {:range => 60..69, :image => './shared/updating_system_06.bmp'},
      {:range => 70..79, :image => './shared/updating_system_07.bmp'},
      {:range => 80..89, :image => './shared/updating_system_08.bmp'},
      {:range => 90..99, :image => './shared/updating_system_09.bmp'},
      {:range => 100..100, :image => './shared/updating_system_10.bmp'}
    ]

    def self.show_message(symbol, block, options = {})
      if SCREENS_UPATE_PART_SUCCESS.include?(symbol)
        part_sucess_message(block)
      elsif SCREENS_UPATE_PART_FAIL.include?(symbol)
        part_fail_message(block, options[:reason])
      elsif SCREENS_UPATE_SUCCESS.include?(symbol)
        update_success_message(symbol, block)
      elsif SCREEN_ABORT.include?(symbol)
        abort_message(symbol, block)
      elsif SCREENS.include?(symbol)
        normal_message(symbol, block)
      else
        block.call
      end
    rescue => e
      ContextLog.exception(e, e.backtrace)
      block.call
    end

    def self.show_percentage(percent, part, total)
      self.image = MAP_PARTS.find { |value| value[:range].include?(percent) }
      if self.image.is_a?(Hash)
        if File.exists?(self.image[:image])
          Device::Display.print_bitmap(self.image[:image])
        else
          Device::Display.clear
          I18n.pt(:system_update, :line => 0)
          I18n.pt(:system_update_downloading_parts, :line => 3)
          Device::Display.print("#{part}/#{total}", 4, 0)
        end
      else
        Device::Display.clear
        I18n.pt(:system_update, :line => 0)
        I18n.pt(:system_update_downloading_parts, :line => 3)
        Device::Display.print("#{part}/#{total}", 4, 0)
      end
    rescue => e
      ContextLog.exception(e, e.backtrace)
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_downloading_parts, :line => 3)
      Device::Display.print("#{part}/#{total}", 4, 0)
    end

    def self.abort_message(symbol, block)
      if File.exists?(SCREEN_ABORT[symbol])
        Device::Display.print_bitmap(SCREEN_ABORT[symbol])
        event, key = wait_touchscreen_or_keyboard_event(SCREEN_ABORT_KEYS_MAP, 30_000, {special_keys: []})
        return true if key == Device::IO::ONE_NUMBER
        return false
      end
      block.call
    end

    def self.normal_message(symbol, block)
      if File.exists?(SCREENS[symbol])
        return Device::Display.print_bitmap(SCREENS[symbol])
      end
      block.call
    end

    def self.update_success_message(symbol, block)
      if File.exists?(SCREENS_UPATE_SUCCESS[symbol]) && File.exists?(SCREEN_RESTART_PATH)
        File.delete(UPDATE_FILE_PATH) if File.exists?(UPDATE_FILE_PATH)
        Device::Display.print_bitmap(SCREENS_UPATE_SUCCESS[symbol])
        getc(2000)
        Device::Display.print_bitmap(SCREEN_RESTART_PATH)
        getc(2000)
        Device::System.restart
      end
      block.call
    end

    def self.part_sucess_message(block)
      if File.exists?(self.image[:image])
        return Device::Display.print_bitmap(self.image[:image])
      end
      block.call
    end

    def self.part_fail_message(block, reason)
      file = update_part_fail_reasons(reason)
      if File.exists?(file)
        Device::Display.print_bitmap(file)
        getc(2000)
        return false
      end
      block.call
    end

    def self.update_part_fail_reasons(reason)
      case reason
      when DaFunk::Transaction::Download::SERIAL_NUMBER_NOT_FOUND
        './shared/config_fail.bmp'
      when DaFunk::Transaction::Download::FILE_NOT_FOUND
        './shared/config_fail.bmp'
      when DaFunk::Transaction::Download::COMMUNICATION_ERROR
        './shared/network_system_error.bmp'
      when DaFunk::Transaction::Download::IO_ERROR
        './shared/config_fail.bmp'
      else
        './shared/network_system_error.bmp'
      end
    end
  end
end
