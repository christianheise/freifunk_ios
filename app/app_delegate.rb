class AppDelegate
  attr_reader :file_loader, :node_repo, :link_repo

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    TestFlight.takeOff(NSBundle.mainBundle.objectForInfoDictionaryKey('testflight_apitoken'))

    reload

    UISearchBar.appearance.tintColor    = Color::LIGHT
    UITabBar.appearance.tintColor       = Color::LIGHT

    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      # window.rootViewController = tabbar_controller
      window.addSubview(tabbar_controller.view)
      window.tintColor = Color::LIGHT
      window.backgroundColor = Color::GRAY
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
    @link_repo    = LinkRepository.new(@file_loader.load_links)
  end

  private

  def tabbar_controller
    @tabbar_controller ||= UITabBarController.alloc.tap do |controller|
      controller.init
      controller.viewControllers = [map_controller, list_controller, settings_controller]
      controller.selectedIndex   = 0
    end
  end

  def list_controller
    @list_controller ||= UINavigationController.alloc.tap do |controller|
      root_controller = ListController.new
      controller.initWithRootViewController(root_controller)
    end
  end

  def map_controller
    @map_controller ||= UINavigationController.alloc.tap do |controller|
      root_controller = MapController.new
      controller.initWithRootViewController(root_controller)
    end
  end

  def settings_controller
    @settings_controller ||= UINavigationController.alloc.tap do |controller|
      root_controller = SettingsController.new
      controller.initWithRootViewController(root_controller)
    end
  end
end
