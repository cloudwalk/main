class CloudwalkFont
  FILE_PATH = "shared/font.dat"

  attr_accessor :file, :file_path

  def self.setup(file_path = FILE_PATH)
    if File.exists?(file_path)
      CloudwalkFont.new.load
    else
      DaFunk::EventHandler.new :file_exists_once, CloudwalkFont::FILE_PATH do
        CloudwalkFont.new.load
      end
    end
  end

  def initialize(file_path = FILE_PATH)
    self.file_path = file_path
  end

  def check
    File.exists?(self.file_path) && ! self.file
  end

  def load
    # TODO Scalone temporary
    if File.exists?(file_path)
      self.file = FileDb.new(file_path)
      if Device::Display.adapter.respond_to? :font
        Device::Display.adapter.font(r, g, b, a, width, height, path)
      end

      STDOUT.max_x = columns
      STDOUT.max_y = lines
    end
  end

  def r
    self.file["r"].to_i
  end

  def g
    self.file["g"].to_i
  end

  def b
    self.file["b"].to_i
  end

  def a
    self.file["a"].to_i
  end

  def width
    self.file["line_width"].to_i
  end

  def height
    self.file["line_height"].to_i
  end

  def lines
    self.file["lines"].to_i
  end

  def columns
    self.file["columns"].to_i
  end

  def path
    self.file["path"]
  end
end

