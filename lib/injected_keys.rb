class InjectedKeys
  def self.log(filename)
    ContextLog.file_log = filename
    (0..99).inject({}) do |hash, slot|
      duktp_key = Device::Pinpad.key_ksn(slot)
      master_session = Device::Pinpad.key_kcv(slot)
      ContextLog.info("[K] Dukpt key injetecd on slot: #{slot}, ksi: #{duktp_key[:pin][1]}", filename) if duktp_key[:pin][0] == 0
      ContextLog.info("[K] Master session key injetecd on slot: #{slot}, kcv: #{master_session[:ms3des][1]}", filename) if master_session[:ms3des][0] == 0
    end
    ContextLog.file_log = nil
  end
end
