
class Variable
  OPERATORS = {
    "igual"                => :==,
    "equalto"              => :==,
    "diferente"            => :!=,
    "notequalto"           => :!=,
    "maior"                => :>,
    "greaterthan"          => :>,
    "menor"                => :<,
    "lessthan"             => :<,
    "maiorigual"           => :>=,
    "greaterthanorequalto" => :>=,
    "menorigual"           => :<=,
    "lessthanorequalto"    => :<=,
    "+"                    => :+,
    "-"                    => :-,
    "*"                    => :*,
    "/"                    => :/,
    "%"                    => :%,
    "^"                    => :^
  }

  attr_accessor :value, :index, :parent

  def self.index?(value)
    #if(cleaned = value.match(/\$\((\w+)\)/))
    #cleaned[1].to_i
    if((cleaned = value.to_s[2..-2]) && value.to_s[0..1] == "$(" && value.to_s[-1] == ")")
      cleaned.to_i
    else
      false
    end
  end

  def self.create(new_value, parent)
    if index = index?(new_value)
      parent.variables[index]
    else
      Variable.new(new_value, nil, parent)
    end
  end

  def initialize(value, index = nil, parent = nil)
    @value  = value
    @index  = index
    @parent = parent
  end

  # TODO: Review method name, now We're using to conditions
  # and math operations
  # TODO: incorrect behavior to compare "t" and "0t"
  # TODO: Verify if operator is valid
  # TODO: Test new operator and zero division
  def compare(operator_variable, variable2)
    value1, value2 = rjust(self.value, variable2.value)
    operator = operator_variable.to_operator

    value1.send(operator, value2)
  rescue ZeroDivisionError
    0
  end

  def to_operator
    OPERATORS[self.value.to_s]
  end

  def to_i
    self.value.to_i
  end

  def to_s
    self.value.to_s
  end

  private

  #MRuby do not have rjust or insert
  def rjust(string1, string2)
    if string1.size > string2.size
      insert = ("0" * (string1.size - string2.size))
      [string1, insert + string2]
    else
      insert = ("0" * (string2.size - string1.size))
      [insert + string1, string2]
    end
  end
end

