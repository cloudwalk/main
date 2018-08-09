#!/usr/bin/env rake

require 'rake'
require 'fileutils'
require 'bundler/setup'

Bundler.require(:default)

Cloudwalk::Ruby::RakeTask.new do |t|
  t.debug = false
end

DaFunk::RakeTask.new do |conf|
  conf.resources = FileList["./resources/**/*"]
  conf.mruby = "cloudwalk run -b"
  conf.resources_out = conf.resources.pathmap("%{resources,out}p")
  conf.debug = false
end

