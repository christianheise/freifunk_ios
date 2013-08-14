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
  app.deployment_target       = '5.0'
  app.icons                   = Dir['resources/Icon*'].map { |file| File.basename(file) }

  app.codesign_certificate    = 'iPhone Distribution: Peter Schroeder'
  app.identifier              = 'de.nofail.freifunk'

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
  end

  app.release do
    app.version                                   = VERSION
    app.info_plist['CFBundleShortVersionString']  = VERSION
    app.provisioning_profile                      = "#{ENV['HOME']}/Dropbox/ios_certs/app_store_distribution_freifunk.mobileprovision"
  end
end

desc "download latest node json"
task :update_json do
  system('wget "http://graph.hamburg.freifunk.net/nodes.json" && mv nodes.json resources/data/nodes.json')
end
