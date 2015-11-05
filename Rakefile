#!/usr/bin/env rake

require 'rake'
require 'fileutils'
require 'bundler/setup'

Bundler.require(:default)

DaFunk::RakeTask.new do |conf|
  conf.resources = FileList["./resources/**/*"]
  conf.resources_out = conf.resources.pathmap("%{resources,out/shared}p")
  conf.mruby = "cloudwalk run"
  conf.out_path = "out/main"
end

