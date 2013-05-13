class PhotoViewController < UIViewController
	def loadView
  

   
  end
  
  def viewDidLoad
    super
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
    self.title = 'Photo'
    self.view.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("background.png"))

     btnPost = UIBarButtonItem.alloc.initWithTitle("Post", style:UIBarButtonItemStyleBordered, target:self, action: 'post_content')
    self.navigationItem.rightBarButtonItem = btnPost

    #=> Listen for type event & Set Padding for TextField
    caption.delegate = self
    paddingTextField(caption)

    @defaults = NSUserDefaults.standardUserDefaults 
    theScrollView.delegate = self
    theScrollView.scrollEnabled = true
    #p "View Size height: #{self.view.bounds.size.height} width: #{self.view.bounds.size.width}"


    theScrollView.setContentSize(self.view.bounds.size)

    
   
    
    #self.performSelector('goBack', nil, afterDelay:5.0)
  end


  def viewDidAppear(view)
  	app = UIApplication.sharedApplication
    delegate = app.delegate
    #p delegate
    #=> Crop Image
    croppedRect = CGRectMake(0, 0, 657, 451)
    tmp = CGImageCreateWithImageInRect(delegate.instance_variable_get(:@temp_params).CGImage, croppedRect)
   
    #=> Set Image to ImageView
    captured_image_view.image = UIImage.imageWithCGImage(tmp)
    self.getLocation #=> current location is saved in @defaults["currentLocation"]
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

  def paddingTextField(textField)
    paddingView = UIView.alloc.initWithFrame(CGRectMake(0, 0, 7, 20)).autorelease
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
  end

    def post_content

     SVProgressHUD.showWithStatus("Posting...")
     Dispatch::Queue.concurrent.async do
       send_content(caption.text)
      end

  end

  def send_content(content)

    posting = lambda do |succeeded, error|  
            if !error
           
               #SVProgressHUD.dismiss 
               #SVProgressHUD.showSuccessWithStatus("Posted.")

               SVProgressHUD.showImage(UIImage.imageNamed('success.png'), status: "Posted.")
               caption.text = nil
               self.tabBarController.selectedIndex=0
            else
               #SVProgressHUD.dismiss
               #SVProgressHUD.showErrorWithStatus("Please try again!")
               SVProgressHUD.showImage(UIImage.imageNamed('error.png'), status: "Please try again.")
               #alert_message("Login failed! Please try again.") 
            end #=> if
          end #=> lambda

    app = UIApplication.sharedApplication
    delegate = app.delegate

    post = PFObject.objectWithClassName("Post") 
    post.setObject(content, forKey: "caption")
    post.setObject(current_user, forKey: "user")
    post.setObject("0", forKey: "likes")
    post.setObject("0", forKey: "commentCount")
    @defaults["currentLocation"].nil? ? post.setObject("Not Found", forKey: "location") : post.setObject(@defaults["currentLocation"], forKey: "location")
    croppedRect = CGRectMake(0, 0, 616, 530)
    tmp = CGImageCreateWithImageInRect(delegate.instance_variable_get(:@temp_params).CGImage, croppedRect)
    imageFile = PFFile.fileWithName("Image.jpg", data: UIImageJPEGRepresentation(UIImage.imageWithCGImage(tmp), 0.8))
    post.setObject(imageFile, forKey: "media")

    post.saveInBackgroundWithBlock(posting)

  end

  def current_user
    PFUser.currentUser
  end

   def getCity(params)
    geoCoder = CLGeocoder.alloc.init
    pBlock = lambda do |placemarks, error| 
      if !error
        if (placemarks.size > 0)   
          @defaults["currentLocation"] =  placemarks[0].locality
          #p @location
        else
          @defaults["currentLocation"] = "Not Found"
        end
      else
        p error
      end
    end

    geoCoder.reverseGeocodeLocation(params, completionHandler: pBlock)
   

  end

  def getLocation
      #=> 
      BW::Location.get do |result|
        #p result
        #p "From Lat #{result[:from].latitude}, Long #{result[:from].longitude}"
        if result[:to].nil?
          unless @defaults["locerror"]
             @defaults["locerror"] = 1
             alert = UIAlertView.alloc.initWithTitle("Heads up!",
             message:"To allow others in your area see your post, please enable location services.",
             delegate: nil,
             cancelButtonTitle: "Cancel",
             otherButtonTitles:nil)
        
              # Show it to the user
              alert.show
          end
        else
          #p "To Lat #{result[:to].latitude}, Long #{result[:to].longitude}"
          # p "Current Lat&Long: #{result[:to]}"
           self.getCity(result[:to])
          # p "Current City: "+@defaults["currentLocation"]
           BW::Location.stop
          
        end
      end
      #=>
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

  def captured_image_view
     @captured_image_viewsignUpButton ||= self.view.viewWithTag(2)
   end

   def caption
    @caption ||= self.view.viewWithTag(3)
   end

   #=> Retrieve ScrollView from Xib with tag
   def theScrollView
    @theScrollView ||= self.view.viewWithTag(1)
    @theScrollView.setFrame([[0,47], [320, 460]])  if iPhone5
    return @theScrollView
    
   end

    def iPhone5
     return true if self.view.bounds.size.height == 548.0
    end

end