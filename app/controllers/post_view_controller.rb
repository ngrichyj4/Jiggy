class PostViewController < UIViewController
  def loadView
    #views = NSBundle.mainBundle.loadNibNamed "Navigation_2", owner:self, options:nil
    #self.view = views[0]

   
  end
  
  def viewDidLoad
    super
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
    self.title = 'Post'
    postTextArea.delegate = self
    #self.view.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("background.png"))
    self.view.backgroundColor = UIColor.whiteColor
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Post", image: nil, tag: 1)
    self.tabBarItem.setFinishedSelectedImage UIImage.imageNamed('post.png'), withFinishedUnselectedImage: UIImage.imageNamed('post.png')

    btnPost = UIBarButtonItem.alloc.initWithTitle("Post", style:UIBarButtonItemStyleBordered, target:self, action: "post_content")
    self.navigationItem.rightBarButtonItem = btnPost

    btnPost = UIBarButtonItem.alloc.initWithTitle("Cancel", style:UIBarButtonItemStyleBordered, target:self, action: 'cancel_post')
    self.navigationItem.leftBarButtonItem = btnPost
    #=>iPhone 5 Specifics
    profile_image_view.setFrame([[9,15], [50, 50]])  if iPhone5
    postTextArea.setFrame([[67,15], [243, 179]])  if iPhone5
    #=>

    @placeholderLabel = UILabel.alloc.initWithFrame([[10.0, 0.0], [243.0, 34.0]])
    @placeholderLabel.setText("Got something to say?")
    @placeholderLabel.setBackgroundColor(UIColor.clearColor)
    @placeholderLabel.setFont(UIFont.fontWithName("HelveticaNeue-Italic", size:13.0))
    @placeholderLabel.setTextColor(UIColor.lightGrayColor)
    postTextArea.addSubview(@placeholderLabel)

    @defaults = NSUserDefaults.standardUserDefaults 

    # this creates the CCLocationManager that will find your current location
    #locationManager = CLLocationManager.alloc.init.autorelease
    #locationManager.delegate = self
    #locationManager.desiredAccuracy = 10.0
    #locationManager.startUpdatingLocation

    

    #self.performSelector('goBack', nil, afterDelay:5.0)
  end

  def viewDidAppear(view)
    postTextArea.becomeFirstResponder
    self.getLocation #=> current location is saved in @defaults["currentLocation"]

    begin
      #If current picture exists in cache and if media exists in parse
      #if !@defaults["currentPicture"].nil? && !current_user.objectForKey("media").nil? 
      if  !current_user.objectForKey("media").nil? 
        p "Inside Post Section"
          query = PFUser.query
          user = query.getObjectWithId(current_user.objectId)
          theImage = user.objectForKey("media")
          imageData = theImage.getData
          image = UIImage.imageWithData(imageData)
          profile_image_view.image = image
      end
  rescue => error
  end
  end

  def iPhone5
    return true if self.view.bounds.size.height == 548.0
  end

 

  def resize_profile(the_image)
      croppedRect = CGRectMake(0, 0, 100, 100)
      tmp = CGImageCreateWithImageInRect(imageWithImage(the_image, CGSizeMake(140, 105)).CGImage, croppedRect)
      #@tmp = CGImageCreateWithImageInRect(the_image.CGImage, croppedRect)
      profile_image_view.image  = UIImage.imageWithCGImage(@tmp)
  end

  def profile_image_view
     @profile_image_view ||= self.view.viewWithTag(2)
     
   end

   def imageWithImage(image, newSize)

     UIGraphicsBeginImageContext( newSize )
     image.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
     newImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     return newImage
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

  def locationManager(manager, didUpdateToLocation: newLocation, fromLocation: oldLocation)

    # this creates a MKReverseGeocoder to find a placemark using the found coordinates
    geoCoder = MKReverseGeocoder.alloc.initWithCoordinate(newLocation.coordinate)
    geoCoder.delegate = self
    geoCoder.start
  end

  def locationManager(manager, didChangeAuthorizationStatus: auth)
    alert = UIAlertView.alloc.initWithTitle("Heads up!",
        message:"To allow others in your area see your post, please enable location services.",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
  end

  # this delegate method is called if an error occurs in locating your current location
 def locationManager(manager, didFailWithError:error )

  p "locationManager: #{manager} didFailWithError: #{error}" 
 end

  #this delegate is called when the reverseGeocoder finds a placemark
  def reverseGeocoder(geocoder, didFindPlacemark:placemark)

      myPlacemark = placemark
      # with the placemark you can now retrieve the city name
      city = myPlacemark.addressDictionary.objectForKey(kABPersonAddressCityKey)
      p city
      alert = UIAlertView.alloc.initWithTitle("Location",
        message:"#{city}",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
  end

  # this delegate is called when the reversegeocoder fails to find a placemark
  def reverseGeocoder(geocoder, didFailWithError:error)

      p "reverseGeocoder: #{geocoder} didFailWithError: #{error}"
  end

  def cancel_post
    self.tabBarController.selectedIndex=0
  end

  def post_content

     SVProgressHUD.showWithStatus("Posting...")
     Dispatch::Queue.concurrent.async do
       send_content(postTextArea.text)
      end

  end

  def send_content(content)

    posting = lambda do |succeeded, error|  
            if !error
           
               #SVProgressHUD.dismiss 
               #SVProgressHUD.showSuccessWithStatus("Posted.")

               SVProgressHUD.showImage(UIImage.imageNamed('success.png'), status: "Posted.")
               postTextArea.text = nil
            else
               #SVProgressHUD.dismiss
               #SVProgressHUD.showErrorWithStatus("Please try again!")
               SVProgressHUD.showImage(UIImage.imageNamed('error.png'), status: "Please try again!")
               #alert_message("Login failed! Please try again.") 
            end #=> if
          end #=> lambda


    post = Post.new
    post.content = content
    post.user = current_user
    post.likes = "0"
    post.commentCount = "0"
    @defaults["currentLocation"].nil? ? post.location = "Not Found" : post.location = @defaults["currentLocation"] 
    # @defaults["currentLocation"]
    post.saveInBackgroundWithBlock(posting)

  end


  def current_user
    PFUser.currentUser
  end


  def postTextArea
   
    @postTextArea ||= self.view.viewWithTag(3)
   
  end

  def textViewDidChange(textView) 
      if(textView.hasText) 
          @placeholderLabel.hidden = true
      
      else 
          @placeholderLabel.hidden = false
     end
  end

   def viewDidUnload
    @placeholderLabel.release
   end

  def textViewDidEndEditing(textView) 
      if(textView.hasText) 
          @placeholderLabel.hidden = true
      
      else 
          @placeholderLabel.hidden = false
     end
  end


end