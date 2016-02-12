class CloudwalkWizard < DaFunk::ScreenFlow
  include DaFunk::Helper

  def order
    language.serial_number_1.serial_number_2.logical_number_1.
      logical_number_2.communication_1.communication_2.
      activation_1.activation_2.activation_3
  end

  add :language do |result|
    I18n.pt :language
    # TODO Language
    if (try_key(["1","2"], 0) == "1")
      I18n.locale = "pt-br"
    else
      I18n.locale = "en"
    end
    Device::Setting.locale = I18n.locale
    true
  end

  add :serial_number_1 do |result|
    confirm I18n.t(:serial_number_1)
  end

  add :serial_number_2 do |result|
    confirm I18n.t(:serial_number_2, :args => Device::System.serial)
  end

  add :logical_number_1 do |result|
    confirm I18n.t(:logical_number_1)
  end

  add :logical_number_2 do |result|
    I18n.pt(:logical_number_2)
    options = {:value => Device::Setting.logical_number, :mode => :alpha,
      :column => 0, :line => 4, :label => ": "}
    Device::Setting.logical_number = Device::IO.get_format(1, 19, options)
    ! Device::Setting.logical_number.empty?
  end

  add :communication_1 do |result|
    confirm I18n.t(:communication)
  end

  add :communication_2 do |result|
    ret = false
    unless (ret = (Device::Network.connected? == 0))
      case(menu("Select Media:", {"WIFI" => :wifi, "GPRS" => :gprs}))
      when :wifi; ret = MediaConfiguration.wifi
      when :gprs; ret = MediaConfiguration.gprs
      end
    end

    Device::Setting.network_configured = "1"
    ret
  end

  add :activation_1 do |result|
    confirm I18n.t(:activation_1)
  end

  add :activation_2 do |result|
    I18n.pt(:activation_2)
    connected = Device::Network.connected?
    connected = Device::Network.attach if connected != Device::Network::SUCCESS
    params = Device::ParamsDat.download if connected == Device::Network::SUCCESS
    if params && Device::ParamsDat.exists?
      true
    else
      Device::Display.clear
      confirm I18n.t(:activation_error)
      false
    end
  end

  add :activation_3 do |result|
    confirm I18n.t(:activation_success)
  end
end

