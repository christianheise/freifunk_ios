class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    tabs = [
      MapController.new,
      ListController.new,
      SettingsController.new,
    ]
    @tabbar_controller = UITabBarController.alloc.init
    @tabbar_controller.viewControllers = tabs

    UINavigationBar.appearance.tintColor        = Color::MAIN
    UITabBar.appearance.tintColor               = Color::MAIN
    UITabBar.appearance.selectedImageTintColor  = Color::WHITE
    UISegmentedControl.appearance.tintColor     = Color::MAIN
    UISearchBar.appearance.tintColor            = Color::MAIN

    @navigation_controller  = UINavigationController.alloc.initWithRootViewController(@tabbar_controller)
    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      window.rootViewController = @navigation_controller
      window.rootViewController.wantsFullScreenLayout = true
      window.makeKeyAndVisible
    end
    true
  end
end
