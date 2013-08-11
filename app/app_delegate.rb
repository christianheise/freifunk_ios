class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    @tabbar_controller = UITabBarController.alloc.init
    @tabbar_controller.viewControllers  = [MapController.new, ListController.new]
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
end
