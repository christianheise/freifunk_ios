class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    init_testflight
    init_nui

    @tabbar_controller = UITabBarController.alloc.init
    @tabbar_controller.viewControllers  = tabs
    @tabbar_controller.selectedIndex    = 0

    @navigation_controller  = UINavigationController.alloc.initWithRootViewController(@tabbar_controller)
    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      window.rootViewController = @navigation_controller
      window.rootViewController.wantsFullScreenLayout = true
      window.makeKeyAndVisible
    end
    true
  end

  def region
    if key = App::Persistence['region']
      Region.find(key.to_sym) || Region::ALL.first
    else
      Region::ALL.first
    end
  end
  
  def region=(region)
    App::Persistence['region'] = region.key.to_s
    region
  end

  private

  def tabs
    [
      MapController.new,
      ListController.new,
      SettingsController.new,
    ]
  end

  def init_testflight
    TestFlight.takeOff(NSBundle.mainBundle.objectForInfoDictionaryKey('testflight_apitoken'))
  end

  def init_nui
    NUISettings.initWithStylesheet("style")
    NUISettings.setAutoUpdatePath NSBundle.mainBundle.objectForInfoDictionaryKey('nui_style_path') if App.development?
    NUIAppearance.init
  end
end
