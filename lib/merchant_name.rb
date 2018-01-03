class MerchantName
  def self.display
    if (merchant_name = "#{DaFunk::ParamsDat.file["merchant_name"]}") != ""
      Device::Display.print_line(merchant_name, self.line, self.align(merchant_name))
    end
  end

  def self.line
    case Device::System.model.to_s.downcase
    when "gpos400"
      16
    else
      STDOUT.max_y - 2
    end
  end

  def self.align(merchant_name)
    ((STDOUT.max_x - merchant_name.size) / 2).to_i
  end
end

