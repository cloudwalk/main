class InputTransactionAmount
  class << self
    def enabled?
      DaFunk::ParamsDat.file["emv_application"] &&
      (DaFunk::ParamsDat.file["emv_contactless_amount"] == "1" ||
        Device::Setting.emv_contactless_amount == "1")
    end

    def call(first_key=nil)
      amount = input(first_key)
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

    def contactless_amount_image
      DaFunk::ParamsDat.file["emv_contactless_amount_image"] || 'amount.bmp'
    end

    def contactless_amount_user_canceled_image
      DaFunk::ParamsDat.file["emv_contactless_amount_user_canceled_image"] || 'operation_canceled.bmp'
    end

    def contactless_amount_timeout_image
      DaFunk::ParamsDat.file["emv_contactless_amount_timeout_image"] || 'fail_timeout.bmp'
    end

    def contactless_minimum_amount_permited
      DaFunk::ParamsDat.file["emv_contactless_minimum_amount_permitted"] || '100'
    end

    def contactless_amount_under_permited
      DaFunk::ParamsDat.file["emv_contactless_amount_under_permited_image"] || 'fail_low_amount.bmp'
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

      key = ''
      while key.empty?
        Device::Display.print_bitmap(bmp) if bmp_exists?(bmp)

        key = Device::IO.get_format(0, 12, options)

        if key == Device::IO::CANCEL
          Device::Display.clear
          user_canceled_message
        elsif key == Device::IO::KEY_TIMEOUT
          Device::Display.clear
          timeout_message
        else
          unless key.to_s.empty?
            if key.to_i < contactless_minimum_amount_permited.to_i
              amount_under_minimum_not_permitted
              key = ''
            end
          end
        end
      end

      key
    end

    def user_canceled_message
      image = contactless_amount_user_canceled_image
      bmp   = to_bmp(image)

      if bmp_exists?(bmp)
        Device::Display.print_bitmap(bmp)
      else
        I18n.pt(:emv_contactless_amount_user_canceled, :line => 3)
      end
      getc(3000)
    end

    def timeout_message
      image = contactless_amount_timeout_image
      bmp   = to_bmp(image)

      if bmp_exists?(bmp)
        Device::Display.print_bitmap(bmp)
      else
        I18n.pt(:contactless_amount_timeout_image, :line => 3)
      end
      getc(3000)
    end

    def emv_ctls_table_installed?
      EmvTransaction.ctls_apps.first == 0
    end

    def amount_under_minimum_not_permitted
      amount_under_minimum = to_bmp(contactless_amount_under_permited)

      if bmp_exists?(amount_under_minimum)
        Device::Display.print_bitmap(amount_under_minimum)
      else
        I18n.pt(:emv_contactless_amount_under_minimum, :line => 3)
      end
      getc(3000)
    end
  end
end
