class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    @map_controller         = MapController.new
    @navigation_controller  = UINavigationController.alloc.initWithRootViewController(@map_controller)
    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      window.rootViewController = @navigation_controller
      window.rootViewController.wantsFullScreenLayout = true
      window.makeKeyAndVisible
    end
  end
end
