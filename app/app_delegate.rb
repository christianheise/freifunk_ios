class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    @window = UIWindow.alloc.tap do |window|
      window.initWithFrame(UIScreen.mainScreen.bounds)
      window.rootViewController = map_controller
      window.makeKeyAndVisible
    end
  end

  private

  def map_controller
    @map_controller ||= MapController.new
  end
end
