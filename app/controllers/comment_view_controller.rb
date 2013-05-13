class CommentViewController < UIViewController

  def loadView

 
  end
  
  def viewDidLoad
    super
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
    #self.title = 'Activity'
    #self.tabBarItem = UITabBarItem.alloc.initWithTitle("Activity", image: nil, tag: 1)
    #self.tabBarItem.setFinishedSelectedImage UIImage.imageNamed('activity.png'), withFinishedUnselectedImage: UIImage.imageNamed('activity.png')

 
    iPhone5 ? @table = UITableView.alloc.initWithFrame(CGRectMake(0, 47, 320, 240)) : @table = UITableView.alloc.initWithFrame(CGRectMake(0, 47, 320, 150))
    #@table.delegate = self
    #@table.dataSource = self
   # @table.rowHeight = 360
    @table.setSeparatorStyle(UITableViewCellSeparatorStyleNone)
    @table.backgroundColor = UIColor.whiteColor
    @table.delegate = self
    @table.dataSource = self
    #@table.separatorColor = UIColor.lightGrayColor
    #@data = ("A".."Z").to_a
    self.view.addSubview @table
    @defaults = NSUserDefaults.standardUserDefaults
    #=> iPhone5 Specifics
    postTextArea.setFrame([[3,289], [243, 40]]) if iPhone5
    post.setFrame([[242,291], [68, 38]])        if iPhone5
    divider.setFrame([[9,286], [301, 3]])       if iPhone5
    #=>
    
    @comments = Array.new
    @profilePicture = Array.new
    @postTime = Array.new
    @username = Array.new


    fetch_comments(10) if !@defaults["postObjectId"].nil?

    @placeholderLabel = UILabel.alloc.initWithFrame([[10.0, 0.0], [243.0, 34.0]])
    @placeholderLabel.setText("Write a comment...")
    @placeholderLabel.setBackgroundColor(UIColor.clearColor)
    @placeholderLabel.setFont(UIFont.fontWithName("HelveticaNeue-Italic", size:13.0))
    @placeholderLabel.setTextColor(UIColor.lightGrayColor)
    postTextArea.addSubview(@placeholderLabel)
    postTextArea.delegate = self

    doneButton.addTarget(self, action: 'dismiss_comment_view', forControlEvents:UIControlEventTouchUpInside)
  	post.addTarget(self, action: 'post_comment', forControlEvents:UIControlEventTouchUpInside)


    
 
    #self.performSelector('goBack', nil, afterDelay:5.0)
  end

  def viewDidAppear(view)
  	postTextArea.becomeFirstResponder
    @defaults["refreshView"] = true
   

    @refreshHeaderView ||= begin
      rhv = LoadAllComments.alloc.initWithFrame(CGRectMake(0, 0 - @table.bounds.size.height, @table.bounds.size.width, @table.bounds.size.height))
      rhv.delegate = self
      rhv.refreshLastUpdatedDate    
      @table.addSubview(rhv)
      rhv
    end

    
    #@data = ("A".."Z").to_a

    #SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeGradient)
    #fetch_comments



  end

  


  def viewDidUnload
    @defaults["postObjectId"] = nil
  end 

  def dealloc
    @defaults["postObjectId"] = nil
  end

  def postTextArea
   
    @postTextArea ||= self.view.viewWithTag(3)
   
  end

  def fetch_comments(limit)
    query = Comment.query
    query.orderByDescending("createdAt")
    query.limit = limit
    query.whereKey("post_id", equalTo: @defaults["postObjectId"])
    p @defaults["postObjectId"]
    @comments = query.find

    if  @comments.nil?
        @comments = Array.new #=> Initialize manually for UITable
        alert = UIAlertView.alloc.initWithTitle("Error",
        message:"Sorry! An error occured while trying to fetch comments. Please try again! ",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles:nil)
    
        # Show it to the user
        alert.show
    end

    puts "You have #{@comments.length} objects of class #{@comments.first.class}."
    #Retrieve profile pic from parse
    #Dispatch::Queue.concurrent.async do
      #@profilePicture = Array.new
      query = PFUser.query
      @comments.each do |comment|
        #p post.objectForKey("user").objectId
        user = query.getObjectWithId(comment.objectForKey("user").objectId)
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
    #end
    #Retrieve post time ago
    #Dispatch::Queue.concurrent.async do
      #@postTime = Array.new
      @comments.each do |comment|
        #p post.createdAt
        @postTime << timeago(comment.createdAt)
        #p @postTime
      end
    #end

    #Retrieve username from parse
    #Dispatch::Queue.concurrent.async do
    #@username = Array.new
      query = PFUser.query
      @comments.each do |comment|
        #p post.objectForKey("user").objectId
        user = query.getObjectWithId(comment.objectForKey("user").objectId)
        @username << user.objectForKey("username")
       
      end
      SVProgressHUD.dismiss
      #theScrollView.setContentOffset(CGPointMake(200, 0), animated: true)
    #end
  end

  def post_comment
    SVProgressHUD.show
     Dispatch::Queue.concurrent.async do
      post_content(@defaults["postObjectId"], postTextArea.text)
     end
  end


  def dismiss_comment_view
  	self.dismissModalViewControllerAnimated(true)
  end

  def doneButton
   
    @doneButton ||= self.view.viewWithTag(1)
   
  end

  def post_content(objectId, content)
      posting = lambda do |succeeded, error|  
            if !error
           
               #SVProgressHUD.dismiss 
               #SVProgressHUD.showSuccessWithStatus("Posted.")
                query = PFQuery.queryWithClassName("Post")
                post = query.getObjectWithId(objectId)
                commentCount = post.objectForKey("commentCount").to_i
                commentCount +=1
                post.setObject(commentCount.to_s, forKey:"commentCount")
                post.save
                @defaults["refreshView"] = nil
               SVProgressHUD.showImage(UIImage.imageNamed('success.png'), status: "Posted.")
               postTextArea.text = nil
            else
               #SVProgressHUD.dismiss
               #SVProgressHUD.showErrorWithStatus("Please try again!")
               SVProgressHUD.showImage(UIImage.imageNamed('error.png'), status: "Please try again!")
               #alert_message("Login failed! Please try again.") 
            end #=> if
          end #=> lambda
     
     comment = Comment.new
     comment.content = "#{content}"
     comment.user = current_user
     comment.post_id = objectId
     comment.saveInBackgroundWithBlock(posting)


  end



  def post
   
    @post ||= self.view.viewWithTag(2)
   
  end

  def divider
   
    @divider ||= self.view.viewWithTag(4)
   
  end

  def current_user
    PFUser.currentUser
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CommentCellIdentifier"

     cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      #UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
         NSBundle.mainBundle.loadNibNamed('CommentCustomCell', owner:self, options:nil).first 
    end
     puts "I'm here"
     content =   @comments[indexPath.row].objectForKey("content")
     media = @profilePicture[indexPath.row]
     profilePic = PFImageView.alloc.initWithFrame(CGRectMake(6, 9, 38, 38))
     profilePic.image = UIImage.imageNamed("postloading.png") # placeholder image
     profilePic.tag = 55
     if media.nil?
      cell.viewWithTag(55).removeFromSuperview if !cell.viewWithTag(55).nil?   #PFImageView
       
     else
      profilePic.file = media
      cell.contentView.addSubview(profilePic)
      profilePic.loadInBackground
    end


    # put your data in the cell
    #cell.textLabel.text = @data[indexPath.row]
    #cell.selectionStyle = UITableViewCellSelectionStyleGray
    #cell.viewWithTag(1).text = @data[indexPath.row]
    #cell.viewWithTag(1).text = @data[indexPath.row]

    label = UILabel.new
    label.text = "#{content}"
    #label.backgroundColor = UIColor.clearColor
    label.frame = [[52,20],[250,labelHeight(indexPath.row)]]
    label.font = UIFont.fontWithName("HelveticaNeue", size:12.0)
    #p UIFont.fontNamesForFamilyName("ProximaNova-Light")
    label.setTextColor(UIColor.lightGrayColor)
    label.tag = 56
    label.adjustsFontSizeToFitWidth =  false
    label.lineBreakMode = UILineBreakModeWordWrap
    label.numberOfLines = 0
    cell.contentView.addSubview(label)


    cell.viewWithTag(2).text = @username[indexPath.row]
    #cell.viewWithTag(3).text = content
    cell.viewWithTag(4).text = @postTime[indexPath.row]

    
    cell

  end

  def tableView(tableView, numberOfRowsInSection: section)
     #@data.count
     @comments.length
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
  end
  
  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end
  
  def refreshTableHeaderDidTriggerRefresh(view)
    self.reloadTableViewDataSource
    self.performSelector('doneReloadingTableViewData', withObject:nil, afterDelay:3)
    #fetch_posts
    #@table.reloadData 
  end
    
  def refreshTableHeaderDataSourceIsLoading(view)
    @reloading
  end
  
  def refreshTableHeaderDataSourceLastUpdated(view)
    NSDate.date
  end

  def tableView(tableView, heightForRowAtIndexPath:section) 
      
    #cell = tableView.cellForRowAtIndexPath(section.row)
    cellText = @comments[section.row].objectForKey("content")
    cellFont = UIFont.fontWithName("HelveticaNeue", size:12.0)
    constraintSize = CGSizeMake(280.0, Float::MAX)
    labelSize = cellText.sizeWithFont(cellFont, constrainedToSize:constraintSize, lineBreakMode:UILineBreakModeWordWrap)

    return labelHeight(section.row) + 30

      #57
   end

   def labelHeight(row)
    cellText = @comments[row].objectForKey("content")
    cellFont = UIFont.fontWithName("HelveticaNeue", size:12.0)
    constraintSize = CGSizeMake(280.0, Float::MAX)
    labelSize = cellText.sizeWithFont(cellFont, constrainedToSize:constraintSize, lineBreakMode:UILineBreakModeWordWrap)

    return labelSize.height
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

 def iPhone5
    return true if self.view.bounds.size.height == 548.0
 end

end