class Interpreter
  include PosxmlParser
  include DaFunk::Helper

  #def flow_if(jump_point, variable1, operator, variable2=Variable.new(""))
    #variable2.value = "" if variable2.value == " "
    #if !Variable::OPERATORS[operator.value.to_s]
      #$device.error("\"#{operator.value}\" is not a valid operator!")
      #util_exit
    #end
    #if variable1.value.class == Float
      #_variable1 = Variable.new(variable1.to_s)
      #posxml_conditional(jump_point, _variable1, operator, variable2)
    #else
      #posxml_conditional(jump_point, variable1, operator, variable2)
    #end
  #end

  #def flow_while(jump_point, variable1, operator, variable2=Variable.new(""))
    #if variable1.value.class == Float
      #_variable1 = Variable.new(variable1.to_s)
      #posxml_conditional(jump_point, _variable1, operator, variable2)
    #else
      #posxml_conditional(jump_point, variable1, operator, variable2)
    #end
  #end

  # TODO Scalone: Implement
  util_exit { }

  file_download do |filename, remotepath, variable|
    #TODO Implement
  end

  card_get_variable do |msg1, msg2, min, max, var|
    Device::Display.clear
    Device::Display.print_line(msg1.value, 0, 2)
    tracks = Device::Magnetic.read_card(Device::IO.timeout)
    var.value = "#{tracks[:track1]}=#{tracks[:track2]}"
  end

  card_read do |key, card, timeout, result|
    EmvFlow.start
    mag     = Device::Magnetic.new
    emv     = PosxmlEmv.transaction
    timeout = Time.now + timeout.to_i

    while true
      key_pressed = getc(900)
      if key_pressed != Device::IO::KEY_TIMEOUT
        key.value = key_pressed
        break
      elsif mag.swiped?
        tracks = mag.tracks
        card.value = "#{tracks[:track1]}=#{tracks[:track2]}"
        result.value = 0
        break
      elsif emv && emv.detected?
        emv.process
        result.value = 1
        break
      elsif timeout > Time.now
        result.value = -2
        break
      end
    end
  ensure
    mag.close
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

  def parse_menu_selection(options)
    options.split(".").each_with_index.inject({}) do
      |hash, values| hash[values[0]] = values[1]; hash
    end
  end

  interface_menu do |variable,options|
    variable.value = menu(nil, parse_menu_selection(options.value), number: false)
  end

  # TODO Scalone: Missing some implementation:
  #  - Title hot swapping.
  #  - Title datetime.
  interface_menu_header do |header, selection, timeout_header, timeout, variable|
    options = { number: false, timeout: timeout.value.to_i*1000 }
    variable.value = menu(header.value, parse_menu_selection(selection.value), options)
  end

  interface_display do |column, line, text|
    Device::Display.print_line(text.value, line.value.to_i, column.value.to_i)
  end

  interface_display_bitmap do |filename, variable|
    Device::Display.print_bitmap(posxml_file_path(filename.value), 0, 0)
    variable.value = 0
  end

  interface_clean_display { Device::Display.clear }

  interface_system_get_touchscreen do |axis_x, axis_y, variable|
    # TODO Implement
    variable.value = 0
  end

  print     { |v| Device::Printer.print v.value }
  print_big { |v| Device::Printer.print_big v.value }

  print_barcode do |horizontal, number|
    # TODO Implement
  end

  print_bitmap do |filename, variable|
    Device::Printer.print_bmp(posxml_file_path(filename.value))
  end

  print_check_paper_out { |variable|}
  print_paper_feed      {  }

  input_float do |variable, line, column, message|
    total_input = ""
    @pause = true
    read = Proc.new do |input, remove|
      if input == "KEY_X"
        variable.value = -2
        @pause = false
        posxml_loop_next
      elsif input != "ENTER" # The green button
        total_input = total_input[0..-2] if remove
        total_input << input
        $device.display(0, line.value, message.value+total_input)
        $device.read(&read)
      else
        variable.value = total_input
        @pause = false
        posxml_loop_next
      end
    end
    $device.display(0, line.value, message.value + (variable.value ? variable.value : ""))
    $device.prompt "Click any button to continue."
    $device.read(&read)
  end

  input_integer do |variable, line, column, message, min, max|
    total_input = ""
    @pause = true
    read = Proc.new do |input, remove|
      if input == "KEY_X"
        variable.value = -2
        @pause = false
        posxml_loop_next
      elsif input != "ENTER" # The green button
        total_input = total_input[0..-2] if remove
        total_input << input
        $device.display(0, line.value, message.value+total_input)
        $device.read(&read)
      else
        variable.value = total_input
        @pause = false
        posxml_loop_next
      end
    end
    $device.display(0, line.value, message.value + (variable.value ? variable.value : ""))
    $device.prompt "Click any button to continue."
    $device.read(&read)
  end

  input_option do |var, line, column, message, min, max|
    input_integer(var, line, column, message, min, max)
  end

  input_money do |v, line, column, message|
    options = Hash.new
    options[:label]  = message.value
    options[:line]   = line.value.to_i
    options[:column] = column.value.to_i
    options[:mode]   = Device::IO::IO_INPUT_MONEY

    v.value = Device::IO.get_format(0, 20, options)
  end

  input_format do |variable, line, column, message, format|
    options = Hash.new
    options[:label]  = message.value
    options[:line]   = line.value.to_i
    options[:column] = column.value.to_i

    if format.value[0] == "*"
      options[:mode] = Device::IO::IO_INPUT_SECRET
    else
      options[:mode] = Device::IO::IO_INPUT_MASK
      options[:mask] = format.value
    end
    variable.value = Device::IO.get_format(0, 20, options)
  end

  input_getvalue do |empty, caption, columnC, lineC, columnI, lineI, max, min, var|
  end

  crypto_encryptdecrypt do |message,key,cryptotype,type,variablereturn|
    # Should be implemented by platform
  end

  crypto_lrc do |buffer,size,variablereturn|
    # Should be implemented by platform
  end

  crypto_xor do |buffer1,buffer2,size,variablereturn|
    # Should be implemented by platform
  end

  crypto_crc do |buffer,size,crctype,variablereturn|
    # Should be implemented by platform
  end

  file_list do |dir, listfilename, var|
    begin
      if dir.value == "I"
        File.open("./"+listfilename.value, 'w') { |f| f.write("") }
        var.value = 0
      elsif dir.value == "F"
        files = Dir.entries(".")
        list  = ""
        files.each do |f|
          parts = f.split(".")
          if parts.size > 1
            ext = parts[1]
            if ext.size > 1
              list << "#{f}=\"#{File.size(f)}\"\n"
            end
          end
        end
        File.open("./"+listfilename.value, 'w') { |f| f.write(list) }
        var.value = 0
      else
        var.value = -1
      end
    rescue Exception => e
      var.value = -1
    end
  end

  # Won't be implemented
  file_system_space { |dir, type, variable| }

  file_open do |mode, filename, variable|
    name = filename.value
    variable.value = @files.length
    # Saving a copy of the file index in a local variable,
    # We could use File.open here, but everything is already in memory.
    @files.push name
    $device.rememberFile name
  end

  file_close do
    # Nothing to do here
  end

  file_read do |handle, size, buffer, variable|
    b16 = $device.readFile(@files[handle.value])
    variable.value = b16.length
    buffer.value = b16.unpack("H*").join("")
  end

  file_write do |handle, size, buffer|
    name = @files[handle.value]
    size = size.value * 2 # This is necessary
    $device.writeFile(name, buffer.value[0..size-1], File.exists?(name) && File.size(name) > 0)
  end

  file_read_by_index do |filename, index, key, value, var|
    var.value = 0
    if File.exist?(filename)
      file = File.open(filename, "r")
      i = 0
      file.read.each_line do |line|
        parts = line.chomp().split("=")
        line_key, line_value = parts[0], parts[1]
        if i == index
          value.value = line_value
          key.value   = line_key
          var.value = 1
          return
        end
        i += 1
      end
      file.close
    end
  end

  file_unzip {|filename, variablereturn| }

  iso8583_init_field_table do |filename,variablereturn|
    # Should be implemented by platform
  end

  iso8583_init_message do |format,id,variablemessage,variablereturn|
    # Should be implemented by platform
  end

  iso8583_analyze_message do |format,size,variablemessage,variableid,variablereturn|
    # Should be implemented by platform
  end

  iso8583_end_message do |variablesize,variablereturn|
    # Should be implemented by platform
  end

  iso8583_put_field do |fieldnumber,type,value,variablereturn|
    # Should be implemented by platform
  end

  iso8583_get_field do |fieldnumber,type,variablevalue,variablereturn|
    # Should be implemented by platform
  end

  iso8583_transact_message do |channel,header,trailler,isomsg,variableresponse,variablereturn|
    # Should be implemented by platform
  end

  iso8583_transact_message_sub_field do |channel,header,trailler,variablereturn|
    # Should be implemented by platform
  end

  serial_open_port do |port,rate,configuration,variablereturn|
    # Should be implemented by platform
  end

  serial_read_port do |variablehandle,variablebuffer,bytes,timeout,variablereturn|
    # Should be implemented by platform
  end

  serial_write_port do |variablehandle,buffer|
    # Should be implemented by platform
  end

  serial_close_port do |variablehandle|
    # Should be implemented by platform
  end

  datetime_calculate do |operation, type, date1, date2, value, var|
    # operation can be: sum, less, difference
    # type can be: years, months, days, hours, minutes or seconds
    # type is not used on a difference operation
    var.value = 0
    case operation.value
    when "sum"
      date1.value = $device.dateSum(date1.value, type.value, value.to_i)
    when "less"
      date1.value = $device.dateSum(date1.value, type.value, -value.to_i)
    when "difference"
      var.value = $device.dateDiff(date1.value, date2.value)
    else
      var.value = -1
    end
  end

  network_pre_dial do |option, var|
    # Should be implemented by platform
  end

  network_shutdown_modem do
    @socket.close
  end

  network_check_gprs_signal {|v| }

  network_ping do |host, var|
    @pause = true
    ping = Proc.new do |result|
      var.value = result
      @pause = false
      posxml_loop_next
    end
    $device.ping(host.value, &ping)
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

  v_getinfo do |type,parameter,value|
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

  smartcard_transmit_APDU do |slot,header,LC,datafield,LE,variabledatafieldresponse,variableSW,variablereturn|
    # Should be implemented by platform
  end

  util_system_beep do
    @pause = true
    $device.beep do
      @pause = false
      posxml_loop_next
    end
  end

  util_system_checkbattery {|v| v.value = Device::System.battery }

  util_system_info do |type, var|
    case type.value
    when "simid"
      var.value = "11111 22222 33333 44444"
    when "macaddress"
      var.value = "01-02-03-04-05-0b"
    when "osversion"
      var.value = "emulator"
    when "libsversion"
      var.value = "emulator"
    when "is3g"
      var.value = "0"
    end
  end

  util_system_restart do
    @pause = true
    $device.close "POSXML restart.", 1
  end

  util_system_qrcode do |filename, input, size, version|
    # Should be implemented by platform
  end

  util_wait_key { getc }
  util_wait_key_timeout {|timeout_milliseconds| getc(timeout_milliseconds.to_i) }

  util_wait do |milliseconds|
    @pause = true
    callback = Proc.new do
      @pause = false
      posxml_loop_next
    end
    MrubyJs.window.setTimeout(callback, milliseconds.to_i)
  end

  util_read_key { |timeout_milliseconds, v| v.value = getc(timeout_milliseconds)}

  util_parse_ticket do |productmenu,ticket,message,literal,variablereturn|
    # Should be implemented by platform
  end

  def manual_card_input(msg1, msg2, min, max, var)
    total_input = ""
    max = max.to_i
    min = min.to_i
    n_spaces = max - min + 1
    spaces = " "
    spaces *= n_spaces if n_spaces > 0
    # $device.display(0, 2, msg1.value)
    line = msg2.value.size > screen_columns ? 4 : 3
    $device.display(0, 2, msg2.value)
    $device.display(0, line, ": " + spaces)
    read = Proc.new do |input, remove|
      if input == "KEY_X"
        @pause = false
        util_exit
        posxml_loop_next
      elsif !remove && ((input == "ENTER" && (total_input.size >= min)) || total_input.size >= max)
        $device.clear(nil)
        var.value = "D" + total_input
        @pause = false
        posxml_loop_next
      elsif !((remove && input == "") || input.match(/[0-9]/))
        $device.read(&read)
      elsif (total_input.size < max) || remove
        if remove
          total_input = total_input[0..-2]
        end
        total_input << input
        $device.display(0, 2, msg2.value)
        $device.display(0, line, ": " + total_input)
        $device.read(&read)
      end
    end
    $device.prompt("Click any button to continue.")
    @pause = true
    $device.read(&read)
  end

  def start
    # TODO Scalone: Check configuration
    #posxml_configure!("", $device.executingAppName(nil), false)
    #posxml_write_db_config("ipHost", $device.ipHost(nil))
    #posxml_write_db_config("serialTerminal", $device.serialTerminal(nil))
    #posxml_write_db_config("numeroLogico", $device.logicalNumber(nil))

    posxml_loop do
      posxml_next
    end
  end
end

