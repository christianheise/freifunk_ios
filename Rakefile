# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require :default
require 'bubble-wrap/location'
require 'bubble-wrap/reactor'

VERSION = "2.2.0"

Motion::Project::App.setup do |app|
  app.name                    = 'freifunk'
  app.device_family           = [:iphone, :ipad]
  app.deployment_target       = '7.0'
  app.icons                   = Dir['resources/Icon*'].map { |file| File.basename(file) }

  app.codesign_certificate    = 'iPhone Distribution: Peter Schroeder'
  app.identifier              = 'de.nofail.freifunk'

  # app.info_plist['UIStatusBarHidden'] = true
  # app.info_plist['UIViewControllerBasedStatusBarAppearance'] = true

  app.testflight.sdk = 'vendor/TestFlightSDK'
  app.info_plist['testflight_apitoken'] = ENV['TESTFLIGHT_APP_TOKEN_FREIFUNK']

  app.development do
    app.version                                   = "build #{%x(git describe --tags).chomp}"
    app.info_plist['CFBundleShortVersionString']  = VERSION

    app.provisioning_profile  = "#{ENV['HOME']}/Dropbox/ios_certs/ad_hoc_distribution_freifunk.mobileprovision"

    app.testflight.api_token          = ENV['TESTFLIGHT_API_TOKEN']
    app.testflight.team_token         = ENV['TESTFLIGHT_TEAM_TOKEN_FREIFUNK']
    app.testflight.app_token          = ENV['TESTFLIGHT_APP_TOKEN_FREIFUNK']
    app.testflight.notify             = true
    app.testflight.identify_testers   = true
    app.testflight.distribution_lists = ['freifunk']

    app.entitlements['get-task-allow'] = false
  end

  app.release do
    app.version                                   = VERSION
    app.info_plist['CFBundleShortVersionString']  = VERSION
    app.provisioning_profile                      = "#{ENV['HOME']}/Dropbox/ios_certs/app_store_distribution_freifunk.mobileprovision"
  end
end

desc "download latest node json"
task :update_json, [:name] do |t, args|
  require_relative 'app/01_models/region.rb'
  if name = args[:name]
    regions = [Region.find(name.to_sym)]
  else
    regions = Region.all
  end
  regions.each do |region|
    system("wget -O tmp.json '#{region.data_url}'")
    system("cat tmp.json | python -mjson.tool > resources/data/#{region.key}.json")
    system("rm tmp.json")
  end
end
