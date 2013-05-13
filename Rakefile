# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")

require 'motion/project'
require 'rubygems'
require 'motion-cocoapods'
require 'ParseModel'
require 'bubble-wrap/location'
require 'motion-addressbook'
require 'date'
require 'time'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Jiggy'
  app.device_family = :iphone
  app.fonts = ["ProximaNova-Light.otf"]
  app.prerendered_icon = true
  #app.sdk_version = "5.1"
  app.deployment_target = "5.1"
  app.frameworks += %w(MobileCoreServices AssetsLibrary AudioToolbox CFNetwork SystemConfiguration Security Foundation CoreGraphics QuartzCore AddressBook StoreKit MessageUI AddressBookUI)
  app.libs += ['/usr/lib/libsqlite3.dylib','/usr/lib/libz.1.1.3.dylib'] 

   app.vendor_project('vendor/Parse.framework', :static,
        :products => ['Parse'],
        :headers_dir => 'Headers')

  app.pods do
    pod 'SVProgressHUD'
  end

end
