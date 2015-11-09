
module PosxmlParser
  module ClassMethods
    PosxmlParser::Bytecode::INSTRUCTIONS.each do |bytecode, new_method|
      define_method new_method do |&block|
      define_method new_method, &block
      end
    end
  end
end

