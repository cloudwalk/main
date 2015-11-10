class Interpreter
  include PosxmlParser
  include DaFunk::Helper

  network_check_gprs_signal {|v| }
  interface_clean_display { Device::Display.clear }
  util_system_checkbattery {|v| v.value = Device::System.battery }
  util_read_key { |timeout_milliseconds, v| v.value = getc(timeout_milliseconds)}
  util_wait_key_timeout {|timeout_milliseconds| getc(timeout_milliseconds) }
  util_wait_key { getc }

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

  # TODO: Missing some implementation
  interface_menu_header do |header, options, timeout_header, timeout, variable|
    options = { number: false, timeout: timeout.value.to_i*1000 }
    selection = options.split(".").each_with_index.inject({}) do
      |hash, values| hash[values[0]] = values[1]; hash
    end

    variable.value = menu(header.value, selection, options)
  end

  interface_display do |column, line, text|
    Device::Display.print_line(text.value, line.value.to_i, column.value.to_i)
  end

  interface_display_bitmap do |filename, variable|
    Device::Display.print_bitmap(shared_path(filename.value), 0, 0)
    variable.value = 0
  end

  # TODO Implement
  util_exit { }

  # TODO Won't be implemented
  file_system_space { |dir, type, variable| }

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

  card_get_variable do |msg1, msg2, min, max, var|
    Device::Display.clear
    Device::Display.print_line(msg1.value, 0, 2)
    tracks = Device::Magnetic.read_card(Device::IO.timeout)
    var.value = "#{tracks[:track1]}=#{tracks[:track2]}"
  end






  print_check_paper_out   { |r| r.value = 1 }
  print                   { |v| $device._print fixAccents v.value }
  print_big               { |v| $device._printBig fixAccents v.value }
  print_paper_feed        { $device._print " " }

  def print_barcode(horizontal, number)
    $device.printBarcode(number.value, horizontal.value)
  end

  def file_edit_db(file_name, key, value)
    $device.rememberFile file_name.value
    posxml_write_db(file_name.value, key.value, value.value)
  end

  def file_read_by_index(filename, index, key, value, var)
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

  file_open do |mode, filename, variable|
    name = filename.value
    variable.value = @files.length
    # Saving a copy of the file index in a local variable,
    # We could use File.open here, but everything is already in memory.
    @files.push name
    $device.rememberFile name
  end

  file_size do |filename, variable|
    variable.value = File.exists?(filename.value) ? File.size(filename.value) : 0
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

  file_close do
    # Nothing to do here
  end

  def file_rename(old, new, variable)
    if File.exists?(old.value)
      $io.renameFile(old.value, new.value)
      variable.value = 0 # OK
    else
      variable.value = -1 # NOT OK
    end
  end

  def file_delete(file_name)
    $io.unlink(file_name.value) if File.exists?(file_name.value)
  end

  def file_read_db(file_name, key, string)
    string.value = ""
    if File.exist?(file_name.value) && File.size(file_name.value) > 0
      index = $device.readFile(file_name.value).index(key.value+"=")
      if index && index > -1
        string.value = posxml_read_db(file_name.value, key.value)
        if string.value[0] == "\"" && string.value[-1] == "\""
          string.value = string.value[1..-2]
        end
        match_comma = string.value.scan(/.*[^\\]","/)
        if match_comma != nil && match_comma[0]
          string.value = match_comma[0][0..-4]
        end
      end
    end
  end

  def file_list(dir, listfilename, var)
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

  # On download.rb's function riak_mapreduce_request we have the following line:
  #     return_code = @first_packet[7].to_s.unpack("C*").first
  # It results in `0`, so we have to set the expected value (1) manually.
  def _file_download(file_name, remote_path, variable)
    $device.echo("Downloading #{remote_path.value} as #{file_name.value}...")
    @pause = true
    $device.timeout(300) do
      $io.unlink(file_name.value) if File.exists?(file_name.value)
      file_download(remote_path, file_name, variable)
      msg = "Failed to download #{remote_path.value} as #{file_name.value}."
      if variable.value == 0 && File.size(remote_path.value) > 0
        $device.rememberFile file_name.value
        $io.renameFile(remote_path.value, file_name.value)
        # If it still has the 0x6A at the end, let's remove it
        file = File.open("./"+file_name.value)
        content = file.read
        file.close
        if content[-1].to_s == "j"
          File.open("./"+file_name.value, 'w') { |f| f.write(content[0..-2]) }
        end
        msg = "Downloaded #{remote_path.value} as #{file_name.value}!"
        variable.value = 1
      end
      $device.echo(msg)
      $device.timeout(300) do
        @pause = false
        posxml_loop_next
      end
    end
  end

  def datetime_get(format, variable)
    variable.value = $device.getDate(format.value)
  end

  def datetime_calculate(operation, type, date1, date2, value, var)
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

  def datetime_adjust(date)
    p "WARNING: Command adjustdatetime has been deprecated. More information here: https://docs.cloudwalk.io/en/posxml/commands/adjustdatetime"
  end

  def network_ping(host, var)
    @pause = true
    ping = Proc.new do |result|
      var.value = result
      @pause = false
      posxml_loop_next
    end
    $device.ping(host.value, &ping)
  end

  def network_pre_dial(option, var)
    p "IMPORTANT: predial is not available in the web emulator"
  end

  def network_pre_connect(variable)
    host = posxml_read_db_config("ipHost")
    port = posxml_read_db_config("portaHost")
    $device.echo("Connecting to #{host}:#{port}")
    # Setting up a small delay so the above message can be seen before any
    # network connection.
    @pause = true
    $device.timeout(300) do
      # @socket = TCPSocket.open(host, port)
      @socket = SSocket.new(host, port)
      variable.value = -1
      hand_shake = "#{posxml_read_db_config("serialTerminal")};#{posxml_read_db_config("executingAppName")};#{posxml_read_db_config("numeroLogico")};#{posxml_read_db_config("version")}"
      hand_shake = hand_shake.size.chr << hand_shake # It doesn't have insert
      socket.send(hand_shake, hand_shake.size)
      @message = socket.read(3)
      msg = "Failed to connect."
      if (@message != "err" && @message != "") # It doesn't have .empty?
        msg = "Connected!"
        variable.value = 0
        posxml_write_db_config("walkServer3CompanyName", @message)
      end
      $device.echo(msg)
      $device.timeout(300) do
        local_name   = Variable.new("params.dat")
        if File.exists?(local_name.value) && File.size(local_name.value) > 0
          @pause = false
          posxml_loop_next
        else
          remote_name  = Variable.new("#{$device.logicalNumber(nil)}_params.dat")
          ret_variable = Variable.new("")
          _file_download(local_name, remote_name, ret_variable)
        end
      end
    end
  end

  def network_send(buffer, size, variable)
    $device.echo("Sending #{size.value} bytes...")
    @pause = true
    $device.timeout(300) do
      @pause = false
      @socket.write([buffer.value.to_s].pack("H*"))
      posxml_loop_next
    end
    variable.value = 1
  end

  def network_receive(buffer, max_size, bytes, variable)
    $device.echo("Requesting up to #{max_size.value} bytes to the server...")
    variable.value = 0
    @pause = true
    $device.timeout(300) do
      received = @socket.read(max_size.value.to_i)
      buffer.value = received.unpack("H*")[0]
      bytes.value = received.size
      variable.value = 1 if bytes.value > 0
      $device.echo("Received #{buffer.value.size>>1} bytes.")
      $device.timeout(300) do
        @pause = false
        posxml_loop_next
      end
    end
  end

  def network_shutdown_modem
    @socket.close
  end

  def print_bitmap(filename, variable)
    if File.exists?(filename.value) && File.size(filename.value) > 0
      assign = Proc.new do |result|
        variable.value = result
      end
      $device.showBitmap(filename.value, "printer", nil, nil, &assign)
    else
      variable.value = 0
    end
  end

  def util_wait(milliseconds)
    @pause = true
    callback = Proc.new do
      @pause = false
      posxml_loop_next
    end
    MrubyJs.window.setTimeout(callback, milliseconds.to_i)
  end

  # Resets the terminal if we reach the end of the POSXML.
  def util_exit
    @pause = true
    $device.close "POSXML exit.", 0
  end

  def util_system_restart
    @pause = true
    $device.close "POSXML restart.", 1
  end

  def util_system_beep
    @pause = true
    $device.beep do
      @pause = false
      posxml_loop_next
    end
  end

  def util_system_info(type, var)
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

  input_money do |variable, line, column, message|
    total_input = variable.to_i > 0 ? variable.to_s.gsub(".", "") : ""
    @pause = true
    last_number = ""
    read = Proc.new do |input, remove|
      if input == "KEY_X"
        variable.value = -2
        @pause = false
        posxml_loop_next
      elsif input != "ENTER"
        total_input = total_input[0..-2] if remove
        total_input << input if input.match(/[0-9]/)
        number = "0,00"
        l = total_input.length - 1
        i = l
        until i < 0
          li = l - i
          if li < 3 # "0,00".length - 1
            pos = number.length - 1 - li
            pos -= 1 if number[pos] == ","[0]
            number[pos] = total_input[i].to_s
          else
            if (li + 1) % 3 == 0
              number = ".#{number}"
            end
            number = "#{total_input[i]}#{number}"
          end
          i-=1
        end
        last_number = number
        $device.display(0, line.to_i, "#{message.value} #{number}")
        $device.read(&read)
      else
        # The line below should work but at unknown circumstances, it doesn't
        # variable.value = last_number.gsub(/[.,]/,"").to_i
        variable.value = ""
        last_number.each_char do |char|
          variable.value << char if char =~ /[0-9]/
        end
        variable.value = variable.value.to_i
        @pause = false
        posxml_loop_next
      end
    end
    $device.display(column.value, line.value, "#{message.value} 0,00")
    $device.prompt "Click any button to continue."
    $device.read(&read)
  end

  input_getvalue do |empty, caption, columnC, lineC, columnI, lineI, max, min, var|
  end

  # type:     1 for magstripe, 2 for chip, 3 for contactless, 4 for keyboard, 5 for touch.
  # keyboard: 1 for keybard enabled and 0 for keyboard disabled.
  # timeout:  In miliseconds in this case 30 seconds.
  # key:      When keyboard equals to 0, just returns with timeout or if you press KEY_CANCEL. If keyboard equals to 1 it will return all the pressed keys.
  # card:     It contains the track 2 and/or track 1 only when inputtype equals to 1.
  # var:      0 when a key is pressed or when the card input happens with success. -1 if it fails reading the tracks. -2 for timeout. For EMV chip or contactless: 1 for success, less than 1 for errors.
  card_system_input_transaction do |key, card, timeout, var, keyboard, type|
    $device.prompt "Press 1 for magstripe, 2 for chip, 3 for contactless, 4 for keyboard, 5 for touch"
    var.value = 0
    @pause = true
    $device.read(timeout.to_i) do |input|
      @pause     = false
      type.value = input
      key.value  = input
      case input
      when "1"
        p "Processing magstripe..."
        PAN = $device.getCard("", "", 12, 16)
        if PAN != ""
          EXP  = $device.getCardExp(nil)
          PVKI = "0"
          PVV  = "0000"
          CVV  = $device.getCardCVV(nil)
          card.value = "#{PAN}=#{EXP}000#{PVKI}#{PVV}#{CVV}"
        else
          p "Click on a card in the cards panel."
          var.value  = -1
        end
      when "2"
        p "Processing chip..."
        p "WARNING: EMV is not yet implemented in the emulator."
      when "3"
        p "Processing contactless..."
        p "WARNING: EMV is not yet implemented in the emulator."
      when "4"
        manual_card_input("", "Enter the number of the card", Variable.new("12"), Variable.new("16"), card)
        var.value = 0 if card.value != ""
      when "5"
        p "Processing touch..."
        p "WARNING: EMV is not yet implemented in the emulator."
      end
      posxml_loop_next
    end
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

  input_option do |var, line, column, message, min, max|
    input_integer(var, line, column, message, min, max)
  end

  interface_menu do |variable,options|
    @pause = true
    $device.clear(nil)
    options_slides = options.value.index("\\") != nil ? options.value.split("\\") : options.value
    lines = screen_lines - 1 # -1 because length
    next_first_option = 1
    i = 0
    while i <= lines
      option = i < options_slides.length && options_slides[i].length > 0 ? options_slides[i] : " "*screen_columns
      $device.display(0, i, option)
      i += 1
    end
    read = Proc.new do |input, remove|
      if input == "ENTER"
        first = next_first_option + lines
        first = 0 if first > options_slides.length
        i = first
        while (i-first) <= lines
          option = i < options_slides.length && options_slides[i].length > 0 ? options_slides[i] : " "*screen_columns
          $device.display(0, i-first, option)
          i += 1
        end
        next_first_option = first + 1
        $device.read(&read)
      else
        if input == "KEY_X" || input.match(/[0-9]/)
          variable.value = input == "KEY_X" ? KEY_CANCEL : input
          $device.clear(nil)
          @pause = false
          posxml_loop_next
        else
          $device.read(&read)
        end
      end
    end
    $device.read(&read)
  end

  # posxml_conditional fixed to work without needing to check for ZeroDivisionError
  def posxml_conditional(jump, variable1, operator, variable2)
    value1, value2 = rjust(variable1.to_s, variable2.to_s)
    op = operator.to_operator
    unless value1.send(op, value2)
      posxml_jump!(jump.value)
    end
  end

  # We cannot call posxml_push_function with "number" alone after posxml_jump!
  # because it will take the next value, not the current one
  # We have to use @number - 1, @number only causes the next instruction to fail.
  def flow_function_call(jump_point, function_name)
    posxml_push_function(@number-1)
    posxml_jump!(jump_point.value)
  end

  # MRuby do not have rjust or insert
  def rjust(string1, string2)
    if string1.size > string2.size
      insert = ("0" * (string1.size - string2.size))
      [string1, insert + string2]
    else
      insert = ("0" * (string2.size - string1.size))
      [insert + string1, string2]
    end
  end

  def string_elements(string, delimiter, variable)
    variable.value = string.to_s.split(delimiter.value).size
  end

  def string_element_at(string, index, delimiter, variable)
    variable.value = string.value.split(delimiter.value)[index.to_i]
  end

  def string_char_at(string, index, variable)
    variable.value = string.value[index.to_i]
  end

  def string_insert_at(string, insert, index, delimiter, variable)
    parts    = string.value.split(delimiter.value)
    index    = index.to_i
    head     = parts[0..(index-1)]
    head[-1] = head[-1]+insert.value
    tail     = parts[(index)..-1]
    variable.value = head.join(delimiter.value) + tail.join(delimiter.value)
  end

  def string_replace_at(string, replace, index, delimiter, variable)
    parts = string.value.split(delimiter.value)
    index = index.to_i
    parts[index] = replace.value
    variable.value = parts.join(delimiter.value)
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

  def string_trim(str, variable)
    strip = str.value.strip
    variable.value = strip if strip
  end

  def string_replace(original, old, new, variable)
    sub = original.value.gsub old.value, new.value
    variable.value = sub ? sub : original.value
  end

  def string_remove_at(original, index, delimiter, variable)
    parts = original.value.split(delimiter.value)
    parts.delete_at(index.value.to_i)
    variable.value = parts.join(delimiter.value)
  end

  def string_string_substring(string, start, length, substring)
    substring.value = string.value[start.value.to_i, length.value.to_i]
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

  def string_get_value_by_key(string, key, variable)
    index = string.value.index(key.value+"=")
    if index
      from_index = string.value[index+key.value.size+1..-1]
      last_quote_index = from_index.rindex("\"")
      from_index = from_index[0..last_quote_index] + "," + from_index[last_quote_index..-1]
      variable.value = from_index.split("\",")[0]
    end
  end

  def flow_if(jump_point, variable1, operator, variable2=Variable.new(""))
    variable2.value = "" if variable2.value == " "
    if !Variable::OPERATORS[operator.value.to_s]
      $device.error("\"#{operator.value}\" is not a valid operator!")
      util_exit
    end
    if variable1.value.class == Float
      _variable1 = Variable.new(variable1.to_s)
      posxml_conditional(jump_point, _variable1, operator, variable2)
    else
      posxml_conditional(jump_point, variable1, operator, variable2)
    end
  end

  def flow_while(jump_point, variable1, operator, variable2=Variable.new(""))
    if variable1.value.class == Float
      _variable1 = Variable.new(variable1.to_s)
      posxml_conditional(jump_point, _variable1, operator, variable2)
    else
      posxml_conditional(jump_point, variable1, operator, variable2)
    end
  end

  def posxml_load!(file)
    file_handle     = File.open(posxml_file_path(file), "r")
    @file           = file
    @function_stack = Array.new
    @bytecode       = file_handle.read(File.size(file))
    @number         = 0
    file_handle.close
    posxml_write_db_config("executingAppName", file)
  end

  def posxml_loop_next
    loop do
      break if @pause
      posxml_next
    end
  end

  def posxml_execute_bytecode(symbol, parameters)
    list = parameters.collect do |parameter|
      # TODO: By unknown reasons, some previously defined variables are set to nil
      # to fix this we have to re-create them. We should discover why this happens.
      index = 0
      if parameter[0..1] == "$(" && parameter[-1] == ")"
        index = parameter[2..-2].to_i
      end
      if index == 0 || self.variables[index]
        Variable.create(parameter, self)
      else
        self.variables[index] = Variable.new("", nil, self)
      end
    end
    instruction = PosxmlParser::Bytecode::INSTRUCTIONS[symbol]
    # MrubyJs.window.console.log instruction, parameters # Just to debug
    begin
      send(instruction,*list)
    rescue
      if instruction && self.methods.include?(instruction.to_sym)
        message = "caused an error, please report this issue in cloudwalk.zendesk.com"
      else
        message = "is not an implemented instruction!"
      end
      $device.fail(symbol, instruction, message)
      util_exit
    end
  end

  def qrcode(filename, input, size, version)
    @pause = true
    callback = Proc.new do
      @pause = false
      posxml_loop_next
    end
    $device.qrcode(filename.to_s, input.to_s, size.to_s[1..-1].to_i, version.to_i, &callback)
  end

  def start
    $device.loadFiles do

      @screen_columns = $device.screenColumns(nil)
      @screen_lines   = $device.screenLines(nil)

      posxml_configure!("", $device.executingAppName(nil), false)
      posxml_write_db_config("ipHost", $device.ipHost(nil))

      # We don't need the SSL port (31416) right now.
      # posxml_write_db_config("portaHost", $device.portaHost(nil))
      posxml_write_db_config("serialTerminal", $device.serialTerminal(nil))
      posxml_write_db_config("numeroLogico", $device.logicalNumber(nil))

      @files = Array.new

      # Read _file_download to see why we're doing this.
      PosxmlParser::Bytecode::INSTRUCTIONS["4"] = :_file_download

      # TODO: Update mruby-posxml-parser to the one that has the qrcode
      # instruction, or at least has it mentioned in the bytecode.rb file
      PosxmlParser::Bytecode::INSTRUCTIONS["\x94"] = :qrcode

      PosxmlParser::Bytecode::INSTRUCTIONS["\x8A"] = :file_rename

      # Pre-connecting to get the params file.
      if posxml_read_db_config("serialTerminal").empty? || posxml_read_db_config("numeroLogico").empty?
        posxml_loop_next
      else
        network_pre_connect(Variable.new(""))
      end
    end
  end
end

