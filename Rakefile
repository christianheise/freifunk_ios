# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require :default

Motion::Project::App.setup do |app|
  app.name              = 'freifunk'
  app.device_family     = [:iphone, :ipad]
  app.deployment_target = '5.0'
  app.icons             = Dir['resources/Icon*'].map { |file| File.basename(file) }
end
