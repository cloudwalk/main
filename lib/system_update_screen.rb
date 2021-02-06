class SystemUpdate
  class Screen
    class << self
      attr_accessor :image
    end
    extend DaFunk::Helper
    SCREEN_RESTART_PATH = './shared/init_reboot.bmp'
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
    SCREEN_ABORT_SEARCH_UPDATE_KEYS_MAP = {
      Device::IO::ENTER  => {:x => 32..237, :y => 119..153},
      Device::IO::CANCEL => {:x => 30..239, :y => 171..202}
    }
    SCREENS_UPATE_FAIL_SUCCESS = {
      :system_update_success => '',
      :system_update_fail    => ''
    }
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

    def self.show_message(symbol, block)
      if SCREENS_UPATE_FAIL_SUCCESS.include?(symbol)
        sucess_or_failed_message(block)
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
        Device::Display.print_bitmap(SCREENS_UPATE_SUCCESS[symbol])
        getc(2000)
        Device::Display.print_bitmap(SCREEN_RESTART_PATH)
        Device::System.restart
      end
      block.call
    end

    def self.sucess_or_failed_message(block)
      if File.exists?(self.image[:image])
        return Device::Display.print_bitmap(self.image[:image])
      end
      block.call
    end
  end
end
