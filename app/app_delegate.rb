class AppDelegate
  attr_reader :file_loader, :node_repo, :mash_repo

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    TestFlight.takeOff(NSBundle.mainBundle.objectForInfoDictionaryKey('testflight_apitoken'))

    reload

    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      window.rootViewController = navigation_controller
      window.tintColor = Color::LIGHT
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
    reload
    region
  end

  def reload
    @file_loader  = FileLoader.new(region)
    @node_repo    = NodeRepository.new(@file_loader.load_nodes)
    @mash_repo    = MashRepository.new(@file_loader.load_links)
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
