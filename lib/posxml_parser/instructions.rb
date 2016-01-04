
module PosxmlParser
  module Instructions
    def flow_if(jump_point, variable1, operator, variable2)
      posxml_conditional(jump_point, variable1, operator, variable2)
    end

    def flow_else(jump_point)
      posxml_jump!(jump_point.value)
    end

    def flow_end_if
    end

    def flow_execute(file_name)
      posxml_load!(file_name.value)
    end

    def flow_function(jump_point, function_name)
      posxml_jump!(jump_point.value)
    end

    def flow_function_call(jump_point, function_name)
      # Push current
      posxml_push_function(number - 1)
      posxml_jump!(jump_point.value)
    end

    def flow_function_end
      posxml_pop_function
    end

    def flow_while(jump_point, variable1, operator, variable2)
      posxml_conditional(jump_point, variable1, operator, variable2)
    end

    def flow_while_break(jump_point)
      posxml_jump!(jump_point.value)
    end

    def flow_while_end(jump_point)
      posxml_jump!(jump_point.value)
    end

    def util_exit
      posxml_load!(file_main)
    end

    def string_variable(value, index)
      posxml_define_variable(value.value, index.value)
    end

    def integer_variable(value, index)
      posxml_define_variable(value.value, index.value)
    end

    def file_download(file_name, remote_path, variable)
      variable.value = -5
      return unless socket?

      file_path = posxml_file_path(file_name.value)
      variable.value = Device::Transaction::Download.request_file(remote_path.value, file_path)
    end

    def file_size(file_name, result)
      path = posxml_file_path(file_name.value)
      result.value = File.exists?(path) ? File.size(path) : -1
    end

    def file_delete(file_name)
      begin
        File.delete(file_name.value)
      rescue Errno::ENOENT
      end
    end

    def file_rename(old, new, variable)
      if File.exists?(old.value)
        File.rename(old.value, new.value)
        variable.value = 0 # OK
      else
        variable.value = -1 # NOT OK
      end
    end

    def file_edit_db(file_name, key, value)
      if file_name.value == "config.dat"
        posxml_write_db_config(key.value, value.value)
      else
        file = FileDb.new(posxml_file_path(file_name.value))
        file.update_attributes({key.value => value.value})
      end
    end

    def file_read_db(file_name, key, string)
      if file_name.value == "config.dat"
        string.value = posxml_read_db_config(key.value)
      else
        string.value = FileDb.new(posxml_file_path(file_name.value))[key.value]
      end
    end

    def file_list(dir, listfilename, var)
      begin
        path = posxml_file_path(listfilename.value)
        File.delete(path) if File.exists?(path)
        file = FileDb.new("./#{path}", {})
        Dir.entries.inject({}) do |entry,hash|
          fpath = posxml_file_path(entry)
          hash[entry] = File.size(fpath) if File.file?(fpath) && entry != ".." && entry != "."
        end
        file.update_attributes(hash)
        variablereturn.value = 0
      rescue
        variablereturn.value = -1
      end
    end

    def file_open(mode, filename, variable)
      @files ||= []
      @files << File.open(posxml_file_path(filename.value), mode.value)
      variable.value = (@files.size - 1)
    end

    def file_close(handle)
      file = @files[handle.to_i]
      file.close if file
    end

    def file_read(handle, size, buffer, variable)
      file = @files[handle.to_i]
      buffer.value   = file.read.to_s.unpack("H*").first
      variable.value = buffer.value.size / 2
      size.value     = variable.value
    end

    def file_write(handle, size, buffer)
      file = @files[handle.value]
      buf = buffer.value[0..(size.to_i * 2 - 1)]
      file.syswrite(buf)
    end

    def file_read_by_index(filename, index, key, value, var)
      var.value = 0
      path = posxml_file_path(filename.value)
      if File.exist?(path)
        file = File.open(path, "r")
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

    def file_unzip(filename, variablereturn)
      begin
        Zip.uncompress(filename.value, posxml_file_path(""))
        variablereturn.value = 0
      rescue
        variablereturn.value = -1
      end
    end

    def network_send(buffer, size, variable)
      if socket? && socket.send(buffer.to_s, 0) > 0
        variable.value = 1
      else
        variable.value = 0
      end
    end

    def network_receive(buffer, max_size, bytes, variable)
      variable.value = 0
      buffer.value = ""
      if socket?
        timeout = Time.now + posxml_read_db_config("uclreceivetimeout").to_i
        loop do
          buffer.value << socket.read(bytes.value) if socket.bytes_available > 0
          break if (timeout > Time.now) || buffer.value.size >= max_size.to_i
          usleep 500_000
        end
      end
    ensure
      # 1 - Success; 0 - Failure
      bytes.value = buffer.value.size
      variable.value = 1 if bytes.value > 0
    end

    def network_host_disconnect
      socket.close if socket?
    end

    def network_pre_connect(variable)
      variable.value = Device::Network.attach
      if variable.value == 0
        socket.close if socket?
        @socket = Device::Network.socket
      end
    end

    def network_shutdown_modem
      @socket.close
    end

    def network_check_gprs_signal(variablestatus)
      variablestatus.value = Device::Network.signal
    end

    def network_ping(host,variablereturn)
      variablereturn.value = Device::Network.ping(host.value, 14000)
    end

    def datetime_get(format_string, string)
      time = Time.now
      string.value = format_string.value.sub("yy", time.year.to_s).
        sub("y", time.year.to_s[2..3]).
        sub("M", time.month.to_s).
        sub("d", time.day.to_s).
        sub("h", time.hour.to_s).
        sub("m", time.min.to_s).
        sub("s", time.sec.to_s)
    end

    def datetime_calculate(operation, type, date1, date2, value, var)
      # operation can be: sum, less, difference
      # type can be: years, months, days, hours, minutes or seconds
      # type is not used on a difference operation
      var.value = 0
      case operation.value
      when "sum"
        result = posxml_date_to_time(date2.value) - posxml_date_to_seconds(type.to_s, value.to_i)
        date1.value = posxml_time_to_date(result)
      when "less"
        result = posxml_date_to_time(date2.value) + posxml_date_to_seconds(type.to_s, value.to_i)
        date1.value = posxml_time_to_date(result)
      when "difference"
        var.value = (posxml_date_to_time(date2.to_s) - posxml_date_to_time(date1.to_s)).to_i
      else
        var.value = -1
      end
    end

    def util_math(result, operator, variable1, variable2)
      result.value = variable1.compare(operator, variable2)
    end

    def string_to_hex(string, hex)
      hex.value = string.value.to_s.unpack('H*').first
    end

    def string_hex_to_string(hex, string)
      string.value = [hex.value.to_s].pack('H*')
    end

    def string_join(string1, string2, result)
      result.value = "#{string1.value}#{string2.value}"
    end

    def binary_convert_to_integer(base, string, integer)
      case base.value
      when "2"
        integer.value = string.value.to_i(2)
      when "10"
        integer.value = string.value.to_i(16)
      when "16"
        integer.value = string.value.to_i(16)
      end
    end

    def integer_convert_to_binary(number, base, size, variable)
      binary = number.to_i.to_s(base.to_i)
      if binary.size < size.to_i
        if base.to_i == 2
          binary = ("0" * (size.to_i/4 - binary.size)) + binary
        else
          binary = ("0" * (size.to_i - binary.size)) + binary
        end
      end
      variable.value = binary.upcase
    end

    def integer_to_string(integer, string)
      string.value = integer.value.to_s
    end

    def integer_operator(operator, integer)
      if operator.value == "++"
        integer.value = integer.to_i + 1
      elsif operator.value == "--"
        integer.value = integer.to_i - 1
      end
    end

    def string_length(string, variable)
      variable.value = string.value.to_s.size
    end

    def string_string_substring(string, start, length, substring)
      substring.value = string.value[start.value.to_i, length.value.to_i]
    end

    def string_to_integer(string, integer)
      integer.value = string.value.to_i
    end

    def string_char_at(string, index, variable)
      variable.value = string.value[index.to_i]
    end

    def string_element_at(string, index, delimiter, variable)
      variable.value = string.value.split(delimiter.value)[index.to_i]
    end

    def string_elements(string, delimiter, variable)
      variable.value = string.to_s.split(delimiter.value).size
    end

    def string_find(str, sub, start, variable)
      str = str.value
      sub = sub.value
      start = start.value.to_i
      if str && str.size > start
        index = str.index(sub)
        variable.value = index == nil ? -1 : (index >= start ? index - start : -1)
      else
        variable.value = -1
      end
    end

    def string_get_value_by_key(string, key, variable)
      index = string.value.index(key.value+"=")
      if index
        from_index = string.value[index+key.value.size+1..-1]
        last_quote_index = from_index.rindex("\"")
        from_index = from_index[0..last_quote_index] + "," + from_index[last_quote_index..-1]
        variable.value = from_index.split("\",")[0]
      end
    end

    def string_trim(str, variable)
      strip = str.value.strip
      variable.value = strip if strip
    end

    def string_insert_at(string, insert, index, delimiter, variable)
      parts    = string.value.split(delimiter.value)
      index    = index.to_i
      head     = parts[0..(index-1)]
      head[-1] = head[-1]+insert.value
      tail     = parts[(index)..-1]
      variable.value = head.join(delimiter.value) + tail.join(delimiter.value)
    end

    def string_pad(origin, char, align, length, destination)
      length = length.to_i - origin.value.size
      chars = char.value * length
      case align.value
      when "left"
        destination.value = chars + origin.value
      when "right"
        destination.value = origin.value + chars
      end
    end

    def string_remove_at(original, index, delimiter, variable)
      parts = original.value.split(delimiter.value)
      parts.delete_at(index.value.to_i)
      variable.value = parts.join(delimiter.value)
    end

    def string_replace(original, old, new, variable)
      sub = original.value.gsub old.value, new.value
      variable.value = sub ? sub : original.value
    end

    def string_replace_at(string, replace, index, delimiter, variable)
      parts = string.value.split(delimiter.value)
      index = index.to_i
      parts[index] = replace.value
      variable.value = parts.join(delimiter.value)
    end

    def string_substring(index, source, destination, char, variable)
      parts = source.to_s.split(char.to_s)
      if index.to_i >= 0 && parts.size > index.to_i
        destination.value = parts[index.to_i]
        variable.value = index.to_i
      else
        variable.value =  -1
      end
    end

    def iso8583_init_field_table(filename,variablereturn)
      @iso8583_filename = filename.value
      variablereturn.value = 0
    end

    def iso8583_init_message(format,id,variablemessage,variablereturn)
      begin
        iso_format = format.value == "ASCII" ? ISO8583::N : ISO8583::LL_BCD
        @iso_klass = ISO8583::FileParser.build_klass([iso_format, {length: 4}],
          {id.value.to_i => ""}, posxml_file_path(@iso8583_filename))
        variablereturn.value = 0
      rescue
        variablereturn.value = -801
      end
    end

    def iso8583_analyze_message(format,size,variablemessage,variableid,variablereturn)
      begin
        iso_format = format.value == "ASCII" ? ISO8583::N : ISO8583::LL_BCD
        @iso_klass.instance_eval { 
          mti_format iso_format, :length => 4 
          mti variableid.to_i, ""
        }
        @iso_analyzed = @iso_klass.parse(variablemessage.value, true)
        variablereturn.value = 0
      rescue
        variablereturn.value = -806
      end
    end

    def iso8583_end_message(variablesize,variablereturn)
      begin
        @iso_binary = @iso.to_b
        variablesize.value = @iso_binary.size
        variablereturn.value = 0
      rescue
        variablereturn.value = -801
      end
    end

    def iso8583_put_field(fieldnumber,type,value,variablereturn)
      begin
        @iso[fieldnumber.to_i] = value.value
        variablereturn.value = 0
      rescue
        variablereturn.value = -801
      end
    end

    def iso8583_get_field(fieldnumber,type,variablevalue,variablereturn)
      begin
        variablevalue.value = @iso_analyzed[fieldnumber.to_i]
        variablereturn.value = 0
      rescue
        variablereturn.value = -801
      end
    end

    # TODO Implement others channels
    #  0: Size of the response message
    # -1: Channel unknown or not implemented
    # -2: Failed to connect to the host or while attempting to dial
    # -3: Failed to send send the message to the host authorizer
    # -4: Failed to receive the size of the response message
    def iso8583_transact_message(channel,header,trailler,isomsg,variableresponse,variablereturn)
      # -1: Channel unknown or not implemented
      return(variablereturn.value = -1) unless channel.value == "NAC"

      # -2: Failed to connect to the host or while attempting to dial
      return(variablereturn.value = -2) if Device::Network.connected? != 0

      message      = "#{header.value}#{@iso_binary}#{trailler.value}"
      size         = message.size + 2
      message      = "#{[size].pack("n*")}#{message}"
      isomsg.value = message

      # Send
      # -3: Failed to send send the message to the host authorizer
      return(variablereturn.value = -3) unless socket.send(message)

      # Receive
      variablereturn.value = socket.read(2).to_s.unpack("n*")[0].to_s

      # -4: Failed to receive the size of the response message
      return(variablereturn.value = -4) if variableresponse.value.empty?

      timeout = Time.now + posxml_read_db_config("uclreceivetimeout").to_i
      attempts = 1
      loop do
        variableresponse.value << socket.read(size) if socket.bytes_available > 0
        break if variableresponse.value.size >= size
        if (timeout > Time.now)
          # -5: Failed to receive the response message
          break(variablereturn.value = -5) if attempts >= 3
          timeout = Time.now + posxml_read_db_config("uclreceivetimeout").to_i
          attempts+=1
        end
        usleep 500_000
      end
    end

    def util_system_beep
      Device::Audio.beep(0, 200)
    end

    def util_system_checkbattery(variablereturn)
      variablereturn.value = Device::System.battery
    end

    # TODO Scalone: Low priority implementation
    def util_system_info(type,variablereturn)
      case type.value
      when "simid"
        variablereturn.value = " "
      when "macaddress"
        variablereturn.value = " "
      when "osversion"
        variablereturn.value = " "
      when "libsversion"
        variablereturn.value = " "
      when "gprssignal"
        variablereturn.value = Device::Network.signal
      when "wifisignal"
        variablereturn.value = Device::Network.signal
      when "is3g"
        variablereturn.value = 0
      end
    end

    def util_system_restart
      Device::System.restart
    end

    def util_system_qrcode(filename, input, size, version)
      begin
        qr = QR.new(input.value, version.to_i)
        result = qr.generate("bmp", size.to_s.gsub("x", "").to_i)
        file = File.open(posxml_file_path(filename.value), "w")
        file.write result
        file.close
      end
    end

    def util_wait_key
      getc
    end

    def util_wait_key_timeout(seconds)
      getc(seconds.to_i*1000)
    end

    def util_wait(milliseconds)
      usleep timeout_milliseconds.to_i * 1000
    end

    def util_read_key(timeout_milliseconds, v)
      v.value = getc(timeout_milliseconds)
    end

    def card_get_variable(msg1, msg2, min, max, var)
      Device::Display.clear
      Device::Display.print_line(msg1.value, 0, 2)
      tracks = Device::Magnetic.read_card(Device::IO.timeout)
      var.value = "#{tracks[:track1]}=#{tracks[:track2]}"
    end

    def card_read(key, card, timeout, result)
      begin
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
    end

    def interface_menu(variable,options)
      variable.value = menu(nil, posxml_parse_menu_selection(options.value), number: false)
    end

    # TODO Scalone: Missing some implementation:
    #  - Title hot swapping.
    #  - Title datetime.
    def interface_menu_header(header, selection, timeout_header, timeout, variable)
      options = { number: false, timeout: timeout.value.to_i*1000 }
      variable.value = menu(header.value, posxml_parse_menu_selection(selection.value), options)
    end

    def interface_display(column, line, text)
      Device::Display.print_line(text.value, line.value.to_i, column.value.to_i)
    end

    def interface_display_bitmap(filename, variable)
      Device::Display.print_bitmap(posxml_file_path(filename.value), 0, 0)
      variable.value = 0
    end

    def interface_clean_display
      Device::Display.clear
    end

    def interface_system_get_touchscreen(axis_x, axis_y, variable)
      # TODO Scalone: Low priority implementation. A DaFunk touchscreen interface
      # is neecesary to be implemented.
      variable.value = 0
    end

    def input_money(v, line, column, message)
      options = Hash.new
      options[:label]  = message.value
      options[:line]   = line.value.to_i
      options[:column] = column.value.to_i
      options[:mode]   = Device::IO::IO_INPUT_MONEY

      v.value = Device::IO.get_format(0, 20, options)
    end

    def input_format(variable, line, column, message, format)
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

    def print(v)
      Device::Printer.print v.value
    end

    def print_big(v)
      Device::Printer.print_big v.value
    end

    def print_barcode(horizontal, number)
      # TODO Scalone: Low priority implementation. A DaFunk touchscreen interface
      # is neecesary to be implemented.
    end

    def print_bitmap(filename, variable)
      Device::Printer.print_bmp(posxml_file_path(filename.value))
    end

    def print_check_paper_out(variable)
      variable.value = Device::Printer.check
    end

    def print_paper_feed
      Device::Printer.paperfeed
    end

    def iso8583_transact_message_sub_field(channel,header,trailler,variablereturn)
      # Deprecated, shouldn't be implemented
    end

    def card_get(msg1, msg2, min, max, var)
      # Deprecated, shouldn't be implemented
    end

    # type:     1 for magstripe, 2 for chip, 3 for contactless, 4 for keyboard, 5 for touch.
    # keyboard: 1 for keybard enabled and 0 for keyboard disabled.
    # timeout:  In miliseconds in this case 30 seconds.
    # key:      When keyboard equals to 0, just returns with timeout or if you press KEY_CANCEL. If keyboard equals to 1 it will return all the pressed keys.
    # card:     It contains the track 2 and/or track 1 only when inputtype equals to 1.
    # var:      0 when a key is pressed or when the card input happens with success. -1 if it fails reading the tracks. -2 for timeout. For EMV chip or contactless: 1 for success, less than 1 for errors.
    def card_system_input_transaction(key, card, timeout, var, keyboard, type)
      # TODO Scalone: Low priority implementation
    end

    def input_float(variable,line,column,message)
      # Should be implemented by platform
    end

    def input_integer(variable,line,column,message,minimum,maximum)
      # Should be implemented by platform
    end

    def input_option(variable,line,column,message,minimum,maximum)
      # Should be implemented by platform
    end

    def input_money(variable,line,column,message)
      # Should be implemented by platform
    end

    def input_format(variable, line, column, message, type)
      # Should be implemented by platform
    end

    def input_getvalue(linecaption,columncaption,caption,lineinput,columninput,minimum,maximum,allowsempty,variablereturn)
      # Should be implemented by platform
    end

    def crypto_encryptdecrypt(message,key,cryptotype,type,variablereturn)
      # Should be implemented by platform
    end

    def crypto_lrc(buffer,size,variablereturn)
      # Should be implemented by platform
    end

    def crypto_xor(buffer1,buffer2,size,variablereturn)
      # Should be implemented by platform
    end

    def crypto_crc(buffer,size,crctype,variablereturn)
      # Should be implemented by platform
    end

    def file_system_space(dir, type, variable)
      # Should be implemented by platform
    end

    def serial_open_port(port,rate,configuration,variablereturn)
      # Should be implemented by platform
    end

    def serial_read_port(variablehandle,variablebuffer,bytes,timeout,variablereturn)
      # Should be implemented by platform
    end

    def serial_write_port(variablehandle,buffer)
      # Should be implemented by platform
    end

    def serial_close_port(variablehandle)
      # Should be implemented by platform
    end

    def datetime_adjust(datetime)
      # Deprecated, shouldn't be implemented
    end

    def network_pre_dial(option,variablestatus)
      # Should be implemented by platform
    end

    def pinpad_open(type,variableserialnumber,variablereturn)
      # Should be implemented by platform
    end

    def pinpad_display(message)
      # Should be implemented by platform
    end

    def pinpad_getkey(message,timeout,variablereturn)
      # Should be implemented by platform
    end

    def pinpad_getpindukpt(message,type,pan,maxlen,variablereturnpin,variablereturnksn,variablereturn)
      # Should be implemented by platform
    end

    def pinpad_loadipek(ipek,ksn,type,variablereturn)
      # Should be implemented by platform
    end

    def pinpad_close(message)
      # Should be implemented by platform
    end

    def emv_open(variablereturn,mkslot,pinpadtype,pinpadwk,showamount)
      # Should be implemented by platform
    end

    def emv_close(variablereturn)
      # Should be implemented by platform
    end

    def emv_loadtables(acquirer,variablereturn)
      # Should be implemented by platform
    end

    def emv_settimeout(seconds,variablereturn)
      # Should be implemented by platform
    end

    def emv_cleanstructures
      # Should be implemented by platform
    end

    def emv_adddata(type,parameter,value,variablereturn)
      # Should be implemented by platform
    end

    def emv_getinfo(type,parameter,value)
      # Should be implemented by platform
    end

    def emv_inittransaction(variablereturn)
      # Should be implemented by platform
    end

    def emv_processtransaction(variablereturn,ctls)
      # Should be implemented by platform
    end

    def emv_finishtransaction(variablereturn)
      # Should be implemented by platform
    end

    def emv_removecard(variablereturn)
      # Should be implemented by platform
    end

    def smartcard_insert_card(slot,variablereturn)
      # Should be implemented by platform
    end

    def smartcard_reader_close(slot,variablereturn)
      # Should be implemented by platform
    end

    def smartcard_reader_start(slot,variablereturn)
      # Should be implemented by platform
    end

    def smartcard_transmit_APDU(slot,header,lc,datafield,le,variabledatafieldresponse,variableSW,variablereturn)
      # Should be implemented by platform
    end

    def util_parse_ticket(productmenu,ticket,message,literal,variablereturn)
      # Should be implemented by platform
    end

    private
    def socket?
      socket
    end
  end
end

