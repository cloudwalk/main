
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
      posxml_jump!(jump_point.value)
      # Push current
      posxml_push_function(number)
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

      crc = ""
      if File.exists?(file_path)
        file = File.open(file_path, "r")
        crc = PosxmlParser::Crc16.crc16(file.read).to_s
        file.close
      end

      @downloader  ||= PosxmlParser::Download.new(posxml_read_db_config("serialTerminal"), path)
      variable.value = @downloader.riak_mapreduce_request(
        @socket,
        posxml_read_db_config("walkServer3CompanyName"),
        remote_path.value, crc,
        posxml_read_db_config("executingAppName"),
        posxml_read_db_config("numeroLogico"))
    end

    def file_size(file_name, result)
      result.value = File.size(posxml_file_path(file_name.value))
    end

    def file_delete(file_name)
      begin
        File.delete(file_name.value)
      rescue Errno::ENOENT
      end
    end

    def file_edit_db(file_name, key, value)
      posxml_write_db(file_name.value, key.value, value.value)
    end

    def file_read_db(file_name, key, string)
      string.value = posxml_read_db(file_name.value, key.value)
    end

    def network_send(buffer, size, variable)
      if socket?
        #TODO Use send/puts socket.puts(buffer.to_s)
        socket.send(buffer.to_s, 0)
        variable.value = 1
      else
        variable.value = 0
      end
    end

    def network_receive(buffer, max_size, bytes, variable)
      variable.value = 0
      if socket?
        #TODO Extract timeout
        buffer.value = Timeout::timeout(14) { @socket.recv(max_size.to_i) }.to_s
      end
    rescue Timeout::Error
      # Do nothing to not raise, ensure have the logic
    ensure
      # 1 - Success; 0 - Failure
      bytes.value = buffer.value.size
      variable.value = 1 if bytes.value > 0
    end

    def network_host_disconnect
      socket.close if socket?
    end

    def network_pre_connect(variable)
      # TODO Extract errors
      posxml_execute_thread(true) do
        @socket = TCPSocket.open(posxml_read_db_config("ipHost"), posxml_read_db_config("portaHost")) unless socket?
      end

      variable.value = -1
      if socket?
        hand_shake = "#{posxml_read_db_config("serialTerminal")};#{posxml_read_db_config("executingAppName")};#{posxml_read_db_config("numeroLogico")};#{posxml_read_db_config("version")}"

        posxml_execute_thread { socket.write hand_shake.insert(0, hand_shake.size.chr) }
        posxml_execute_thread(true) { @message = socket.read(3) }

        if (@message != "err" && @message)
          posxml_write_db_config("walkServer3CompanyName", @message)
          variable.value = 1
        end
      end
    end

    #TODO Refactory need
    def datetime_get(format_string, string)
      format = format_string.value
      format.match(/yy/) == nil ? format = format.gsub(/y/, "\%y") : format = format.gsub(/yy/, "\%Y")

      format = format.gsub(/M/, "\%m")
      format = format.gsub(/d/, "\%d")
      format = format.gsub(/h/, "\%H")
      format = format.gsub(/m/, "\%M")
      format = format.gsub(/s/, "\%S")
      #To fix month and minutes confusion
      format = format.gsub(/%%M/, "\%m")

      datetime = Time.now

      string.value = datetime.strftime(format)
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

    def card_get_variable(msg1, msg2, min, max, var)
      # Should be implemented by platform
    end

    def card_get(msg1, msg2, min, max, var)
      # Deprecated, shouldn't be implemented
    end

    def card_read(key, card, timeout, result)
      # Should be implemented by platform
    end

    def card_system_input_transaction(key, card, timeout, var, keyboard, type)
      # Should be implemented by platform
    end

    def interface_menu(variable, options)
      # Should be implemented by platform
    end

    def interface_menu_header(header, options, timeout_header, timeout, variable)
      # Should be implemented by platform
    end

    def interface_display(column, line, text)
      # Should be implemented by platform
    end

    def interface_display_bitmap(file_name, variable)
      # Should be implemented by platform
    end

    def interface_clean_display
      # Should be implemented by platform
    end

    def interface_system_get_touchscreen(axis_x, axis_y, variable)
      # Should be implemented by platform
    end

    def print(message)
      # Should be implemented by platform
    end

    def print_big(message)
      # Should be implemented by platform
    end

    def print_barcode(number)
      # Should be implemented by platform
    end

    def print_bitmap(filename)
      # Should be implemented by platform
    end

    def print_check_paper_out(variable)
      # Should be implemented by platform
    end

    def print_paper_feed
      # Should be implemented by platform
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

    def file_list(dir,listfilename,variablereturn)
      # Should be implemented by platform
    end

    def file_system_space(dir, type, variable)
      # Should be implemented by platform
    end

    def file_open(mode,filename,variablehandle)
      # Should be implemented by platform
    end

    def file_close(handle)
      # Should be implemented by platform
    end

    def file_read(handle,size,variablebuffer,variablereturn)
      # Should be implemented by platform
    end

    def file_write(handle,size,buffer)
      # Should be implemented by platform
    end

    def file_read_by_index(filename,index,variablekey,variablevalue,variablereturn)
      # Should be implemented by platform
    end

    def file_unzip(filename,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_init_field_table(filename,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_init_message(format,id,variablemessage,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_analyze_message(format,size,variablemessage,variableid,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_end_message(variablesize,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_put_field(fieldnumber,type,value,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_get_field(fieldnumber,type,variablevalue,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_transact_message(channel,header,trailler,isomsg,variableresponse,variablereturn)
      # Should be implemented by platform
    end

    def iso8583_transact_message_sub_field(channel,header,trailler,variablereturn)
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

    def datetime_calculate(operation,type,date,greaterdate,value,variablereturn)
      # Should be implemented by platform
    end

    def network_pre_dial(option,variablestatus)
      # Should be implemented by platform
    end

    def network_shutdown_modem
      # Should be implemented by platform
    end

    def network_check_gprs_signal(variablestatus)
      # Should be implemented by platform
    end

    def network_ping(host,variablereturn)
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

    def smartcard_transmit_APDU(slot,header,LC,datafield,LE,variabledatafieldresponse,variableSW,variablereturn)
      # Should be implemented by platform
    end

    def util_system_beep
      # Should be implemented by platform
    end

    def util_system_checkbattery
      # Should be implemented by platform
    end

    def util_system_info(type,variablereturn)
      # Should be implemented by platform
    end

    def util_system_restart
      # Should be implemented by platform
    end

    def util_wait_key
      # Should be implemented by platform
    end

    def util_wait_key_timeout(timeout_seconds)
      # Should be implemented by platform
    end

    def util_wait(timeout_milliseconds)
      # Should be implemented by platform
    end

    def util_read_key(timeout_milliseconds, variable)
      # Should be implemented by platform
    end

    def util_parse_ticket(productmenu,ticket,message,literal,variablereturn)
      # Should be implemented by platform
    end

    private
    def socket?
      socket && ! socket.closed?
    end
  end
end

