class Cloudwalk
  include Device::Helper

  def self.boot(start_attach = true)
    I18n.configure("main", Device::Setting.locale)
    if Device::Network.configured? && start_attach
      if attach
        Device::Notification.start
      end
    end
  end

  def self.execute
    unless application = Device::ParamsDat.executable_app
      application = Device::ParamsDat.application_menu
    end
    application.execute if application
  end

  def self.start
    if Device::ParamsDat.ready?
      self.execute
    elsif Device::ParamsDat.exists?
      Device::ParamsDat.update_apps
    else
      CloudwalkWizard.new.start
    end
  end
end
