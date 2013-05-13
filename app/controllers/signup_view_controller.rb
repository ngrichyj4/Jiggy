class SignupViewController < UIViewController

  def loadView
  end

  def viewDidLoad
    super
  
  self.title = "Signup"
  userTextField.delegate = self
  passTextField.delegate = self
  emailTextField.delegate = self

  #=> Set Padding for TextField
  paddingTextField(userTextField)
  paddingTextField(passTextField)
  paddingTextField(emailTextField)

  signUpButton.addTarget(self, action: 'push_signup:', forControlEvents:UIControlEventTouchUpInside)
  doneButton.addTarget(self, action: 'dismiss_comment_view', forControlEvents:UIControlEventTouchUpInside)

  theScrollView.delegate = self
  theScrollView.scrollEnabled = true
  theScrollView.setContentSize(self.view.bounds.size)


  end

  def push_signup(param)
    #Implement Signup Process then
    app = UIApplication.sharedApplication
    @window = app.delegate.instance_variable_get(:@window)
    controller = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[2]
    #@window.viewControllers(controller)
    
    SVProgressHUD.showWithStatus("Registering...")
      Dispatch::Queue.concurrent.async do
      create_user(userTextField.text, passTextField.text, emailTextField.text)
      
    end

  end

  def create_user(username, password, email)
    user = PFUser.user
    user.username = "#{username}"
    user.email = "#{email}"
    user.password = "#{password}"
    user.setObject("1", forKey:"currentCity")
    #user.signUp
   
    signin = lambda do |succeeded, error|  

        if !error
            restart
           SVProgressHUD.dismiss 
        else
           SVProgressHUD.dismiss
           alert_message(error.userInfo["error"]) 
          #return error.userInfo["error"]
        end
    end
    user.signUpInBackgroundWithBlock(signin)
  end

    def restart

    appDelegate = UIApplication.sharedApplication.delegate
    #appDelegate.navigationController.popToRootViewControllerAnimated(true)
    #topViewController = appDelegate.navigationController.topViewController
    #className = topViewController.class
    #nibName = topViewController.nibName
    myMainViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[2]
    myCameraViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[3]
    myPostViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[4]
    myProfileViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[5]

    navigation = UINavigationController.alloc.initWithRootViewController(myMainViewController)
    navigation_2 = UINavigationController.alloc.initWithRootViewController(myCameraViewController)
    navigation_3 = UINavigationController.alloc.initWithRootViewController(myPostViewController)
    navigation_4 = UINavigationController.alloc.initWithRootViewController(myProfileViewController)
    tab_controller = UITabBarController.alloc.initWithNibName(nil, bundle: nil)
    tab_controller.viewControllers = [navigation, navigation_2, navigation_3, navigation_4]
    
    self.view.removeFromSuperview
    appDelegate.instance_variable_get(:@window).rootViewController = tab_controller
    appDelegate.instance_variable_get(:@window).makeKeyAndVisible
    #rootViewcontroller = tab_controller
    #appDelegate.window.view.removeFromSuperview
    #appDelegate.viewControllers = arrayWithObject(rootViewcontroller)
    #appDelegate.window.addSubview(appDelegate.view)
    
  end


  def alert_message(msg)
    alert = UIAlertView.alloc.initWithTitle("Error",
        message:"#{msg}",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
  end


   #=> Retrieve ScrollView from Xib with tag
   def theScrollView
    @theScrollView ||= self.view.viewWithTag(1)
    @theScrollView.setFrame([[0,44], [320, 460]])  if iPhone5
    @theScrollView.setShowsVerticalScrollIndicator(false)
    return @theScrollView
    
    
   end

   def dismiss_comment_view
      self.dismissModalViewControllerAnimated(true)
   end





    #=> Retrieve Username from Xib with tag
   def userTextField
     @userTextField ||= self.view.viewWithTag(2)
    
   end

   #=> Retrieve Password from Xib with tag
   def passTextField
     @passTextField ||= self.view.viewWithTag(3)
   end

   def emailTextField
     @emailTextField ||= self.view.viewWithTag(4)
   end

   def signUpButton
    @signUpButton ||= self.view.viewWithTag(6)
   end

   def doneButton
   
    @doneButton ||= self.view.viewWithTag(7)
   
    end


   def paddingTextField(textField)
    paddingView = UIView.alloc.initWithFrame(CGRectMake(0, 0, 7, 20)).autorelease
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
  end


  #=> called when textField start editting and adjust view
  def textFieldDidBeginEditing(textField)
    activeField = textField
    theScrollView.setContentOffset(CGPointMake(0,textField.center.y-60), animated: true)
  end

  #=> called when textField next is hit and adjust view
  def textFieldShouldReturn(textField)

      nextTag = textField.tag + 1
      # Try to find next responder
      nextResponder = textField.superview.viewWithTag(nextTag)

      if (nextResponder.isKindOfClass(UITextField))
          theScrollView.setContentOffset(CGPointMake(0,textField.center.y-60), animated:true)
          # Found next responder, so set it.
          nextResponder.becomeFirstResponder
       else 
          theScrollView.setContentOffset(CGPointMake(0,0), animated:true)
          textField.resignFirstResponder
          return true
      end

      return false
  end

  def iPhone5
    return true if self.view.bounds.size.height == 548.0
  end
 

end