
class PosxmlInterpreter
  include PosxmlParser
  include DaFunk::Helper

  def start
    posxml_configure!("./shared/", "inicio.posxml", false)
    posxml_loop
  end

  util_exit do
    @stop = true
  end

  # type:     1 for magstripe, 2 for chip, 3 for contactless, 4 for keyboard, 5 for touch.
  # keyboard: 1 for keybard enabled and 0 for keyboard disabled.
  # timeout:  In miliseconds in this case 30 seconds.
  # key:      When keyboard equals to 0, just returns with timeout or if you press KEY_CANCEL. If keyboard equals to 1 it will return all the pressed keys.
  # card:     It contains the track 2 and/or track 1 only when inputtype equals to 1.
  # var:      0 when a key is pressed or when the card input happens with success. -1 if it fails reading the tracks. -2 for timeout. For EMV chip or contactless: 1 for success, less than 1 for errors.
  card_system_input_transaction do |key, card, timeout, var, keyboard, type|
    # TODO Scalone: Low priority implementation
  end

  input_float do |variable, line, column, message|
    # TODO Scalone: Low priority implementation.
  end

  input_integer do |variable, line, column, message, min, max|
    # TODO Scalone: Low priority implementation.
  end

  input_option do |var, line, column, message, min, max|
    # TODO Scalone: Low priority implementation.
  end

  input_getvalue do |empty, caption, columnC, lineC, columnI, lineI, max, min, var|
    # TODO Scalone: Low priority implementation.
  end

  crypto_encryptdecrypt do |message,key,cryptotype,type,variablereturn|
    # Should be implemented by platform
  end

  # TODO Scalone: Low priority implementation.
  file_system_space { |dir, type, variable| }

  crypto_lrc do |buffer,size,variablereturn|
    # TODO Scalone: Low priority implementation.
  end

  crypto_xor do |buffer1,buffer2,size,variablereturn|
    # TODO Scalone: Low priority implementation.
  end

  crypto_crc do |buffer,size,crctype,variablereturn|
    # TODO Scalone: Low priority implementation.
  end

  serial_open_port do |port,rate,configuration,variablereturn|
    # TODO Scalone: Low priority implementation.
  end

  serial_read_port do |variablehandle,variablebuffer,bytes,timeout,variablereturn|
    # TODO Scalone: Low priority implementation.
  end

  serial_write_port do |variablehandle,buffer|
    # TODO Scalone: Low priority implementation.
  end

  serial_close_port do |variablehandle|
    # TODO Scalone: Low priority implementation.
  end

  network_pre_dial do |option, var|
    # TODO Scalone: Low priority implementation.
  end

  pinpad_open do |type,variableserialnumber,variablereturn|
    # Should be implemented by platform
  end

  pinpad_display do |message|
    # Should be implemented by platform
  end

  pinpad_getkey do |message,timeout,variablereturn|
    # Should be implemented by platform
  end

  pinpad_getpindukpt do |message,type,pan,maxlen,variablereturnpin,variablereturnksn,variablereturn|
    # Should be implemented by platform
  end

  pinpad_loadipek do |ipek,ksn,type,variablereturn|
    # Should be implemented by platform
  end

  pinpad_close do |message|
    # Should be implemented by platform
  end

  emv_open do |variablereturn,mkslot,pinpadtype,pinpadwk,showamount|
    # Should be implemented by platform
  end

  emv_close do |variablereturn|
    # Should be implemented by platform
  end

  emv_loadtables do |acquirer,variablereturn|
    # Should be implemented by platform
  end

  emv_settimeout do |seconds,variablereturn|
    # Should be implemented by platform
  end

  emv_cleanstructures do
    # Should be implemented by platform
  end

  emv_adddata do |type,parameter,value,variablereturn|
    # Should be implemented by platform
  end

  emv_getinfo do |type,parameter,value|
    # Should be implemented by platform
  end

  emv_inittransaction do |variablereturn|
    # Should be implemented by platform
  end

  emv_processtransaction do |variablereturn,ctls|
    # Should be implemented by platform
  end

  emv_finishtransaction do |variablereturn|
    # Should be implemented by platform
  end

  emv_removecard do |variablereturn|
    # Should be implemented by platform
  end

  smartcard_insert_card do |slot,variablereturn|
    # Should be implemented by platform
  end

  smartcard_reader_close do |slot,variablereturn|
    # Should be implemented by platform
  end

  smartcard_reader_start do |slot,variablereturn|
    # Should be implemented by platform
  end

  smartcard_transmit_APDU do |slot,header,lc,datafield,le,variabledatafieldresponse,variableSW,variablereturn|
    # Should be implemented by platform
  end

  util_parse_ticket do |productmenu,ticket,message,literal,variablereturn|
    # Should be implemented by platform
  end
end

