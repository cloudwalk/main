ROOT_PATH = File.expand_path("../")
APP_NAME = File.basename(ROOT_PATH)

$LOAD_PATH.unshift "./#{APP_NAME}"
require 'da_funk'

DaFunk::Test.configure do |t|
  t.root_path      = ROOT_PATH
  t.serial         = "0000000002"
  t.logical_number = "0000012"
end

Device::Setting.to_staging!
