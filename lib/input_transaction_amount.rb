class InputTransactionAmount
  class << self
    def enabled?
      DaFunk::ParamsDat.file["emv_application"] &&
      (DaFunk::ParamsDat.file["emv_input_amount_idle"] == "1" ||
        Device::Setting.emv_input_amount_idle == "1")
    end

    def call(first_key)
      amount = self.input(first_key)
      if amount != Device::IO::CANCEL
        Device::Runtime.execute(
          DaFunk::ParamsDat.file["emv_application"],
          emv_parameters(amount)
        )
      end
    end

    def column
      DaFunk::ParamsDat.file["emv_input_amount_idle_column"] || 5
    end

    def line
      DaFunk::ParamsDat.file["emv_input_amount_idle_row"] || 7
    end

    def label(extra = nil)
      (DaFunk::ParamsDat.file["emv_input_amount_idle_label"] || 'R$ ') + extra.to_s
    end

    def emv_parameters(amount)
      EmvTransaction.params('init_data' => {'amount' => amount.to_s.rjust(12, '0')}).to_json
    end

    def display
      Device::Display.print_line(label('0,00'), line, column)
    end

    def input(value)
      options = Hash.new
      options[:label]  = label
      options[:value]  = value
      options[:line]   = line
      options[:column] = column
      options[:mode]   = Device::IO::IO_INPUT_MONEY
      options[:delimiter] = "."
      options[:separator] = ","

      Device::IO.get_format(0, 12, options)
    end
  end
end
