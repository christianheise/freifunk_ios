# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require :default
require 'bubble-wrap/location'

VERSION = "0.0.1"

Motion::Project::App.setup do |app|
  app.name                    = 'freifunk'
  app.device_family           = [:iphone, :ipad]
  app.deployment_target       = '5.1'
  app.icons                   = Dir['resources/Icon*'].map { |file| File.basename(file) }

  app.codesign_certificate    = 'iPhone Distribution: Peter Schroeder'
  app.identifier              = 'de.nofail.freifunk'
 
  app.pods do
    pod 'NUI'
  end

  app.info_plist['testflight_apitoken'] = ENV['TESTFLIGHT_APP_TOKEN_FREIFUNK']

  app.development do
    app.version               = "#{VERSION} (build #{%x(git describe --tags).chomp})"
    app.provisioning_profile  = "#{ENV['HOME']}/Dropbox/ios_certs/ad_hoc_distribution_freifunk.mobileprovision"

    app.testflight.sdk                = 'vendor/TestFlightSDK'
    app.testflight.api_token          = ENV['TESTFLIGHT_API_TOKEN']
    app.testflight.team_token         = ENV['TESTFLIGHT_TEAM_TOKEN_FREIFUNK']
    app.testflight.app_token          = ENV['TESTFLIGHT_APP_TOKEN_FREIFUNK']
    app.testflight.notify             = true
    app.testflight.identify_testers   = true
    app.testflight.distribution_lists = ['freifunk']

    # REM (ps) this needs to be set for testflight
    # TODO (ps) open an issue at https://github.com/HipByte/motion-testflight/
    app.entitlements['get-task-allow'] = false

    app.info_plist['nui_style_path'] = "#{Dir.pwd}/resources/style.nss"
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
