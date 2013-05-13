class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    #=> Disable comment load @ launch
    @defaults = NSUserDefaults.standardUserDefaults 
    @defaults["postObjectId"] = nil
    #=> Parse credentials
    Parse.setApplicationId("XXX", clientKey:"XXX")
    
    myEntryViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil).first
    myMainViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[2]
    myCameraViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[3]
    myPostViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[4]
    myProfileViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[5]


    if  PFUser.currentUser #todo :=> checking current user from Parse
        #navigation = UINavigationController.alloc.initWithRootViewController(myEntryViewController)
        navigation = UINavigationController.alloc.initWithRootViewController(myMainViewController)
        navigation_2 = UINavigationController.alloc.initWithRootViewController(myCameraViewController)
        navigation_3 = UINavigationController.alloc.initWithRootViewController(myPostViewController)
        navigation_4 = UINavigationController.alloc.initWithRootViewController(myProfileViewController)
        tab_controller = UITabBarController.alloc.initWithNibName(nil, bundle: nil)
        tab_controller.viewControllers = [navigation, navigation_2, navigation_3, navigation_4]

        @window.rootViewController = tab_controller
        @window.rootViewController.wantsFullScreenLayout = true
        @window.makeKeyAndVisible
         
    else
        navigation = myEntryViewController
         @window.rootViewController = navigation
         @window.rootViewController.wantsFullScreenLayout = true
         @window.makeKeyAndVisible
    end

    @temp_params = nil
    #=> Set Standard Background Image
    @window.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("background.png"))

    #=> Set Custom Nav Bar
    navigationBar = UINavigationBar.appearance
    navigationBar.setBackgroundImage(UIImage.imageNamed('navbar.png'), forBarMetrics: UIBarMetricsDefault)

     #=> Set Custom Tab Bar
    tabBar = UITabBar.appearance
    tabBar.setBackgroundImage(UIImage.imageNamed('tabbar.png').resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0)))
    tabBar.setSelectionIndicatorImage(UIImage.imageNamed("selectedtab.png"))
    tabBar.setBackgroundColor(UIColor.lightGrayColor)
    #tabBar.setSelectedImageTintColor(UIColor.lightGrayColor)
    
    #tabBar.setTintColor(UIColor.clearColor)

    true
  end
end
