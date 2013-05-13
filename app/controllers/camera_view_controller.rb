class CameraViewController < UIViewController
  def loadView
    #views = NSBundle.mainBundle.loadNibNamed "Navigation_2", owner:self, options:nil
    #self.view = views[0]
 
  end
  
  def viewDidLoad
    super
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
    self.title = 'Camera'
    self.view.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("background.png"))
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Camera", image: nil, tag: 1)
    #self.tabBarItem.setFinishedSelectedImage(UIImage.imageNamed('camera.png'))
    self.tabBarItem.setFinishedSelectedImage UIImage.imageNamed('camerablur.png'), withFinishedUnselectedImage: UIImage.imageNamed('camera.png')
    #self.performSelector('goBack', nil, afterDelay:5.0)
    
    
    #=> Listen for type event & Set Padding for TextField
    #caption.delegate = self
    #paddingTextField(caption)

    #=> Add Post Button to Nav Bar
      
    #btnPost = UIBarButtonItem.alloc.initWithTitle("Post", style:UIBarButtonItemStyleBordered, target:self, action: 'post_content')
    #self.navigationItem.rightBarButtonItem = btnPost

    
  
  end

  def post_content
    myPhotoViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[6]
    #self.setModalTransitionStyle(UIModalTransitionStyleCrossDissolve)
    #self.presentModalViewController(myPhotoViewController, animated: true)
    self.navigationController.pushViewController(myPhotoViewController, animated: true)

  end

  def viewDidAppear(view)

    if camera_available? && takes_photos?
      #@label.text = "Camera Good to Move on"
      #p "Camera good"

      controller = UIImagePickerController.alloc.init
      controller.sourceType = UIImagePickerControllerSourceTypeCamera

      requiredMediaType = KUTTypeImage
      controller.mediaTypes = [requiredMediaType]
      controller.allowsEditing = true
      controller.delegate = self

      self.navigationController.presentModalViewController(controller, animated:true)
    else
      #@label.text = "Camera not Available - Probably run in a simulator"
      alert = UIAlertView.alloc.initWithTitle("Error",
        message:"Sorry! camera not available.",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
    end
    #takeSimulatorSafePhotoWithPopoverFrame([[0,0], [640, 960]])
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

   def captured_image_view
     @captured_image_viewsignUpButton ||= self.view.viewWithTag(2)
   end

   def caption
    @caption ||= self.view.viewWithTag(3)
   end

   #=> Retrieve ScrollView from Xib with tag
   def theScrollView
    @theScrollView ||= self.view.viewWithTag(1)
    
   end

  # UIImagePickerController Delegate Methods
  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    p "Picker returned successfully"
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
      app = UIApplication.sharedApplication
      delegate = app.delegate
      #p delegate
     # p the_image
      delegate.instance_variable_set(:@temp_params, the_image)
      p delegate.instance_variable_get(:@temp_params)
      #@temp_params = the_image
      #captured_image_view.image = the_image
    end

     picker.dismissModalViewControllerAnimated(true)
     myPhotoViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[6]
     self.navigationController.pushViewController(myPhotoViewController, animated: true)
  end

  def imagePickerControllerDidCancel(picker)
   # @label.text = "Picker was cancelled"
   # p @label.text
    picker.dismissModalViewControllerAnimated(true)
    self.tabBarController.selectedIndex=0
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

      if (nextResponder)
          theScrollView.setContentOffset(CGPointMake(0,textField.center.y-60), animated:true)
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