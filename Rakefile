#!/usr/bin/env rake

require 'rake'
require 'fileutils'
require 'bundler/setup'

Bundler.require(:default)

DaFunk::RakeTask.new do |conf|
  conf.resources = FileList["./resources/**/*"]
  conf.mruby = "cloudwalk run -b"
  conf.resources_out = conf.resources.pathmap("%{resources,out}p")
end

