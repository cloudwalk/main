class LogsMenu
  include DaFunk::Helper

  def self.perform
    action = true
    while(action) do
      action = self.action_menu
      break if action.nil? || action == Device::IO::CANCEL || action == Device::IO::KEY_TIMEOUT
      self.send(action)
    end
  end

  def self.send_file_menu
    dirs = Dir.entries("./main").select {|p| p.include?(".log") }
    if dirs.empty?
      Device::Display.clear
      I18n.pt(:admin_logs_file_not_found)
      getc(2000)
    elsif ! Device::Network.connected?
      Device::Display.clear
      I18n.pt(:attach_device_not_configured)
      getc(2000)
    else
      log = menu("LOGS", dirs)
      unless log.nil? || log == Device::IO::KEY_TIMEOUT || log == Device::IO::CANCEL
        self.send_file(log)
      end
    end
  end

  def self.send_file(filename)
    LogControl.layout
    path = "./main/#{filename}"
    zip  = "./main/#{Device::System.serial}-#{filename.split(".").first}.zip"

    if filename && File.exists?(path)
      LogControl.write_keys(filename)

      if Zip.compress(zip, path)
        if self.upload(zip)
          File.delete(path)
        end
        File.delete(zip) if File.exists?(zip)
      end
    end
  end

  def self.upload(zip_file)
    if api_token.nil?
      I18n.pt(:admin_logs_not_configured)
      return false
    end

    socket      = CloudwalkSocket.new
    socket.host = endpoint
    socket.port = '443'
    socket.connect(true)

    http        = SimpleHttp.new("https", socket.host, 443)
    http.socket = socket

    response = http.request("POST", "/v1/devices/#{api_token}/metrics", {
      "Content-Type" => "application/json",
      "Body" => body(zip_file.split("/").last, zip_file)
    })

    response.code == 201 || response.code == 200
  end

  def self.clear
    dirs = Dir.entries("./main").select {|p| p.include?(".log") }.collect {|p| "./main/#{p}" }
    dirs.each { |file| File.delete(file) if File.file?(file) }
    Device::Display.clear
    I18n.pt(:admin_logs_cleaned)
    getc(2000)
  end

  def self.action_menu
    menu(I18n.t(:admin_logs_menu), {
      I18n.t(:admin_logs_upload_file) => :send_file_menu,
      I18n.t(:admin_logs_clear)       => :clear,
      I18n.t(:admin_back)             => false
    })
  end

  private

  def self.body(name, zip_file)
    {
      "name"         => name,
      "content"      => [File.read(zip_file)].pack("m0")
    }.to_json
  end

  def self.endpoint
    if Device::Setting.staging?
      "api-staging.cloudwalk.io"
    else
      "api.cloudwalk.io"
    end
  end

  def self.api_token
    DaFunk::ParamsDat.file["access_token"]
  end
end
