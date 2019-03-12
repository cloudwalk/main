class InjectedKeys
  def self.write_injected_keys_on_log(filename)
    (0..99).inject({}) do |hash, slot|
      duktp_key = Device::Pinpad.key_ksn(slot)
      master_session = Device::Pinpad.key_kcv(slot)
      ContextLog.append_old_log("[K] Dukpt key injetecd on slot: #{slot}, ksi: #{duktp_key[:pin][1]}", filename) if duktp_key[:pin][0] == 0
      ContextLog.append_old_log("[K] Master session key injetecd on slot: #{slot}, kcv: #{master_session[:ms3des][1]}", filename) if master_session[:ms3des][0] == 0
    end
  end
end
