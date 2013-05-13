class EntryViewController < UIViewController

  def loadView
  end

  def viewDidLoad
    super
  self.title = "Jiggy"
  

  userTextField.delegate = self
  passTextField.delegate = self

  #=> Set Padding for TextField
  paddingTextField(userTextField)
  paddingTextField(passTextField)

  signUpButton.addTarget(self, action: 'push_signup_view_controller:', forControlEvents:UIControlEventTouchUpInside)
  signInButton.addTarget(self, action: 'push_signin:', forControlEvents:UIControlEventTouchUpInside)

  theScrollView.delegate = self
  theScrollView.scrollEnabled = true
  theScrollView.setContentSize(self.view.bounds.size)


  
  #=> Keyboard Observers 1, Keyboard was shown. 2, Keyboard is hidden
  #NSNotificationCenter.defaultCenter.addObserver(self, selector: 'keyboardWasShown:', 
  #                                                      name:UIKeyboardDidShowNotification, object:nil)
  #NSNotificationCenter.defaultCenter.addObserver(self, selector: 'keyboardWillHide:', 
  #                                                      name:UIKeyboardWillHideNotification, object:nil)

  end



  def push_signup_view_controller(param)
    @signupViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[1]
    self.setModalTransitionStyle(UIModalTransitionStylePartialCurl)
    self.presentModalViewController(@signupViewController, animated: true)
    #self.navigationController.pushViewController(@signupViewController, animated:'YES')
  end

  def push_signin(param)
    #Implement Signin Process then
    #app = UIApplication.sharedApplication
    #@window = app.delegate.instance_variable_get(:@window)
    #controller = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[2]
    #@window.viewControllers(controller) # MainViewController
    self.showWithStatus("Signing In...")
     Dispatch::Queue.concurrent.async do
       login_user
      end #=> dispatch
      
    end

    def login_user
      signin = lambda do |succeeded, error|  
            if !error
               restart
               SVProgressHUD.dismiss 
            else
               SVProgressHUD.dismiss
               alert_message("Login failed! Please try again.") 
            end #=> if
          end #=> lambda

      PFUser.logInWithUsernameInBackground("#{userTextField.text}", password:"#{passTextField.text}", block: signin)
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

   #=> Retrieve ScrollView from Xib with tag
   def theScrollView
    @theScrollView ||= self.view.viewWithTag(1)

    @theScrollView.setFrame([[0,44], [320, 460]])  if iPhone5
    @theScrollView.setShowsVerticalScrollIndicator(false)
    return @theScrollView
    
    
   end

    #=> Retrieve Username from Xib with tag
   def userTextField
     @userTextField ||= self.view.viewWithTag(2)
    
   end

   #=> Retrieve Password from Xib with tag
   def passTextField
     @passTextField ||= self.view.viewWithTag(3)
   end

   def signInButton
    @signInButton ||= self.view.viewWithTag(5)
   end

   def signUpButton
    @signUpButton ||= self.view.viewWithTag(6)
   end

  


  def viewDidUnload
    #=> Remove observer
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  def dealloc
    #=> Remove observer
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  def paddingTextField(textField)
    paddingView = UIView.alloc.initWithFrame(CGRectMake(0, 0, 7, 20)).autorelease
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
  end

  def showWithStatus(status) 
    SVProgressHUD.showWithStatus("#{status}")
      
  end


  #=> called when textField start editting and adjust view
  def textFieldDidBeginEditing(textField)
    activeField = textField
    theScrollView.setContentOffset(CGPointMake(0,216), animated: true)
  end

  #=> called when textField next is hit and adjust view
  def textFieldShouldReturn(textField)

      nextTag = textField.tag + 1
      # Try to find next responder
      nextResponder = textField.superview.viewWithTag(nextTag)

      if (nextResponder)
          #theScrollView.setContentOffset(CGPointMake(0,textField.center.y-60), animated:true)
          theScrollView.setContentOffset(CGPointMake(0,216), animated:true)
          # Found next responder, so set it.
          nextResponder.becomeFirstResponder
          #puts "Next Responder #{nextTag}"
       else 
          #puts "Here"
          theScrollView.setContentOffset(CGPointMake(0,0), animated:true)
          textField.resignFirstResponder
          return true
      end

      return false
  end

 def keyboardWasShown(notification)
  #alert = UIAlertView.new
  #alert.message = "Keyboard shown!"
  #alert.show

  # Step 1: Get the size of the keyboard.
  #  CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  #  keyboardSize =  notification.userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey).size
     
    
    # Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
  #  contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
  #  theScrollView.contentInset = contentInsets;
  #  theScrollView.scrollIndicatorInsets = contentInsets; 
     
    # Step 3: Scroll the target text field into view.
  #  aRect = self.view.frame;
  #  aRect.size.height -= keyboardSize.height;
  #  if (!CGRectContainsPoint(aRect, activeTextField.frame.origin) ) 
  #      scrollPoint = CGPointMake(0.0, activeTextField.frame.origin.y - (keyboardSize.height-15));
  #      theScrollView.setContentOffset(scrollPoint, animated:YES)
  #  end


 end

 def keyboardWillHide(notification)
 end

 def iPhone5
    return true if self.view.bounds.size.height == 548.0
  end

 

end