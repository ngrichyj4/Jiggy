class MainViewController < UIViewController

  def loadView
    #views = NSBundle.mainBundle.loadNibNamed "Navigation_2", owner:self, options:nil
    #self.view = views[0]
 
  end
  
  def viewDidLoad
    super
  
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
  

    self.title = 'Activity'
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Activity", image: nil, tag: 1)
    self.tabBarItem.setFinishedSelectedImage UIImage.imageNamed('activity.png'), withFinishedUnselectedImage: UIImage.imageNamed('activity.png')

   
    @currentSection = nil
    @defaults = NSUserDefaults.standardUserDefaults

    @customCell = NSBundle.mainBundle.loadNibNamed('CustomCell', owner:self, options:nil).first  
    iPhone5 ? @table = UITableView.alloc.initWithFrame(CGRectMake(0, 0, 320, 500)) : @table = UITableView.alloc.initWithFrame(CGRectMake(0, 0, 320, 410))
    
   # @table.rowHeight = 360
    @table.setSeparatorStyle(UITableViewCellSeparatorStyleNone)
    #@table.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("background.png"))
    @table.backgroundColor = UIColor.whiteColor
    
   self.view.addSubview @table
   
 
    #self.performSelector('goBack', nil, afterDelay:5.0)
  end

  def viewDidAppear(animated)


      #=> Retrieve all post depending on user location settings
    #@posts = nil
    
     #Dispatch::Queue.main.sync do
     if @defaults["refreshView"].nil?
       SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeGradient)
       fetch_posts
       @defaults["refreshView"] = true
     end
     
    #end

    
   @table.delegate = self
   @table.dataSource = self 
   theScrollView.delegate = self
   #@table.reloadData
   @data = ("A".."Z").to_a
   
   @refreshHeaderView ||= begin
      rhv = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - @table.bounds.size.height, @table.bounds.size.width, @table.bounds.size.height))
      rhv.delegate = self
      rhv.refreshLastUpdatedDate    
      @table.addSubview(rhv)
      rhv
    end
    
  
    
     

  end

  def viewDidUnload
    @defaults["refreshView"] = nil
  end 

  def dealloc
    @defaults["refreshView"] = nil
  end
  
  def fetch_posts
    user = current_user
    useLocation = user.objectForKey("currentCity").to_i
    @profilePicture = Array.new
    @postTime = Array.new
    p @defaults["currentLocation"]
    self.getLocation if @defaults["currentLocation"].nil?
    #query = PFQuery.queryWithClassName("Post")
    query = Post.query
    query.orderByDescending("createdAt")
    query.limit = 10
    useLocation == 1 && !@defaults["currentLocation"].nil? ? query.whereKey("location", equalTo: @defaults["currentLocation"]) : nil
     @posts = query.find
    
    if  @posts.nil?
        @posts = Array.new #=> Initialize manually for UITable
        alert = UIAlertView.alloc.initWithTitle("Error",
        message:"Sorry! An error occured while trying to fetch posts. Please try again! ",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
      end
 
    
    #puts "You have #{@posts.length} objects of class #{@posts.first.class}."

    #Retrieve profile pic from parse
    Dispatch::Queue.concurrent.async do
      query = PFUser.query
      @posts.each do |post|
        #p post.objectForKey("user").objectId
        user = query.getObjectWithId(post.objectForKey("user").objectId)
        theImage = user.objectForKey("thumb")
          if theImage.nil? #If user doesn't have profile image, use default image instead
            image = nil
          else
            #imageData = theImage.getData
            #image = UIImage.imageWithData(imageData)
            image = theImage
          end
        @profilePicture << image
      end
      #p @profilePicture
    end
    #Retrieve post time ago
    Dispatch::Queue.concurrent.async do
      @posts.each do |post|
        #p post.createdAt
        @postTime << timeago(post.createdAt)
        #p @postTime
      end
    end

    #Retrieve username from parse
    Dispatch::Queue.concurrent.async do
    @username = Array.new
      query = PFUser.query
      @posts.each do |post|
        #p post.objectForKey("user").objectId
        user = query.getObjectWithId(post.objectForKey("user").objectId)
        @username << user.objectForKey("username")
       
      end
      SVProgressHUD.dismiss
      #theScrollView.setContentOffset(CGPointMake(200, 0), animated: true)
      if @posts.length > 2
        scrollIndexPath = NSIndexPath.indexPathForRow(0, inSection:2)
        @table.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition:UITableViewScrollPositionBottom, animated:true)
      end
    
    end
    #query.find do |objects, error|
    #  puts "You have #{objects.length} objects of class #{objects.first.class}."
      #p objects[0].objectId
    #  @posts = objects
    #  SVProgressHUD.dismiss
    #end
  end

   def theScrollView
    @theScrollView ||= self.view.viewWithTag(1)
    
   end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CustomCellIdentifier"

     cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      #UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
       
      cell = NSBundle.mainBundle.loadNibNamed('CustomCell', owner:self, options:nil).first
     
      #button.release

      return cell
    end

    # put your data in the cell
    #cell.textLabel.text = @data[indexPath.row]
    #cell.viewWithTag(1).text = @data[indexPath.row]
    #cell.viewWithTag(1).text = @data[indexPath.row]
    #p "Reusing...#{indexPath.section}"
    #p cell.contentView.subviews.count
    #button = cell.contentView.subviews[5]
    #cell.viewWithTag(56).setTag(6+indexPath.section)

     #@defaults["currentSection"] =  indexPath.section
     #@defaults["postObjectId"] = @posts[indexPath.section].objectId
    #p button
    #Dispatch::Queue.concurrent.async do
      content =   @posts[indexPath.section].objectForKey("content")
      media =     @posts[indexPath.section].objectForKey("media")
      caption =   @posts[indexPath.section].objectForKey("caption")
      likes =     @posts[indexPath.section].objectForKey("likes")
      city =      @posts[indexPath.section].objectForKey("location")
      commentCount =      @posts[indexPath.section].objectForKey("commentCount")
      profilePic = PFImageView.alloc.initWithFrame(CGRectMake(6, 33, 308, 265))
      profilePic.image = UIImage.imageNamed("postloading.png") # placeholder image
      profilePic.tag = 55
      if media.nil?
         cell.viewWithTag(6).text = " "
         #cell.viewWithTag(6).font = UIFont.fontWithName("ProximaNova-Light", size:14.0)
         label = UILabel.new
         label.text = "#{content}"
         #label.backgroundColor = UIColor.clearColor
         label.frame = [[6,33],[308,265]]
         label.font = UIFont.fontWithName("ProximaNova-Light", size:30.0)
         #p UIFont.fontNamesForFamilyName("ProximaNova-Light")
         label.setTextColor(UIColor.colorWithRed(194.0/255.0, green: 199.0/255.0, blue: 199.0/255.0, alpha:1))
         label.tag = 56
         label.adjustsFontSizeToFitWidth =  false
         label.lineBreakMode = UILineBreakModeWordWrap
         label.numberOfLines = 0
         cell.contentView.addSubview(label)

         cell.viewWithTag(2).text = "#{likes} likes"
         cell.viewWithTag(9).text = "#{city}"

         #cell.contentView.subviews.each do |subview|
           #p subview
             #if subview.isKindOfClass(PFImageView.class)
             # p "removed from superview"
             # subview.removeFromSuperview
            # p cell.viewWithTag(55)

               cell.viewWithTag(55).removeFromSuperview if !cell.viewWithTag(55).nil?   #PFImageView
            
               #cell.viewWithTag(56).removeFromSuperview if !cell.viewWithTag(56).nil?   #Like Button
               #cell.viewWithTag(57).removeFromSuperview if !cell.viewWithTag(57).nil?   #Comment Button
               #cell.viewWithTag(58).removeFromSuperview if !cell.viewWithTag(58).nil?   #View All Comments
               #=> Like Button
               #button = UIButton.alloc.initWithFrame(CGRectMake(6, 166, 63, 20))
               #btnImage = UIImage.imageNamed("like.png")
               #button.setImage(btnImage, forState:UIControlStateNormal)
               #button.addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
               #button.tag = 56
               #cell.contentView.addSubview(button)

               #=> Comment Button
               #button = UIButton.alloc.initWithFrame(CGRectMake(77, 166, 85, 18))
               #btnImage = UIImage.imageNamed("comment.png")
               #button.setImage(btnImage, forState:UIControlStateNormal)
               #button.addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
               #button.tag = 57
               #cell.contentView.addSubview(button)

               #=> View All Comments Button
               #button = UIButton.alloc.initWithFrame(CGRectMake(188, 166, 125, 21))
               #button.titleLabel.text = "view all comments"
               #button.titleLabel.font = UIFont.fontWithName("HelveticaNeue-Bold", size:14.0)
               #button.setTitleColor(UIColor.colorWithRed(210.0/255.0, green: 215.0/255.0, blue: 216.0/255.0, alpha:1), forState:UIControlStateNormal)
               #btnImage = UIImage.imageNamed("like.png")
               #button.setTitle("view all comments", forState:UIControlStateNormal)
               #button.addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
               #button.tag = 58
               #cell.contentView.addSubview(button)
      

               #cell.viewWithTag(3).removeFromSuperview if !cell.viewWithTag(3).nil?     #Default View comments button
               #cell.viewWithTag(4).removeFromSuperview if !cell.viewWithTag(4).nil?     #Default Like Button
               #cell.viewWithTag(5).removeFromSuperview if !cell.viewWithTag(5).nil?     #Default Comments button
               cell.viewWithTag(8).removeFromSuperview if !cell.viewWithTag(8).nil?     #Default Image Holder
               #removePos(cell.viewWithTag(3), 50)
               #changePos(cell.viewWithTag(4), 270)
               #changePos(cell.viewWithTag(5), 270)

          #  end
           #profilePic.file = nil
           #cell.contentView.addSubview(profilePic)
           #profilePic.loadInBackground
        # end
      else
        #cell.viewWithTag(56).removeFromSuperview if !cell.viewWithTag(56).nil?  #Like Button
        #cell.viewWithTag(57).removeFromSuperview if !cell.viewWithTag(57).nil?   #Comment Button
        #cell.viewWithTag(58).removeFromSuperview if !cell.viewWithTag(58).nil?   #View All Comments
        cell.viewWithTag(56).removeFromSuperview if !cell.viewWithTag(56).nil? 
        cell.viewWithTag(6).text = caption
        cell.viewWithTag(6).font = UIFont.fontWithName("ProximaNova-Light", size:14.0)
        cell.viewWithTag(2).text = "#{likes} likes"
        cell.viewWithTag(9).text = "#{city}"
        #addPos(cell.viewWithTag(3), 50)
        #=> Like Button
        #button = UIButton.alloc.initWithFrame(CGRectMake(6, 326, 63, 20))
        #btnImage = UIImage.imageNamed("like.png")
        #button.setImage(btnImage, forState:UIControlStateNormal)
        #button.addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
        #button.tag = 56
        #cell.contentView.addSubview(button)

       #=> Comment Button
         #      button = UIButton.alloc.initWithFrame(CGRectMake(77, 326, 85, 18))
         #      btnImage = UIImage.imageNamed("comment.png")
         #      button.setImage(btnImage, forState:UIControlStateNormal)
         #      button.addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
         #      button.tag = 57
         #      cell.contentView.addSubview(button)

               #=> View All Comments Button
          #     button = UIButton.alloc.initWithFrame(CGRectMake(188, 326, 125, 21))
               #button.titleLabel.text = "view all comments"
           #    button.titleLabel.font = UIFont.fontWithName("HelveticaNeue-Bold", size:14.0)
           #    button.setTitleColor(UIColor.colorWithRed(210.0/255.0, green: 215.0/255.0, blue: 216.0/255.0, alpha:1), forState:UIControlStateNormal)
               #btnImage = UIImage.imageNamed("like.png")
           #    button.setTitle("view all comments", forState:UIControlStateNormal)
           #    button.addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
           #    button.tag = 58
           #    cell.contentView.addSubview(button)
        
        profilePic.file = media
        cell.contentView.addSubview(profilePic)
        profilePic.loadInBackground


      end
    #end

    cell.viewWithTag(3).addTarget(self, action: 'show_comment_view:', forControlEvents:UIControlEventTouchUpInside)
    cell.viewWithTag(3).setTitle("view all #{commentCount} comments", forState:UIControlStateNormal)
    cell.viewWithTag(4).addTarget(self, action: 'like_post:', forControlEvents:UIControlEventTouchUpInside)
    cell.viewWithTag(5).addTarget(self, action: 'show_comment_view:', forControlEvents:UIControlEventTouchUpInside)
    #@defaults["currentSection"] = indexPath.section
    
    #p "In section #{indexPath.section} Cache ObjectID: "+@defaults["postObjectId"]+" indexPath ObjectID: "+@posts[indexPath.section].objectId
    cell

  end

  def removePos(button, y)
    buttonFrame = button.frame
    buttonFrame.origin.y -= y
    button.frame = buttonFrame
  end

   def addPos(button, y)
    buttonFrame = button.frame
    buttonFrame.origin.y += y
    button.frame = buttonFrame
  end

 

  def show_comment_view(sender)
   
    #myCommentViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[8]
    #app = UIApplication.sharedApplication
    #ssdelegate = app.delegate
    cell = sender.superview.superview
    section = @table.indexPathForCell(cell).section
    p "comment button @ #{section} pressed"
    @defaults["postObjectId"] = @posts[section].objectId
    SVProgressHUD.show
    Dispatch::Queue.concurrent.async do
      fetch_comment_view
    end
    
    
    #self.setModalTransitionStyle(UIModalTransitionStyleCrossDissolve)
    #self.navigationController.pushViewController(myCommentViewController, animated: true)
  end

  def fetch_comment_view
    Dispatch::Queue.main.sync do
      myCommentViewController = NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[8]
      self.setModalTransitionStyle(UIModalTransitionStylePartialCurl)
      self.presentModalViewController(myCommentViewController, animated: true)
      SVProgressHUD.dismiss
    end
  end

  def current_user
    PFUser.currentUser
  end

  def like_post(sender)
    # Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton

    #cell = sender.superview.superview
    #if !sender.tag.equal?(0) 
      #button = cell.viewWithTag(sender.tag)
    #  clickedButtonPath = @table.indexPathForCell(cell)
    #  button = @table.cellForRowAtIndexPath(clickedButtonPath).contentView.viewWithTag(@likebutton)
    #  btnImage = UIImage.imageNamed("liked.png")
    #  button.setImage(btnImage, forState:UIControlStateNormal)
    #end
    SVProgressHUD.show
     Dispatch::Queue.concurrent.async do
        cell = sender.superview.superview
        section = @table.indexPathForCell(cell).section
        p "button @ #{section} pressed"
        like_content(section)
      end
  
  end

  def like_content(section)

      #p section
      #section -=1 #Set indexPath to current
      likes = @posts[section].objectForKey("likes").to_i
      likes +=1
      query = PFQuery.queryWithClassName("Post")
      post = query.getObjectWithId(@posts[section].objectId)
      post.setObject(likes.to_s, forKey: "likes")
      post.save
      SVProgressHUD.showImage(UIImage.imageNamed('liked.png'), status: "Liked.")
   
  end

  def likeButton
    likeButton ||= self.view.viewWithTag(4)
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

  def timeago(time, options = {})
   start_date = options.delete(:start_date) || Time.new
   date_format = options.delete(:date_format) || :default
   delta_minutes = (start_date.to_i - time.to_i).floor / 60
   if delta_minutes.abs <= (8724*60)       
     distance = distance_of_time_in_words(delta_minutes)       
     if delta_minutes < 0
        #return "#{distance} from now"
        return "#{distance}"
     else
        #return "#{distance} ago"
        return "#{distance}"
     end
   else
      #time = Time.now
      #return "on #{DateTime.now.to_formatted_s(date_format)}"
   end
 end
 
 def distance_of_time_in_words(minutes)
   case
     when minutes < 1
       #"less than a minute"
       "1m"
     when minutes < 50
       #pluralize(minutes, "minute")
       "#{minutes}m"
     when minutes < 90
       #"about one hour"
       "~1h"
     when minutes < 1080
       #"#{(minutes / 60).round} hours"
       "#{(minutes / 60).round}h"
     when minutes < 1440
       #"one day"
       "1d"
     when minutes < 2880
       #"about one day"
       "~1d"
     else
       #"#{(minutes / 1440).round} days"
       "#{(minutes / 1440).round}d"
   end
 end

  def tableView(tableView, numberOfRowsInSection: section)
     #@data.count
     1
  end

  def numberOfSectionsInTableView(tableView)
    #@data.count
    p @posts.length
  end

  def tableView(tableView, heightForHeaderInSection:section)

    return 52.0
  end  

  def tableView(tableView, viewForHeaderInSection:section)
    
   #header.viewWithTag(1).image = @data[section] #Post Owner Img

    #header ||= NSBundle.mainBundle.loadNibNamed('Jiggy', owner:self, options:nil)[7]
    #header = PostHeader.alloc.init
    #header.viewWithTag(2).text = @data[section] #Post Owner Username
    #return header
    view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 320, 53))
    view.backgroundColor = UIColor.whiteColor
    view.alpha = 0.8

    
    
    #=> User Profile Pic
    #imageView = UIImageView.alloc.initWithFrame(CGRectMake(6, 9, 38, 38))
    #imageView.setImage(UIImage.imageNamed("post_thumb.png"))
    #imageView.contentMode = UIViewContentModeScaleAspectFill
    #imageView.setClipsToBounds(true)
    #if @profilePicture[section].nil?
    #  imageView = UIImageView.alloc.initWithFrame(CGRectMake(6, 9, 38, 38))
    #  imageView.setImage(UIImage.imageNamed("post_thumb.png"))
    #  imageView.contentMode = UIViewContentModeScaleAspectFill
    #  imageView.setClipsToBounds(true)
   # else
      profilePic = PFImageView.alloc.initWithFrame(CGRectMake(6, 9, 38, 38))
      profilePic.image = UIImage.imageNamed("post_thumb.png") # placeholder image
      profilePic.file = @profilePicture[section]
      profilePic.loadInBackground
    #end

    #Dispatch::Queue.concurrent.async do
      #Retrieve profile pic from parse
      #query = PFUser.query
      #p section
      #p @posts[section].objectForKey("user")
      #user = query.getObjectWithId(@posts[section].objectForKey("user").objectId)
      #theImage = user.objectForKey("media")
      #imageData = theImage.getData
      #image = UIImage.imageWithData(imageData)
      #p @profilePicture[section]
      #imageView.setImage(@profilePicture[section]) if !@profilePicture[section].nil?
    #end
    view.addSubview(profilePic)
    #profilePic.release
    #view.addSubview(imageView)
    #imageView.release
    #=> Username
    label = UILabel.new
    label.text = "#{@username[section]}"
    label.backgroundColor = UIColor.clearColor
    label.frame = [[56,15],[76,21]]
    label.setFont(UIFont.fontWithName("HelveticaNeue-Bold", size:10.0))
    label.setTextColor(UIColor.colorWithRed(34.0/255.0, green: 152.0/255.0, blue: 197.0/255.0, alpha:1))
    view.addSubview(label)
    label.release

    #=> Time icon
    imageView = UIImageView.alloc.initWithFrame(CGRectMake(282, 9, 9, 9))
    imageView.setImage(UIImage.imageNamed("time.png"))
    view.addSubview(imageView)
    imageView.release

    #=> Time label
    label = UILabel.new
    label.text = "#{@postTime[section]}"
    label.backgroundColor = UIColor.clearColor
    label.frame = [[293,3],[29,21]]
    label.setFont(UIFont.fontWithName("HelveticaNeue-Bold", size:10.0))
    label.setTextColor(UIColor.lightGrayColor)
    view.addSubview(label)
    label.release
    
    return view

  end
  
  def tableView(tableView, numberOfRowsInSection:section) 
    1
  end

   def tableView(tableView, heightForRowAtIndexPath:section) 
      #media =  @posts[section.section].objectForKey("media")
      #media.nil? ? 200 : 360
      360
   end

  def tableView(tableView, titleForHeaderInSection:section) 
    "Section: #{section}"
  end

  
  def tableView(tableView, titleForHeaderInSection:section) 
    "Section: #{section}"
  end
  
  def reloadTableViewDataSource
    @reloading = true
  end
  
  def doneReloadingTableViewData
    @reloading = false
    @refreshHeaderView.refreshScrollViewDataSourceDidFinishLoading(@table)
  end




  def scrollViewDidScroll(scrollView)
   @refreshHeaderView.refreshScrollViewDidScroll(scrollView) 
    if scrollView.contentOffset.y < 1
      self.navigationController.setNavigationBarHidden(false, animated: true)
    else
      self.navigationController.setNavigationBarHidden(true, animated: true)
    end
  end
  
  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end
  
  def refreshTableHeaderDidTriggerRefresh(view)
    self.reloadTableViewDataSource
    self.performSelector('doneReloadingTableViewData', withObject:nil, afterDelay:3)
    fetch_posts
    #@table.reloadData 
  end
    
  def refreshTableHeaderDataSourceIsLoading(view)
    @reloading
  end
  
  def refreshTableHeaderDataSourceLastUpdated(view)
    NSDate.date
  end

  def iPhone5
    return true if self.view.bounds.size.height == 548.0
  end

end