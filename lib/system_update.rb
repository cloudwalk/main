class SystemUpdate < DaFunk::ScreenFlow
  PATH_UPDATE_DAT   = "./shared/update.dat"
  REMOTE_UPDATE_DAT = "update.dat"
  PATH_UPDATE_FILES = "./shared/update_files.dat"

  include DaFunk::Helper

  attr_accessor :dat, :zip_filename, :total, :zip_path, :status, :zip_crc

  setup do
    Device::Display.clear
    I18n.pt(:system_update)
  end

  screen :device_dat_download do |result|
    I18n.pt(:system_update_check, :line => 3)
    if self.download_device_dat
      I18n.pt(:system_update_available, :line => 4)
      true
    else
      I18n.pt(:system_update_not_available, :line => 4)
      getc(2000)
      nil
    end
  end

  screen :parts_download do |result|
    block_success = -> {
      I18n.pt(:system_update_success, :line => 5)
    }
    block_fail = -> {
      I18n.pt(:system_update_fail, :line => 5)
      sleep 1
    }
    I18n.pt(:system_update_downloading_parts, :line => 3)
    self.download_parts(block_success, block_fail)
  end

  screen :parts_concatenation do
    I18n.pt(:system_update_concatenate, :line => 3)
    self.concatenate
  end

  screen :unpack_files do
    I18n.pt(:system_update_unpack, :line => 3)
    getc(5_000)

    if self.unzip
      true
    else
      I18n.pt(:system_update_file_not_found, :line => 3)
      getc(5_000)
      nil
    end
  end

  screen :system_update do
    I18n.pt(:system_update_updating, :line => 3)
    block_success = -> {
      I18n.pt(:system_update_success_restart, :line => 4)
      getc(5_000)
      Device::System.restart
    }
    block_fail = -> {
      I18n.pt(:system_update_problem, :line => 4)
      getc(5_000)
    }
    self.update(block_success, block_fail)
  end

  def download_device_dat
    ret = DaFunk::Transaction::Download.request_file(
      REMOTE_UPDATE_DAT,
      PATH_UPDATE_DAT,
      Device::Crypto.file_crc16_hex(PATH_UPDATE_DAT)
    )
    if validation = DaFunk::Transaction::Download.check(ret)
      parse_device_dat
    end
    validation
  end

  def parse_device_dat
    self.dat          = FileDb.new(PATH_UPDATE_DAT)
    self.total        = self.dat["parts"].to_i
    self.zip_filename = self.dat["filename"]
    self.zip_path     = "./shared/#{zip_filename}"
    self.zip_crc      = self.dat["crc"]
  end

  def download_parts(block_success, block_fail)
    parse_device_dat unless self.dat
    return true if check(self.zip_path, self.zip_crc)

    full  = true
    1.upto(self.total) do |part|
      result = try(3) do |attempt|
        print("#{part}/#{self.total}",4)

        if response = self.download_partial(self.zip_filename, part, self.dat[part.to_s])
          block_success.call
        else
          block_fail.call
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
    parse_device_dat unless self.dat

    files = FileDb.new(PATH_UPDATE_FILES)["content"]
    ContextLog.info "System Update - Files #{files.inspect}"
    if files
      files.split(",").each do |file|
        path = "./shared/#{file}"
        if File.exists?(path) && Device::System.update(path)
          File.delete(path) if File.exists?(path)
          File.delete(self.zip_path) if File.exists?(self.zip_path)
          block_success.call
        else
          block_fail.call
          File.delete(path) if File.exists?(path)
          false
        end
      end
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
end

