class InputTransactionAmount
  class << self
    def enabled?
      DaFunk::ParamsDat.file["emv_application"] &&
      (DaFunk::ParamsDat.file["emv_contactless_amount"] == "1" ||
        Device::Setting.emv_contactless_amount == "1")
    end

    def call(first_key=nil)
      amount = self.input(first_key)
      if amount != Device::IO::CANCEL && amount != Device::IO::KEY_TIMEOUT
        Device::Runtime.execute(
          DaFunk::ParamsDat.file["emv_application"],
          emv_parameters(amount)
        )
      end
    end

    def column
      DaFunk::ParamsDat.file["emv_contactless_amount_collum"] || 2
    end

    def line
      DaFunk::ParamsDat.file["emv_contactless_amount_row"] || 4
    end

    def label(extra = nil)
      (DaFunk::ParamsDat.file["emv_contactless_amount_label"] || 'R$ ') + extra.to_s
    end

    def emv_parameters(amount)
      EmvTransaction.params('init_data' => {'amount' => amount.to_s.rjust(12, '0')}).to_json
    end

    def display
      Device::Display.print_line(label('0,00'), line, column)
    end

    def contactless_amount_image
      DaFunk::ParamsDat.file["emv_contactless_amount_image"] || 'amount.bmp'
    end

    def to_bmp(image)
      if image.include?('.bmp')
        "./shared/#{image}"
      else
        "./shared/#{image}.bmp"
      end
    end

    def bmp_exists?(bmp)
      File.exists?(bmp)
    end

    def input(value)
      options = Hash.new
      options[:label]     = label
      options[:value]     = value
      options[:line]      = line
      options[:column]    = column
      options[:mode]      = Device::IO::IO_INPUT_MONEY
      options[:delimiter] = "."
      options[:separator] = ","

      image = contactless_amount_image
      bmp   = to_bmp(image)

      Device::Display.print_bitmap(bmp) if bmp_exists?(bmp)
      Device::IO.get_format(0, 12, options)
    end

    def emv_ctls_table_installed?
      EmvTransaction.ctls_apps.first == 0
    end
  end
end
