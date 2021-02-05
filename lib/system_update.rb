class SystemUpdate < DaFunk::ScreenFlow
  PATH_UPDATE_DAT      = "./shared/update.dat"
  REMOTE_UPDATE_DAT    = "update.dat"
  PATH_UPDATE_FILES    = "./shared/update_files.dat"
  PATH_UPDATE_DONE     = './shared/system_update'

  include DaFunk::Helper

  class << self
    attr_accessor :current
  end

  attr_accessor :dat, :zip_filename, :total, :zip_path, :status, :zip_crc

  setup do
    block_search = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_check, :line => 3)
    }
    SystemUpdate::Screen.show_message(:system_update_check, block_search)
  end

  screen :device_dat_download do |result|
    block_search = -> {
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_check, :line => 3)
    }
    block_found = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_available, :line => 4)
    }
    block_not_found = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_not_available, :line => 4)
      getc(5000)
    }
    block_connection_error = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:attach_device_not_configured, :line => 4)
      getc(5000)
    }
    SystemUpdate::Screen.show_message(:system_update_check, block_search)
    if Device::Network.connected?
      if self.download_device_dat
        SystemUpdate::Screen.show_message(:system_update_available, block_found)
        true
      else
        SystemUpdate::Screen.show_message(:system_update_not_available, block_not_found)
        File.delete(PATH_UPDATE_DONE) if File.exists?(PATH_UPDATE_DONE)
        false
      end
    else
      SystemUpdate::Screen.show_message(:attach_device_not_configured, block_connection_error)
      false
    end
  end

  screen :parts_download do |result|
    block_success = -> {
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_success, :line => 5)
      getc(500)
      Device::Display.clear(5)
    }
    block_fail = -> {
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_fail, :line => 5)
      sleep 1
    }
    block_interrupt = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_interrupt)
      try_key(["1", "2"], Device::IO.timeout) == "1"
    }
    self.download_parts(block_success, block_fail, block_interrupt)
  end

  screen :parts_concatenation do
    block = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_concatenate, :line => 3)
    }
    SystemUpdate::Screen.show_message(:system_update_concatenate, block)
    self.concatenate
  end

  screen :unpack_files do
    block_unpack = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_unpack, :line => 3)
    }
    block_fail = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_file_not_found, :line => 3)
      getc(5_000)
    }
    SystemUpdate::Screen.show_message(:system_update_unpack, block_unpack)
    getc(5_000)
    if self.unzip
      true
    else
      SystemUpdate::Screen.show_message(:system_update_file_not_found, block_fail)
      false
    end
  end

  screen :system_update do
    block_updating = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_updating, :line => 3)
    }
    block_success = -> {
      File.delete(PATH_UPDATE_DONE) if File.exists?(PATH_UPDATE_DONE)
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_success_restart, :line => 4)
      getc(5_000)
      Device::System.restart
    }
    block_fail = -> {
      Device::Display.clear
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_problem, :line => 4)
      getc(5_000)
    }
    SystemUpdate::Screen.show_message(:system_update_updating, block_updating)
    self.update(block_success, block_fail)
  end

  def self.bg_start
    @current ||= SystemUpdate.new
  end

  def self.bg_stop
    @current = nil
  end

  def bg_check
    unless @done
      @download_device_dat ||= download_device_dat
      @part                ||= 1

      if @dat
        @part +=1 if download_partial(self.zip_filename, @part, self.dat[@part.to_s])
        if @part > total
          File.open(PATH_UPDATE_DONE, 'w'){|f| f.write("DONE\nRESTART DEVICE") }
          @done = true
        end
      else
        @done = true
      end
    end
  end

  def done?
    if @done && @dat
      unless File.exists?(PATH_UPDATE_DONE)
        File.open(PATH_UPDATE_DONE, 'w'){|f| f.write("DONE\nRESTART DEVICE") }
      end
    end
    @done
  end

  def download_device_dat
    result = try(3) do |attempt|
      ret = DaFunk::Transaction::Download.request_file(
        REMOTE_UPDATE_DAT,
        PATH_UPDATE_DAT,
        Device::Crypto.file_crc16_hex(PATH_UPDATE_DAT)
      )
      DaFunk::Transaction::Download.check(ret)
    end
    if result
      parse_device_dat
    end
    result
  end

  def parse_device_dat
    self.dat          = FileDb.new(PATH_UPDATE_DAT)
    self.total        = self.dat["parts"].to_i
    self.zip_filename = self.dat["filename"]
    self.zip_path     = "./shared/#{zip_filename}"
    self.zip_crc      = self.dat["crc"]
  end

  def download_parts(block_success, block_fail, block_interrupt)
    block_start = -> {
      I18n.pt(:system_update, :line => 0)
      I18n.pt(:system_update_downloading_parts, :line => 3)
    }
    SystemUpdate::Screen.show_message(:system_update_downloading_parts, block_start)
    parse_device_dat unless self.dat
    return true if check(self.zip_path, self.zip_crc)

    full  = true
    1.upto(self.total) do |part|
      result = try(3) do |attempt|
        percent = calculate_percent(part, self.total)
        ContextLog.info "show_percentage percent #{percent}"
        SystemUpdate::Screen.show_percentage(percent, part, self.total)
        if (getc(10) == Device::IO::CANCEL)
          return if SystemUpdate::Screen.show_message(:system_update_interrupt, block_interrupt)
          SystemUpdate::Screen.show_percentage(percent, part, self.total)
        end

        if response = self.download_partial(self.zip_filename, part, self.dat[part.to_s])
          SystemUpdate::Screen.show_message(:system_update_success, block_success)
        else
          SystemUpdate::Screen.show_message(:system_update_fail, block_fail)
        end
        response
      end
      full = false unless result
    end

    full
  end

  def concatenate
    parse_device_dat unless self.dat
    error       = false
    status_path = "#{zip_path}.status"

    return true if check(self.zip_path, self.zip_crc)

    File.delete(self.zip_path) if File.exists?(self.zip_path)
    File.delete(status_path) if File.exists?(status_path)
    self.status = FileDb.new(status_path)

    1.upto(total) do |part|
      path = "#{self.zip_path}.part#{part}"
      if check(path, self.dat[part.to_s])
        self.append(zip_path, path)
        status["#{part}"] = "1"
      else
        error = true
        status["#{part}"] = "0"
        File.delete(path) if File.exists?(path)
      end
    end

    if ! error && check(self.zip_path, self.dat["crc"])
      status["crc"] = "1"
      delete_parts
      true
    else
      status["crc"] = "0"
      File.delete(self.zip_path) if File.exists?(self.zip_path)
      false
    end
  end

  def unzip
    parse_device_dat unless self.dat

    if self.zip_filename && File.exists?(self.zip_path)
      Zip.uncompress(zip_path, "./shared", false, false)
    end
  end

  def update(block_success, block_fail)
    version_major, version_minor, _patch = Device.version.to_s.split('.').map { |v| v.to_i }
    parse_device_dat unless self.dat

    files = FileDb.new(PATH_UPDATE_FILES)["content"]

    ContextLog.info "System Update - Files #{files.inspect}"
    if files
      delete_zip = true
      files.split(",").each do |entry|

        file, type = entry.split(";")
        path = "./shared/#{file}"
        # Because of the error that was introduced in the System#update method on version 8.0.1
        if version_major == 8 && version_minor == 0
          if delete_zip && File.exists?(path)
            Device::System.update("./shared/#{entry}")
            File.delete(path) if File.exists?(path)
            SystemUpdate::Screen.show_message(:system_update_success_restart, block_success)
          end
        else
          if delete_zip && File.exists?(path) && Device::System.update("./shared/#{entry}")
            File.delete(path) if File.exists?(path)
            SystemUpdate::Screen.show_message(:system_update_success_restart, block_success)
          else
            delete_zip = false
            SystemUpdate::Screen.show_message(:system_update_problem, block_fail)
            File.delete(path) if File.exists?(path)
            false
          end
        end
      end
      File.delete(self.zip_path) if File.exists?(self.zip_path)
    end
  end

  private
  def append(zip, path)
    File.open(zip, "a") do |handle|
      File.open(path, "r") do |file|
        loop do
          begin
            handle.write(file.sysread(1000))
          rescue EOFError
            break
          end
        end
      end
    end
  end

  def delete_parts
    1.upto(self.total) do |part|
      path = "#{self.zip_path}.part#{part}"
      File.delete(path) if File.exists?(path)
    end
  end

  def download_partial(zip, part, crc)
    filename  = "#{zip}.part#{part}"
    path      = "./shared/#{filename}"

    if check(path, crc)
      true
    else
      ret = DaFunk::Transaction::Download.request_file(filename, path, "0000")
      DaFunk::Transaction::Download.check(ret)
    end
  end

  def check(path, crc)
    local_crc = Device::Crypto.file_crc16_hex(path)
    ContextLog.info "SystemUpdate - CRC Check [#{path}][#{crc}][#{local_crc}]"
    File.exists?(path) && local_crc == crc
  end

  def calculate_percent(part, total)
    ((part / total) * 100).round(0)
  end
end

