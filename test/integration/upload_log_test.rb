
class UploadLogTest < DaFunk::Test.case
  def setup
    filename  = "text.txt"
    path      = "./shared/#{filename}"
    @zip      = "./main/#{Device::System.serial}-#{filename}.zip"
    File.delete(@zip) if File.file? @zip
    Zip.compress(@zip, path)
  end

  def test_upload
    Device::System.klass = "maintest.posxml"
    Device::ParamsDat.file["api_token"] = "d79db7b1dc59c9c5a1f369478444625a0d1adef8"
    assert LogsMenu.upload(@zip)
  end
end

