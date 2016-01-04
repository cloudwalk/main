
module PosxmlParser
  DELIMITER_END_INSTRUCTION = "\r"
  DELIMITER_END_PARAMETER   = "\n"

  include PosxmlParser::Threadable
  include PosxmlParser::Parameters
  include PosxmlParser::FileDb

  attr_accessor :thread, :variables, :bytecode, :number, :path, :file_main, :file, :function_stack, :socket

  def self.included(base)
    base.send :extend, PosxmlParser::ClassMethods
    base.send :include, PosxmlParser::Instructions
  end

  #Core VM
  #TODO posxml_* methods should extract to a helper/core class
  def posxml_configure!(path, file, use_thread)
    @variables = Hash.new
    @path      = path
    @thread    = use_thread
    @file_main = file

    posxml_initialize_parameters
    posxml_load!(file)
  end

  def posxml_load!(file)
    file_handle     = File.open(posxml_file_path(file), "r")
    @file           = file
    @function_stack = Array.new
    @bytecode       = file_handle.read(File.size(posxml_file_path(file)))
    @number         = 0

    file_handle.close
    posxml_write_db_config("executingAppName", file)
  end

  def posxml_next_instruction
    size        = bytecode[number..-1].index(PosxmlParser::DELIMITER_END_INSTRUCTION).to_i
    line        = bytecode[number..(number + size - 1)]
    @number     += (size + 1)
    line
  end

  def posxml_next
    posxml_load!(file_main) if number >= bytecode.size
    line        = posxml_next_instruction
    instruction = line[0]
    parameters  = line[1..-1].split(PosxmlParser::DELIMITER_END_PARAMETER)

    posxml_execute_bytecode(instruction, parameters)
  end

  # TODO: I don't know if should be on PosxmlInstanceMethods
  def posxml_loop
    if block_given?
      yield
    else
      loop do
        posxml_next
      end
    end
  end

  def posxml_execute_bytecode(instruction, parameters)
    list = parameters.collect { |parameter| Variable.create(parameter, self) }
    send(PosxmlParser::Bytecode::INSTRUCTIONS[instruction],*list)
  end

  def posxml_define_variable(value, index)
    variables[index.to_i] = Variable.new(value, index.to_i, self)
  end

  def posxml_conditional(jump, variable1, operator, variable2)
    unless variable1.compare(operator, variable2)
      posxml_jump!(jump.value)
    end
  end

  def posxml_jump!(point)
    @number = point.to_i
    posxml_next_instruction
  end

  def posxml_push_function(point)
    function_stack << point
  end

  def posxml_pop_function
    posxml_jump!(function_stack.delete_at(-1))
  end

  def posxml_file_path(file_name)
    "#{path}#{file_name}"
  end

  def posxml_date_to_time(text)
    result = text.match(/([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+):([0-9]+)/)
    return nil unless result
    Time.local(result[0].to_i, result[1].to_i, result[2].to_i, result[3].to_i, result[4].to_i, result[5].to_i)
  end

  def posxml_time_to_date(time)
    "#{time.year}-#{time.month}-#{time.day} #{time.hour}:#{time.min}:#{time.sec}"
  end

  def posxml_date_to_seconds(type, value)
    case type
    when (type == "segundos" || type == "seconds")
      value
    when (type == "minutos" || type == "minutes")
      value * 60
    when (type == "horas" || type == "hours")
      value * 60 * 60
    when (type == "dias" || type == "days")
      value * 60 * 60 * 24
    when (type == "meses" || type == "months")
      value * 60 * 60 * 24 * 30
    when (type == "years" || type == "years")
      value * 60 * 60 * 24 * 30 * 365
    else
      0
    end
  end

  def posxml_write_db_config(key, value)
    PosxmlParser::PosxmlSetting.send("#{key}=", value)
  end

  def posxml_read_db_config(key)
    PosxmlParser::PosxmlSetting.send(key)
  end

  def posxml_parse_menu_selection(options)
    options.split(".").each_with_index.inject({}) do
      |hash, values| hash[values[0]] = values[1]; hash
    end
  end
end

