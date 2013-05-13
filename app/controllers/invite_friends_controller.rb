class InviteFriendsController < UIViewController

  def loadView
    #views = NSBundle.mainBundle.loadNibNamed "Navigation_2", owner:self, options:nil
    #self.view = views[0]
 
  end
  
  def viewDidLoad
    super
    #self.view.backgroundColor = UIColor.greenColor
    
    #view.image = UIImage.imageNamed('background.png')
    #self.title = 'Activity'
    #self.tabBarItem = UITabBarItem.alloc.initWithTitle("Activity", image: nil, tag: 1)
    #self.tabBarItem.setFinishedSelectedImage UIImage.imageNamed('activity.png'), withFinishedUnselectedImage: UIImage.imageNamed('activity.png')

 
    @table = UITableView.alloc.initWithFrame(CGRectMake(0, 50, 320, 410))
    @table.delegate = self
    @table.dataSource = self
   # @table.rowHeight = 360
    @table.setSeparatorStyle(UITableViewCellSeparatorStyleSingleLine)
    @table.allowsMultipleSelection = true
    @table.backgroundColor = UIColor.whiteColor
    #@data = ("A".."Z").to_a
    @data = AddressBook::Person.all
    self.view.addSubview @table
    @defaults = NSUserDefaults.standardUserDefaults
    @selected_contacts = Array.new
    

    inviteButton.addTarget(self, action: 'send_message', forControlEvents:UIControlEventTouchUpInside)
 	  cancelButton.addTarget(self, action: 'dismiss_invite_view', forControlEvents:UIControlEventTouchUpInside)


    
 
    #self.performSelector('goBack', nil, afterDelay:5.0)
  end

  def viewDidAppear(view)
  	#p AddressBook::Person.all
    @defaults["refreshView"] = true
  end



  def postTextArea
   
    @postTextArea ||= self.view.viewWithTag(3)
   
  end

  def dismiss_invite_view
    p @selected_contacts
  	self.dismissModalViewControllerAnimated(true)
  end

  def inviteButton
   
    @inviteButton ||= self.view.viewWithTag(1)
   
  end

  def send_message
    
   # Dispatch::Queue.concurrent.async do
      access_sms
      #invoke_sms
   # end
   
  end

  def invoke_sms
    MFMessageComposeViewController.alloc.init.tap do |sms|
        sms.messageComposeDelegate = self
        sms.recipients = ["2024561111", "012-4325-234"]
        sms.body = "It's bad luck to be superstitious."
        self.presentModalViewController(sms, animated:true)
      end if MFMessageComposeViewController.canSendText
      SVProgressHUD.dismiss
  end

  def messageComposeViewController(controller, didFinishWithResult:result)
    #NSLog("SMS Result: #{result}")
    #controller.dismissModalViewControllerAnimated(true)
    self.dismissModalViewControllerAnimated(true)
  end

  def access_sms

    controller = MFMessageComposeViewController.alloc.init
    if(MFMessageComposeViewController.canSendText)
      controller.body = "Invited you to Jiggy: http://jiggy.com/iphone"
      numbers = Array.new
      @selected_contacts.map { |i| numbers << @data[i].phone_numbers.mobile }  
      controller.recipients = numbers
      controller.messageComposeDelegate = self
      self.presentModalViewController(controller, animated: true)   
    else
      p "SMS not available" 
    end
    #SVProgressHUD.dismiss

  end

  def cancelButton
   
    @cancelButton ||= self.view.viewWithTag(2)
   
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "Cell"

     cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
      #NSBundle.mainBundle.loadNibNamed('CustomCell', owner:self, options:nil).first 
    end

    # put your data in the cell
    cell.textLabel.text = "#{@data[indexPath.row].first_name} #{@data[indexPath.row].last_name}"
    #cell.viewWithTag(1).text = @data[indexPath.row]
    #cell.viewWithTag(1).text = @data[indexPath.row]
    bgColorView = UIView.alloc.init
    bgColorView.setBackgroundColor(UIColor.lightGrayColor)
    cell.setSelectedBackgroundView(bgColorView)
    #bgColorView.release
    
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
      @selected_contacts << indexPath.row

  end

  def tableView(tableView, numberOfRowsInSection: section)
     @data.count
  end



end