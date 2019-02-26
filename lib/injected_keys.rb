class InjectedKeys
  def self.write_injected_keys_on_log
    self.write_keys
  end

  def self.write_keys
    (0..99).inject({}) do |hash, slot|
      duktp_key = Device::Pinpad.key_ksn(slot)
      master_session = Device::Pinpad.key_kcv(slot)
      ContextLog.info("[K] Dukpt key injetecd on slot: #{slot}, ksi: #{duktp_key[:pin][1]}") if duktp_key[:pin][0] == 0
      ContextLog.info("[K] Master session key injetecd on slot: #{slot}, kcv: #{master_session[:ms3des][1]}") if master_session[:ms3des][0] == 0
    end
  end
end
