class ProfileViewController < UIViewController
  def loadView
    #views = NSBundle.mainBundle.loadNibNamed "Navigation_2", owner:self, options:nil
    #self.view = views[0]
   
  end
  
  def viewDidLoad
    super
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
    self.title = 'Profile'
    self.view.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("background.png"))
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Profile", image: nil, tag: 1)
    self.tabBarItem.setFinishedSelectedImage UIImage.imageNamed('profile.png'), withFinishedUnselectedImage: UIImage.imageNamed('profile.png')
     btnPost = UIBarButtonItem.alloc.initWithTitle("Logout", style:UIBarButtonItemStyleBordered, target:self, action: 'logout_user')
    self.navigationItem.leftBarButtonItem = btnPost
    #self.performSelector('goBack', nil, afterDelay:5.0)

    #=> Listen for type event & Set Padding for TextField
 
    userTextField.delegate = self
   # passTextField.delegate = self
    emailTextField.delegate = self

    paddingTextField(userTextField)
    #paddingTextField(passTextField)
    paddingTextField(emailTextField)

    #=> Add Post Button to Nav Bar
      
    btnPost = UIBarButtonItem.alloc.initWithTitle("Save", style:UIBarButtonItemStyleBordered, target:self, action: 'save_profile')
    self.navigationItem.rightBarButtonItem = btnPost
    inviteFriends.addTarget(self, action: 'show_friends_view', forControlEvents:UIControlEventTouchUpInside)
    
    #profile_image_view.frame.height = 
    @tap = UITapGestureRecognizer.alloc.initWithTarget(self, action: 'profileAction:')
    @tap.cancelsTouchesInView = true
    @tap.numberOfTapsRequired = 1
    @tap.delegate = self
    profile_image_view.addGestureRecognizer(@tap)
    theScrollView.delegate = self
    theScrollView.scrollEnabled = true
    p "View Size height: #{self.view.bounds.size.height} width: #{self.view.bounds.size.width}"


    theScrollView.setContentSize(self.view.bounds.size)

    @defaults = NSUserDefaults.standardUserDefaults

    begin
      if !current_user.nil?
        userTextField.text = current_user.username 
        #passTextField.text = current_user.password
        emailTextField.text =  current_user.email if current_user.email
        
        query = PFUser.query
        user = query.getObjectWithId(current_user.objectId)
        user.objectForKey("currentCity").to_i == 1 ? currentCity.setOn(true) : currentCity.setOn(false)

        #@defaults = NSUserDefaults.standardUserDefaults

        #p @defaults["stupid"]
        #If current picture exists in cache and if media exists in parse
        #if !@defaults["currentPicture"].nil? && !current_user.objectForKey("media").nil? 
        if !current_user.objectForKey("media").nil? 
          #query = PFQuery.queryWithClassName("UserPhoto")
          #object = query.getObjectWithId(@defaults["currentPicture"])
          #theImage = object.objectForKey("imageFile")
          theImage = current_user.objectForKey("media")
          imageData = theImage.getData
          image = UIImage.imageWithData(imageData)
          profile_image_view.image = image
        end
      end
    rescue => error
    end
   

  end

  def show_friends_view
    #picker = ABPeoplePickerNavigationController.alloc.init
    #picker.peoplePickerDelegate = self;
    #self.presentModalViewController(picker, animated: true)
    #picker.release
    self.setModalTransitionStyle(UIModalTransitionStylePartialCurl)
    self.presentModalViewController(@myFriendInvitesController, animated: true)

  end

  def profileAction(recognizer)
      sheet = UIActionSheet.alloc.initWithTitle("Set profile picture", delegate:self, cancelButtonTitle: "Cancel", destructiveButtonTitle:nil, otherButtonTitles:"Take Photo", "Choose Existing Photo", nil)
      #Show sheet
      #@sheet.delegate = self;
      sheet.actionSheetStyle = UIActionSheetStyleDefault
      sheet.showFromTabBar(self.tabBarController.tabBar)
      
      #@sheet.release
  end

  def iPhone5
    return true if self.view.bounds.size.height == 548.0
  end

  def actionSheet(actionSheet, didDismissWithButtonIndex: buttonIndex)
   # puts "I got #{buttonIndex}"
   #puts "#{buttonIndex}"
    if camera_available? && takes_photos? || buttonIndex == 1
     

      controller = UIImagePickerController.alloc.init
      controller.sourceType = (buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum)

      requiredMediaType = KUTTypeImage
      controller.mediaTypes = [requiredMediaType]
      controller.allowsEditing = true
      controller.delegate = self

      self.navigationController.presentModalViewController(controller, animated:true)
    else
       if buttonIndex != 2
      alert = UIAlertView.alloc.initWithTitle("Error",
        message:"Sorry! camera not available.",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
      end
    end

  end

  def viewDidAppear(view)
    @myFriendInvitesController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[9] 
    @defaults["refreshView"] = true
   # p user.objectForKey("currentCity")
    

   
    #@tap.release

    #takeSimulatorSafePhotoWithPopoverFrame([[0,0], [640, 960]])
  end



  def save_profile
    SVProgressHUD.showWithStatus("Updating...")
    Dispatch::Queue.concurrent.async do
      update_user
      
    end

  end

  def update_user
    user = current_user

      user.setObject("#{userTextField.text}", forKey: "username")
      #user.setObject("#{passTextField.text}", forKey: "password") if !passTextField.text.nil?
      user.setObject("#{emailTextField.text}", forKey: "email")
      #p currentCity.isOn
      currentCity.isOn ? user.setObject("1", forKey: "currentCity") : user.setObject("0", forKey: "currentCity")
      current_user.save
    SVProgressHUD.dismiss
  end


  def takeSimulatorSafePhotoWithPopoverFrame(popoverFrame) 
    
    # Load the imagePicker
    imagePicker = UIImagePickerController.alloc.init

    # Set the sourceType to default to the PhotoLibrary and use the ivar to flag that
    # it will be presented in a popover

    sourceType = UIImagePickerControllerSourceTypePhotoLibrary
    puts "Setting sourceType to Library for Stimulator"
    usingPopover = true
    
    # Check if the camera is available - if it is, reset the sourceType to the camera
    # and indicate that the popover won't be used.

    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera) 
        puts "Camera device found"
        sourceType = UIImagePickerControllerSourceTypeCamera
        self.usingPopover = false
    end

    # Set the sourceType of the imagePicker

    imagePicker.setSourceType(sourceType)

    # Set up the other imagePicker properties
    imagePicker.allowsEditing = false
    imagePicker.delegate = self
    
    # If the sourceType isn't the camera, then use the popover to present
    # the imagePicker, with the frame that's been passed into this method

    if (sourceType != UIImagePickerControllerSourceTypeCamera) 
      puts "Camera device not found, show library for Stimulator"
      @popover = UIPopoverController.alloc.initWithContentViewController(imagePicker)
        @popover.delegate = self
        @popover.presentPopoverFromRect(popoverFrame, inView:self.view, permittedArrowDirections:UIPopoverArrowDirectionAny, animated: true)

     else 

  # Present a standard imagePicker as a modal view
        self.navigationController.presentModalViewController(imagePicker, animated: true)    
    end
    
