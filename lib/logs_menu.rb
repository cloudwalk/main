class LogsMenu
  include DaFunk::Helper

  def self.perform
    action = true
    while(action) do
      action = self.action_menu
      self.send(action) if action
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
      self.send_file(menu("LOGS", dirs))
    end
  end

  def self.send_file(filename)
    content = JsonLog.log_txt_to_json(filename)
    Device::Display.clear
    I18n.pt(:admin_logs_uploading)
    if self.upload(content, "/v1/devices/", false)
      Device::Display.clear
      I18n.pt(:admin_logs_success)
    else
      Device::Display.clear
      I18n.pt(:admin_logs_fail)
    end
    getc(2000)
  end

  def self.upload(content, path="/v1/files/", zip_file=true)
    req = {
      "Content-Type" => "application/json"
    }
    http = SimpleHttp.new("https", endpoint)
    Device::System.klass = "cw_logs.posxml"
    http.socket = Device::Network.socket.call
    if zip_file
      return unless token = api_token
      req["Body"] = body(content.split("/").last, content, token)
    else
      path+="#{access_token}/metrics"
      req["Body"] = content
    end
    response = http.request("POST", path, req)
    response.code == 201 || response.code == 200
  ensure
    Device::System.klass = "main"
  end

  def self.clear
    dirs = Dir.entries("./main").select {|p| p.include?(".log") }.collect {|p| "./main/#{p}" }
    dirs.each { |file| File.delete(file) if File.file?(file) }
    Device::Display.clear
    I18n.pt(:admin_logs_cleaned)
    getc(2000)
  end

  def self.action_menu
    menu(I18n.t(:admin_update), {
      I18n.t(:admin_logs_upload_file) => :send_file_menu,
      I18n.t(:admin_logs_clear)       => :clear,
      I18n.t(:admin_back)             => false
    })
  end

  private

  def self.body(name, zip_file, token)
    {
      "format"       => "json",
      "name"         => name,
      "description"  => "Log #{name}",
      "created_via"  => "device",
      "content"      => [File.read(zip_file)].pack("m0"),
      "access_token" => token
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
    value = DaFunk::ParamsDat.file["api_token"]
    I18n.pt(:admin_logs_not_configured) unless value
    value
  end

  def self.access_token
    DaFunk::ParamsDat.file["access_token"]
  end
end
