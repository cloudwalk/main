#!/usr/bin/env rake

require 'rake'
require 'fileutils'
require 'bundler/setup'

Bundler.require(:default)

files = [
  "lib/admin_configuration.rb",
  "lib/cloudwalk.rb",
  "lib/main.rb",
  "lib/posxml_parser/bytecode.rb",
  "lib/posxml_parser/class_methods.rb",
  "lib/posxml_parser/instructions.rb",
  "lib/posxml_parser/posxml_emv.rb",
  "lib/posxml_parser/posxml_parser.rb",
  "lib/posxml_parser/variable.rb",
  "lib/posxml_parser/version.rb",
  "lib/posxml_parser/posxml_setting.rb",
  "lib/posxml-interpreter.rb"
]

DaFunk::RakeTask.new do |conf|
  conf.libs = FileList[files]
  conf.resources = FileList["./resources/**/*"]
  conf.resources_out = conf.resources.pathmap("%{resources,out/shared}p")
  conf.mruby = "cloudwalk run"
end