end

  def logout_user
    

    appDelegate = UIApplication.sharedApplication.delegate
    myEntryViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil).first
    self.view.removeFromSuperview
    appDelegate.instance_variable_get(:@window).rootViewController = myEntryViewController
    appDelegate.instance_variable_get(:@window).makeKeyAndVisible

    PFUser.logOut #=> Logout current user with Parse

  
  end

  def current_user
    PFUser.currentUser
  end
  
   #=> Retrieve ScrollView from Xib with tag
   def theScrollView
    @theScrollView ||= self.view.viewWithTag(1)
    @theScrollView.setFrame([[0,44], [320, 460]])  if iPhone5
    return @theScrollView
    
   end

   #=> Retrieve ScrollView from Xib with tag
   def inviteFriends
    @inviteFriends ||= self.view.viewWithTag(8)
   end

   def profile_image_view
     @profile_image_view ||= self.view.viewWithTag(2)
     
   end

   def userTextField
      @userTextField ||= self.view.viewWithTag(3)
   end

   

    #def passTextField
    #  @passTextField||= self.view.viewWithTag(4)
    #end

    def emailTextField
      @emailTextField ||= self.view.viewWithTag(4)
   end

   def currentCity
      @currentCity ||= self.view.viewWithTag(7)
   end

   

    def imageWithImage(image, newSize)

     UIGraphicsBeginImageContext( newSize );
     image.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
     newImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();

     #croppedRect = CGRectMake(0, 299, 299, 132)
      #tmp = CGImageCreateWithImageInRect(the_image.CGImage, croppedRect)
      #profile_image_view.image  = UIImage.imageWithCGImage(tmp)

     return newImage
  end

  def resizeImageToMaxSize(max, path)
    imageData = NSData.dataWithData(UIImageJPEGRepresentation(path, 1.0))
    #imgDataRef = imageData as CFDataRef

    imageSource= CGImageSourceCreateWithData(imageData, nil)
    return nil if !imageSource
    options = CFDictionaryRef.new
    options =  {  CGImageSourceCreateThumbnailWithTransform => CFBooleanTrue,
                  CGImageSourceCreateThumbnailFromImageIfAbsent => CFBooleanTrue,
                  CGImageSourceThumbnailMaxPixelSize => NSNumber.numberWithFloat(max)
    }
    imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
    scaled = UIImage.imageWithCGImage(imgRe)
    CGImageRelease(imgRef)
    CFRelease(imageSource)

    return scaled

  end
  # UIImagePickerController Delegate Methods
  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    #p "Picker returned successfully with EDIT INFO => #{info}"
    mediaType = info.objectForKey(UIImagePickerControllerMediaType)

    if mediaType.isEqualToString(KUTTypeMovie)
      video_url = info.objectForKey(UIImagePickerControllerMediaURL)
      #@label.text = "Video located at #{video_url}"
      #p @label.text
    elsif mediaType.isEqualToString(KUTTypeImage)
      metadata = info.objectForKey(UIImagePickerControllerMediaMetadata)
      #the_image = info.objectForKey(UIImagePickerControllerOriginalImage)
      the_image = info.objectForKey(UIImagePickerControllerEditedImage)

      #@label.text = "Image = #{the_image}"
      #p "Image Metadata = #{metadata}"
      #p @label.text 
      #profile_image_view.image = imageWithImage(the_image, CGSizeMake(598, 264))
      #408, 305 OR 640, 480 if scalable from mobile 301, 226
      croppedRect = CGRectMake(0, 0, 657, 290)
      #tmp = CGImageCreateWithImageInRect(imageWithImage(the_image, CGSizeMake(600, 450)).CGImage, croppedRect)
      @tmp = CGImageCreateWithImageInRect(the_image.CGImage, croppedRect)
      profile_image_view.image  = UIImage.imageWithCGImage(@tmp)

      SVProgressHUD.showWithStatus("Updating...")
      Dispatch::Queue.concurrent.async do
          self.uploadImage(UIImageJPEGRepresentation(profile_image_view.image, 0.5), "media")
          
      end
     
        
      

      #@tmp.release

      #profile_image_view.setImage(the_image, forState:UIControlStateNormal)
    end

    picker.dismissModalViewControllerAnimated(true)
  end

  def uploadImage(imageData, key)
    imageFile = PFFile.fileWithName("Image.jpg", data:imageData)
    query = PFUser.query
    user = query.getObjectWithId(current_user.objectId)
    #@user = current_user
    user.setObject(imageFile, forKey:"#{key}")

    updating = lambda do |succeeded, error|  
            if !error
               @defaults = NSUserDefaults.standardUserDefaults
               #@defaults["currentPicture"] = @user.objectId
               croppedRect = CGRectMake(0, 0, 76, 76)
               tmp = CGImageCreateWithImageInRect(imageWithImage(profile_image_view.image, CGSizeMake(177, 80)).CGImage, croppedRect)
                    #@tmp = CGImageCreateWithImageInRect(the_image.CGImage, croppedRect)
               #profile_image_view.image  = UIImage.imageWithCGImage(tmp)
               self.uploadThumb(UIImageJPEGRepresentation(UIImage.imageWithCGImage(tmp), 0.8), "thumb")
               #SVProgressHUD.showImage(UIImage.imageNamed('success.png'), status: "Updated.")
              
            else
               p error
               SVProgressHUD.showImage(UIImage.imageNamed('error.png'), status: "Please try again!")
            
            end #=> if
          end #=> lambda

    user.saveInBackgroundWithBlock(updating)


  end

  def uploadThumb(imageData, key)
    imageFile = PFFile.fileWithName("Image.jpg", data:imageData)
    query = PFUser.query
    user = query.getObjectWithId(current_user.objectId)
    #user = current_user
    user.setObject(imageFile, forKey:"#{key}")

    updating = lambda do |succeeded, error|  
            if !error
               @defaults = NSUserDefaults.standardUserDefaults
               #@defaults["currentPicture"] = @user.objectId
               SVProgressHUD.showImage(UIImage.imageNamed('success.png'), status: "Updated.")
            
            else
               
               SVProgressHUD.showImage(UIImage.imageNamed('error.png'), status: "Please try again!")
            
            end #=> if
          end #=> lambda

    user.saveInBackgroundWithBlock(updating)


  end

  def uploadImageOld(imageData)

    imageFile = PFFile.fileWithName("Image.jpg", data:imageData)

     user_photo = lambda do |succeeded, error|  

            if !error
                
                @defaults = NSUserDefaults.standardUserDefaults
                @defaults["currentPicture"] = @userPhoto.objectId
                p @defaults["currentPicture"]
                SVProgressHUD.dismiss
                #self.refresh(nil)
            else
                #Log details of the failure
                SVProgressHUD.dismiss
                p "Error: #{error} #{error.userInfo}"
              #return error.userInfo["error"]
            end
        end
     
    image_file = lambda do |succeeded, error|  

            if !error

              #Create a PFObject around a PFFile and associate it with the current user
              @userPhoto = PFObject.objectWithClassName("UserPhoto") 
              @userPhoto.setObject(imageFile, forKey: "imageFile")
             
              # Set the access control list to current user for security purposes
              @userPhoto.ACL = PFACL.ACLWithUser(PFUser.currentUser)
                   
              user = PFUser.currentUser
              @userPhoto.setObject(user, forKey:"user")
              @userPhoto.saveInBackgroundWithBlock(user_photo)
            else
              #Log details of the failure
              SVProgressHUD.dismiss
              p "Error: #{error} #{error.userInfo}"
              #return error.userInfo["error"]
            end
        end
    #Save PFFile
    imageFile.saveInBackgroundWithBlock(image_file)


  end


  def imagePickerControllerDidCancel(picker)
    #@label.text = "Picker was cancelled"
    #p @label.text
    picker.dismissModalViewControllerAnimated(true)
  end

  def paddingTextField(textField)
    paddingView = UIView.alloc.initWithFrame(CGRectMake(0, 0, 7, 20)).autorelease
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
  end


  #=> called when textField start editting and adjust view
  def textFieldDidBeginEditing(textField)
    activeField = textField
    theScrollView.setContentOffset(CGPointMake(0,116), animated: true)
  end

  #=> called when textField next is hit and adjust view
  def textFieldShouldReturn(textField)

      nextTag = textField.tag + 1
      # Try to find next responder
      nextResponder = textField.superview.viewWithTag(nextTag)

      if (nextResponder)
          theScrollView.setContentOffset(CGPointMake(0,116), animated:true)
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


  def camera_available?
    UIImagePickerController.isSourceTypeAvailable UIImagePickerControllerSourceTypeCamera 
  end

  def cameraSupportsMedia paramMediaType, paramSourceType
    availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(paramSourceType)

    availableMediaTypes.include? paramMediaType
  end

  def shoots_videos?
    cameraSupportsMedia KUTTypeMovie, UIImagePickerControllerSourceTypeCamera
  end

  def takes_photos?
    cameraSupportsMedia KUTTypeImage, UIImagePickerControllerSourceTypeCamera
  end

  def has_front_camera?
    UIImagePickerController.isCameraDeviceAvailable UIImagePickerControllerCameraDeviceFront 
  end

  def has_rear_camera?
    UIImagePickerController.isCameraDeviceAvailable UIImagePickerControllerCameraDeviceRear 
  end

  def front_camera_flash?
    UIImagePickerController.isFlashAvailableForCameraDevice UIImagePickerControllerCameraDeviceFront 
  end

  def rear_camera_flash?
    UIImagePickerController.isFlashAvailableForCameraDevice UIImagePickerControllerCameraDeviceRear 
  end

end