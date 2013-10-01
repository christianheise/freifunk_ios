class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    TestFlight.takeOff(NSBundle.mainBundle.objectForInfoDictionaryKey('testflight_apitoken'))

    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      window.rootViewController = navigation_controller
      window.tintColor = Color::MAIN
      UISearchBar.appearance.tintColor    = Color::LIGHT
      UISearchBar.appearance.barTintColor = Color::LIGHT
      UITabBar.appearance.tintColor       = Color::LIGHT
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

  def navigation_controller
    @navigation_controller ||= UINavigationController.alloc.tap do |controller|
      controller.initWithRootViewController(tabbar_controller)
      controller.navigationBar.setTitleTextAttributes({ UITextAttributeTextColor => Color::LIGHT }, forState: UIControlStateNormal)
    end
  end

  def tabbar_controller
    @tabbar_controller ||= UITabBarController.alloc.tap do |controller|
      controller.init
      controller.viewControllers = tabs
      controller.selectedIndex   = 0
    end
  end

  def tabs
    [
      MapController.new,
      ListController.new,
      SettingsController.new,
    ]
  end
end
