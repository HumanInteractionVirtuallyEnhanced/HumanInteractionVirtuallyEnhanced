//
//  PersonTableViewController.swift
//  layout_1
//
//  Created by Rijul Gupta on 7/20/15.
//  Copyright (c) 2015 Rijul Gupta. All rights reserved.

//NEW
//Main view of the app. Shows the people around you with similar interests and mutual friends. Also switches to show comments around you.

import UIKit
import CoreLocation
import Social

class PersonTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, CLLocationManagerDelegate, FBLoginViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var fbLoginView : FBLoginView!
    @IBOutlet var tableView: UITableView!
    
    var imageCache = [String : UIImage]()
    var userImageCache = [String: UIImage]()
    var userStatusCache = [Int: String]()
    var voterCache = [Int : String]()
    var heightConstCache = [Int: Int]()
    var voterValueCache = [Int : String]()
    var mutualFriendsCache = [String: String]()
    
    var refreshControl:UIRefreshControl!
    @IBOutlet var customSC: UISegmentedControl!
    var hasLoaded = false
    var theJSON: NSDictionary!
    var savedFBID = "none"
    var numOfCells = 0
    var oldScrollPost:CGFloat = 0.0
    var typeOfCell = 1//1 = people, 2 = posts
    let fakeNames = ["Name is 1", "John SMith", "Charlse Montgoery", "Victor Knermit", "Name is 1", "John SMith", "Charlse Montgoery", "Victor Knermit", "Name is 1", "John SMith", "Charlse Montgoery", "Victor Knermit", "Name is 1", "John SMith", "Charlse Montgoery", "Victor Knermit"]
    //var radValue = 1
    var currentUserLocation = "none"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.locationManager.delegate = self
        
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        self.locationManager.requestWhenInUseAuthorization()
        //self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        
        
        customSC.addTarget(self, action: "toggleComments:", forControlEvents: .ValueChanged)
        
        let font = UIFont(name: "Lato-Light", size: 15)
        let attr = NSDictionary(objects: [font!, UIColor(red: (85.0/255.0), green: (85.0/255.0), blue: (85.0/255.0), alpha: 1.0)], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        // var attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, forKey: NSFontAttributeName)
        
       // _ = NSDictionary(objects: [font!, UIColor.blackColor()], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        
        
        //        customSC.setTitleTextAttributes(attr2 as [NSObject : AnyObject], forState: UIControlState.Normal)
        //        customSC.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: UIControlState.Highlighted)
        
        customSC.setTitleTextAttributes(attr as [NSObject : AnyObject], forState:.Normal)
        //
        let defaults = NSUserDefaults.standardUserDefaults()
        savedFBID =
            defaults.stringForKey("saved_fb_id")!
        
        dispatch_async(dispatch_get_main_queue(),{
            self.loadPeople()
        })
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "didPullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // Do any additional setup after loading the view.
        
        
        self.fbLoginView = FBLoginView()
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
//
        if (!FBSession.activeSession().isOpen) {
            // if the session is closed, then we open it here, and establish a handler for state changes
            
            FBSession.openActiveSessionWithReadPermissions(self.fbLoginView.readPermissions, allowLoginUI: true, completionHandler:  {(session: FBSession!, state: FBSessionState, error: NSError!) -> Void in
                
                if((error) != nil){
                    //self.getFBFriends(next.substringFromIndex(27))
                }
                else{
                    print("THE SESSION ERROR:\(error)")
                }
                }
            )
            
        }
        else{
        }
//
//        
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        print("User Logged In")
        print("This is where you perform a segue.")
        

    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
        print("User Name: \(user.name)")
        print("Usr Edu: \(user.birthday)")
        print(user)
        let userID = user.objectForKey("id") as! String
        print("user id: \(userID)")
        

    }
    
    func sessionStateChanged(session:FBSession, state:FBSessionState, error:NSError?) {
        
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        print("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        print("Error: \(handleError.localizedDescription)")
    }
    

    
    
    func didPullRefresh(sender:AnyObject)
    {
        //loadNewComments()
        
        //loadFakePlaces2()
        
        if(customSC.selectedSegmentIndex == 0){
            loadPeople()
        }
        else if(customSC.selectedSegmentIndex == 1){
            
            loadComments()
        }
        
        
        
        self.refreshControl.endRefreshing()
    }

    
    func toggleComments(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadPeople()
        case 1:
            loadComments()
        default:
            loadPeople()
        }
    }
    
    override func viewDidLayoutSubviews() {
        let color: UIColor = UIColor( red: CGFloat(255.0/255.0), green: CGFloat(210.0/255.0), blue: CGFloat(11.0/255.0), alpha: CGFloat(1.0) )
        self.tableView.separatorColor = color
        self.tableView.separatorInset.left = 0
        self.tableView.separatorInset.right = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //make sure the json has loaded before we do anything
        if(hasLoaded == false){
            return numOfCells
        }
        else{
            return numOfCells
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //let testImage = theJSON["results"]![indexPath.row]["image"] as! String!
        
        if(indexPath.row <= self.numOfCells){
            
            if(self.typeOfCell == 1){
                var cell = tableView.dequeueReusableCellWithIdentifier("person_cell_id") as! custom_cell_person
                
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                cell.separatorInset.left = 20
                cell.separatorInset.right = 20
                cell.layoutMargins = UIEdgeInsetsZero
                cell.tag = 300
                
                
                
                //set the cell contents with the ajax data
                
                if let name = theJSON["results"]![indexPath.row]["userName"] as! String! {
                    cell.name_label?.text = name
                }
                if let uid = theJSON["results"]![indexPath.row]["userID"] as! String!{
                    cell.user_id = uid
                    
                    if let friends = self.mutualFriendsCache[uid]! as String!{
                        cell.friends_label?.text = "MUTUAL FRIENDS: \(friends)"
                    }
                    
                }
                if let hashtags = theJSON["results"]![indexPath.row]["hashtags"] as! [(NSString)]! {
                    cell.hashtags = hashtags
                }
//                cell.name_label?.text = theJSON["results"]![indexPath.row]["userName"] as! String!
//                cell.comment_id = "22"//theJSON["results"]![indexPath.row]["c_id"] as! String!
//                let uid = theJSON["results"]![indexPath.row]["userID"] as! String!
//                cell.user_id = uid//theJSON["results"]![indexPath.row]["userID"] as! String!
//                cell.friends_label?.text = "MUTUAL FRIENDS: " + self.mutualFriendsCache[uid]! as String//(theJSON["results"]![indexPath.row]["friends"] as! String!)
//                cell.hashtags = theJSON["results"]![indexPath.row]["hashtags"] as! [(NSString)]
                var yPos = 0.0
                
                var status = "connect"
                if(userStatusCache[indexPath.row] == nil){
                    userStatusCache[indexPath.row] = theJSON["results"]![indexPath.row]["userStatus"] as! String!
                }
                else{
                    
                }
                status = userStatusCache[indexPath.row]!
                cell.interactionButton?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                //let status = theJSON["results"]![indexPath.row]["userStatus"] as! String!
                
                let userFBID = theJSON["results"]![indexPath.row]["userID"] as! String!
                
                if(status == "requester"){
                    cell.relationshipLabel?.text = "pending"
                    let lGif = NSBundle.mainBundle().URLForResource("loading_spinner", withExtension: "gif")
                    let imageDatagif = NSData(contentsOfURL: lGif!)
                    let image = UIImage.animatedImageWithData(imageDatagif!)
                    //cell.interactionButton?.imageView?.image = UIImage(data: imageDatagif!);
                    cell.interactionButton?.setImage(image, forState: UIControlState.Normal)
                    //cell.interactionButton?.addTarget(self, action:"sendRequest:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                else if(status == "requested"){
                    let image = UIImage(named: "chat_button.png")
                    cell.interactionButton?.setImage(image, forState: UIControlState.Normal)
                    cell.relationshipLabel?.text = "confirm"
                    cell.interactionButton?.addTarget(self, action:"confirmRequest:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                else if(status == "friend"){
                    let image = UIImage(named: "chat_button.png")
                    cell.interactionButton?.setImage(image, forState: UIControlState.Normal)
                    cell.relationshipLabel?.text = "message"
                    cell.interactionButton?.addTarget(self, action:"message:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                else if(status == "connect"){
                    let image = UIImage(named: "add_friend.png")
                    cell.interactionButton?.setImage(image, forState: UIControlState.Normal)
                    cell.relationshipLabel?.text = "connect"
                    cell.interactionButton?.addTarget(self, action:"sendRequest:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                
                cell.interactionButton?.tag = indexPath.row
                // cell.userImage.frame = CGRectMake(20, 20, 20, 20)
                let testUserImg = "http://graph.facebook.com/\(userFBID)/picture?width=100&height=100"
                //
                //            let url = NSURL(string: testUserImg)
                //            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                //            cell.userImage.image = UIImage(data: data!)
                
                var upimage = self.userImageCache[testUserImg]
                if( upimage == nil ) {
                    // If the image does not exist, we need to download it
                    
                    let imgURL: NSURL = NSURL(string: testUserImg)!
                    
                    // Download an NSData representation of the image at the URL
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                        if error == nil {
                            upimage = UIImage(data: data!)
                            
                            // Store the image in to our cache
                            self.userImageCache[testUserImg] = upimage
                            dispatch_async(dispatch_get_main_queue(), {
                                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell_person {
                                    cellToUpdate.userImage?.image = upimage
                                }
                            })
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell_person {
                            cellToUpdate.userImage?.image = upimage
                        }
                    })
                }
                
                
                
                let authorTap = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
                // 4
                authorTap.delegate = self
                cell.userImage?.tag = indexPath.row
                cell.userImage?.userInteractionEnabled = true
                cell.userImage?.addGestureRecognizer(authorTap)
                
                
                
                let authorTap2 = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
                // 4
                authorTap2.delegate = self
                cell.name_label?.tag = indexPath.row
                cell.name_label?.userInteractionEnabled = true
                cell.name_label?.addGestureRecognizer(authorTap2)
                
                var mH = 0.0
                
                
                for view in cell.hashtagHolder.subviews{
                    view.removeFromSuperview()
                }
                cell.hashtagButtons.removeAll()
                cell.widthFiller = 0
                let maxHashtagWidth = self.view.frame.width/1.6
                
                for i in 0...(cell.hashtags.count - 1){
                    
                    var title = cell.hashtags[i]
                    let font = UIFont(name: "Lato-Regular", size: 12);
                    //let width = Int(title.length)*12
                    let width = Int(title.sizeWithAttributes([NSFontAttributeName: font!]).width) + 5
                    let height = Int(title.sizeWithAttributes([NSFontAttributeName: font!]).height) + 2
                    
                    if(height > Int(mH)){
                        mH = Double(height)
                    }
                    
                    var xpos = 0.0
                    let widthSpacing = 5.0
                    if(cell.hashtagButtons.count > 0){
                        let holder = cell.hashtagButtons.last! as UIButton!
                        xpos = Double(holder.frame.origin.x) + Double(holder.frame.width) + widthSpacing;
                    }
                    
                    cell.widthFiller += width + Int(widthSpacing)
                    
                    if(Double(cell.widthFiller) > Double(maxHashtagWidth)){
                        print("THE CELL IS:\(indexPath.row)")
                        cell.widthFiller = width + Int(widthSpacing)
                        let addPos = (Double(height)*0.9)
                        yPos += addPos
                        xpos = 0.0
                    }
                 //   if(cell.hasLoadedInfo == false){
                        let newButton = UIButton(frame: CGRect(x: Int(xpos), y: Int(yPos), width: width, height: Int(height)))
                        //newButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                        newButton.backgroundColor = UIColor.clearColor()
                        
                        newButton.setTitle(title as String, forState: UIControlState.Normal)
                        
                        // newButton.titleLabel?.text = title as String
                        newButton.titleLabel?.font = font
                        //newButton.titleLabel?.backgroundColor = UIColor.whiteColor()
                        
                        //newButton.titleLabel?.textColor = UIColor.blackColor()
                        newButton.titleLabel?.textAlignment = NSTextAlignment.Left
                        newButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), forState: UIControlState.Normal)
                        newButton.sizeToFit()
                        newButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
                        cell.hashtagHolder.addSubview(newButton)
                        cell.hashtagButtons.append(newButton)
                        
                        
                 //   }
//                    else{
//                        cell.hashtagButtons[i]?.setTitle(title as String, forState: UIControlState.Normal)
//                        
//                        // cell.hashtagButtons[i]?.frame = CGRect(x: Int(xpos), y: Int(yPos), width: width, height: Int(height))
//                        cell.hashtagButtons[i]?.sizeToFit()
//                    }
//                    
                    
                }
                
                
                let hConst = CGFloat(yPos + mH)
                let heightConstraint = NSLayoutConstraint(item: cell.hashtagHolder, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: hConst)
                cell.hashtagHolder.addConstraint(heightConstraint)
                
                
                cell.userImage.backgroundColor = UIColor.whiteColor()
               // cell.hasLoadedInfo = true
                //cell.hasLoadedInfo = false
                
                return cell
            }
            else{
                let testImage = theJSON["results"]![indexPath.row]["image"] as! String!
                
                if(testImage == "none"){
                    let cell = tableView.dequeueReusableCellWithIdentifier("custom_cell_no_images") as! custom_cell_no_images
                    
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    cell.separatorInset.left = 0
                    cell.separatorInset.right = 0
                    cell.layoutMargins = UIEdgeInsetsZero
                    cell.preservesSuperviewLayoutMargins = false
                    cell.imageLink = testImage
                    cell.tag = 100
                    
                    
                    
                    
                    
                    //set the cell contents with the ajax data
                    if let text = theJSON["results"]![indexPath.row]["comments"] as! String!{
                        cell.comment_label?.text = text
                    }
                    if let cid = theJSON["results"]![indexPath.row]["c_id"] as! String! {
                        cell.comment_id = cid
                    }
                    if let authorName = theJSON["results"]![indexPath.row]["author"] as! String! {
                        cell.author_label?.text = authorName
                    }
                    if let h = voterValueCache[indexPath.row] as String! {
                        cell.heart_label?.text = h
                    }
                    if let t = theJSON["results"]![indexPath.row]["time"] as! String! {
                        cell.time_label?.text = t
                    }
                    if let rN = theJSON["results"]![indexPath.row]["numComments"] as! String! {
                        cell.replyNumLabel?.text = rN
                    }
                    if let hashtags = theJSON["results"]![indexPath.row]["hashtagTitles"] as! [(NSString)]! {
                        cell.hashtags = hashtags
                    }
//                    cell.comment_label?.text = theJSON["results"]![indexPath.row]["comments"] as! String!
//                    cell.comment_label.sizeToFit()
//                    cell.comment_id = theJSON["results"]![indexPath.row]["c_id"] as! String!
//                    cell.author_label?.text = theJSON["results"]![indexPath.row]["author"] as! String!
//                    //  cell.loc_label?.text = theJSON["results"]![indexPath.row]["location"] as! String!
//                    cell.heart_label?.text = voterValueCache[indexPath.row] as String!
//                    //cell.heart_label?.text = "12"
//                    cell.time_label?.text = theJSON["results"]![indexPath.row]["time"] as! String!
//                    cell.replyNumLabel?.text = theJSON["results"]![indexPath.row]["numComments"] as! String!
//                    
//                    cell.hashtags = theJSON["results"]![indexPath.row]["hashtagTitles"] as! [(NSString)]
                    var yPos = 0.0
                    
                    
                    var mH = 0.0
                    
                    for i in 0...(cell.hashtags.count - 1){
                        
                        var title = cell.hashtags[i]
                        let font = UIFont(name: "Lato-Regular", size: 12);
                        //let width = Int(title.length)*12
                        let width = Int(title.sizeWithAttributes([NSFontAttributeName: font!]).width) + 5
                        let height = Int(title.sizeWithAttributes([NSFontAttributeName: font!]).height) + 2
                        
                        if(height > Int(mH)){
                            mH = Double(height)
                        }
                        
                        var xpos = 0.0
                        var widthSpacing = 5.0
                        if(cell.hashtagButtons.count > 0){
                            let holder = cell.hashtagButtons.last! as UIButton!
                            xpos = Double(holder.frame.origin.x) + Double(holder.frame.width) + widthSpacing;
                        }
                        
                        cell.widthFiller += width + Int(widthSpacing)
                        
                        if(Double(cell.widthFiller) > Double(cell.contentView.frame.width/2.60)){
                            cell.widthFiller = width + Int(widthSpacing)
                            let addPos = (Double(height)*0.9)
                            yPos += addPos
                            xpos = 0.0
                        }
                        if(cell.hasLoadedInfo == false){
                            var newButton = UIButton(frame: CGRect(x: Int(xpos), y: Int(yPos), width: width, height: Int(height)))
                            //newButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                            newButton.backgroundColor = UIColor.clearColor()
                            
                            newButton.setTitle(title as String, forState: UIControlState.Normal)
                            
                            // newButton.titleLabel?.text = title as String
                            newButton.titleLabel?.font = font
                            //newButton.titleLabel?.backgroundColor = UIColor.whiteColor()
                            
                            //newButton.titleLabel?.textColor = UIColor.blackColor()
                            newButton.titleLabel?.textAlignment = NSTextAlignment.Left
                            newButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), forState: UIControlState.Normal)
                            newButton.sizeToFit()
                            newButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
                            cell.hashtagHolder.addSubview(newButton)
                            cell.hashtagButtons.append(newButton)
                            
                            
                            
                        }
                        else{
                            if(i < cell.hashtagButtons.count){
                                cell.hashtagButtons[i]?.setTitle(title as String, forState: UIControlState.Normal)
                                cell.hashtagButtons[i]?.sizeToFit()
                                //cell.hashtagButtons[i]?.frame = CGRect(x: Int(xpos), y: Int(yPos), width: width, height: Int(height))
                            }
                        }
                        
                        
                    }
                    
                    //
                    if(cell.hasLoadedInfo == false){
                        let hConst = CGFloat(yPos + mH)
                        let heightConstraint = NSLayoutConstraint(item: cell.hashtagHolder, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: hConst)
                        cell.hashtagHolder.addConstraint(heightConstraint)
                        
                    }
                    
                    
                    
                    
                    
                    let myMutableString = NSMutableAttributedString(string: "Herro", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!])
                    
                    let myMutableString2 = NSMutableAttributedString(string: "World", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 8.0)!])
                    
                    myMutableString.appendAttributedString(myMutableString2)
                    
                    
                    //     cell.comment_label?.attributedText = myMutableString
                    
                    //var doit: NSAttributedString! = self.parseHTMLString(cell.comment_label?.text!)
                    
                    let asdfasd = cell.comment_label?.text!
                    
                    var gotURL = self.parseHTMLString(asdfasd!)
                    
                    print("OH YEAH:\(gotURL)")
                    
                    if(gotURL.count == 0){
                        print("NO SHOW")
                        cell.urlLink = "none"
                    }
                    else{
                        print("LAST TIME BuDDY:\(gotURL.last)")
                        cell.urlLink = gotURL.last! as String
                    }
                    
                    
                    let userFBID = theJSON["results"]![indexPath.row]["user_id"] as! String!
                    cell.user_id = userFBID
                    let testUserImg = "http://graph.facebook.com/\(userFBID)/picture?type=small"
                    //     let imageLink = "http://graph.facebook.com/\(userFBID)/picture?type=small"
                    //    let url = NSURL(string: imageLink)
                    //   let data2 = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                    //            comImage.image = UIImage(data: data!)
                    
                    // cell.userImage.image = UIImage(data:data2!)
                    
                    
                    
                    //GET TEH USER IMAGE
                    var upimage = self.userImageCache[testUserImg]
                    if( upimage == nil ) {
                        // If the image does not exist, we need to download it
                        
                        var imgURL: NSURL = NSURL(string: testUserImg)!
                        
                        // Download an NSData representation of the image at the URL
                        let request: NSURLRequest = NSURLRequest(URL: imgURL)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if error == nil {
                                upimage = UIImage(data: data!)
                                
                                // Store the image in to our cache
                                self.userImageCache[testUserImg] = upimage
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell_no_images {
                                        cellToUpdate.userImage?.image = upimage
                                    }
                                })
                            }
                            else {
                                print("Error: \(error!.localizedDescription)")
                            }
                        })
                        
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell_no_images {
                                cellToUpdate.userImage?.image = upimage
                            }
                        })
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    let authorTap = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
                    // 4
                    authorTap.delegate = self
                    cell.author_label?.tag = indexPath.row
                    cell.author_label?.userInteractionEnabled = true
                    cell.author_label?.addGestureRecognizer(authorTap)
                    
                    
                    
                    let authorTap2 = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
                    // 4
                    authorTap2.delegate = self
                    cell.userImage?.tag = indexPath.row
                    cell.userImage?.userInteractionEnabled = true
                    cell.userImage?.addGestureRecognizer(authorTap2)
                    
                    
                    
                    let likersTap = UITapGestureRecognizer(target: self, action:Selector("showLikers:"))
                    likersTap.delegate = self
                    //            cell.likerButtonLabel?.tag = indexPath.row
                    //            cell.likerButtonLabel?.userInteractionEnabled = true
                    //            cell.likerButtonLabel?.addGestureRecognizer(likersTap)
                    cell.heart_label?.tag = indexPath.row
                    cell.heart_label?.userInteractionEnabled = true
                    cell.heart_label?.addGestureRecognizer(likersTap)
                    
                    
                    
                    //                let repliesTap2 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
                    //                repliesTap2.delegate = self
                    //                cell.replyButtonLabel?.tag = indexPath.row
                    //                cell.replyButtonLabel?.userInteractionEnabled = true
                    //                cell.replyButtonLabel?.addGestureRecognizer(repliesTap2)
                    //
                    //                let repliesTap3 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
                    //                repliesTap3.delegate = self
                    //                cell.replyNumLabel?.tag = indexPath.row
                    //                cell.replyNumLabel?.userInteractionEnabled = true
                    //                cell.replyNumLabel?.addGestureRecognizer(repliesTap3)
                    
                    
                    
                    
                    
                    //
                    
                    
                    
                    let shareTap2 = UITapGestureRecognizer(target: self, action:Selector("shareComment:"))
                    shareTap2.delegate = self
                    cell.shareButton?.tag = indexPath.row
                    cell.shareButton?.userInteractionEnabled = true
                    cell.shareButton?.addGestureRecognizer(shareTap2)
                    // cell.bringSubviewToFront(cell.shareButton)
                    //
                    
                    //find out if the user has liked the comment or not
                    var hasLiked = voterCache[indexPath.row] as String!
                    
                    if(hasLiked == "yes"){
                        cell.heart_icon?.userInteractionEnabled = true
                        cell.heart_icon?.image = UIImage(named: "button_heart.png")
                        
                        let voteDown = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
                        // 4
                        voteDown.delegate = self
                        cell.heart_icon?.tag = indexPath.row
                        cell.heart_icon?.addGestureRecognizer(voteDown)
                        
                        
                    }
                    else if(hasLiked == "no"){
                        cell.heart_icon?.userInteractionEnabled = true
                        cell.heart_icon?.image = UIImage(named: "button_heart_empty.png")
                        
                        let voteUp = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
                        // 4
                        voteUp.delegate = self
                        cell.heart_icon?.tag = indexPath.row
                        cell.heart_icon?.addGestureRecognizer(voteUp)
                    }
                    
                    
                    
                    
                    
                    cell.hasLoadedInfo = true
                    return cell
                    
                    
                }
                else{
                    //image
                    var cell = tableView.dequeueReusableCellWithIdentifier("custom_cell") as! custom_cell
                    
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.separatorInset.left = 0
                    cell.separatorInset.right = 0
                    cell.layoutMargins = UIEdgeInsetsZero
                    cell.preservesSuperviewLayoutMargins = false
                    cell.imageLink = testImage
                    cell.tag = 200
                    
                    
                    
                    //set the cell contents with the ajax data
                    cell.comment_label?.text = theJSON["results"]![indexPath.row]["comments"] as! String!
                    cell.comment_label.sizeToFit()
                    cell.comment_id = theJSON["results"]![indexPath.row]["c_id"] as! String!
                    cell.author_label?.text = theJSON["results"]![indexPath.row]["author"] as! String!
                    cell.loc_label?.text = theJSON["results"]![indexPath.row]["location"] as! String!
                    cell.heart_label?.text = voterValueCache[indexPath.row] as String!
                    //cell.heart_label?.text = "12"
                    cell.time_label?.text = theJSON["results"]![indexPath.row]["time"] as! String!
                    cell.replyNumLabel?.text = theJSON["results"]![indexPath.row]["numComments"] as! String!
                    
                    cell.hashtags = theJSON["results"]![indexPath.row]["hashtagTitles"] as! [(NSString)]
                    var yPos = 0.0
                    
                    
                    var mH = 0.0
                    
                    for i in 0...(cell.hashtags.count - 1){
                        
                        var title = cell.hashtags[i]
                        let font = UIFont(name: "Lato-Regular", size: 12);
                        //let width = Int(title.length)*12
                        let width = Int(title.sizeWithAttributes([NSFontAttributeName: font!]).width) + 5
                        let height = Int(title.sizeWithAttributes([NSFontAttributeName: font!]).height) + 2
                        
                        if(height > Int(mH)){
                            mH = Double(height)
                        }
                        
                        var xpos = 0.0
                        var widthSpacing = 5.0
                        if(cell.hashtagButtons.count > 0){
                            let holder = cell.hashtagButtons.last! as UIButton!
                            xpos = Double(holder.frame.origin.x) + Double(holder.frame.width) + widthSpacing;
                        }
                        
                        cell.widthFiller += width + Int(widthSpacing)
                        
                        if(Double(cell.widthFiller) > Double(cell.contentView.frame.width/2.60)){
                            cell.widthFiller = width + Int(widthSpacing)
                            let addPos = (Double(height)*0.9)
                            yPos += addPos
                            xpos = 0.0
                        }
                        if(cell.hasLoadedInfo == false){
                            var newButton = UIButton(frame: CGRect(x: Int(xpos), y: Int(yPos), width: width, height: Int(height)))
                            //newButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                            newButton.backgroundColor = UIColor.clearColor()
                            
                            newButton.setTitle(title as String, forState: UIControlState.Normal)
                            
                            // newButton.titleLabel?.text = title as String
                            newButton.titleLabel?.font = font
                            //newButton.titleLabel?.backgroundColor = UIColor.whiteColor()
                            
                            //newButton.titleLabel?.textColor = UIColor.blackColor()
                            newButton.titleLabel?.textAlignment = NSTextAlignment.Left
                            newButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), forState: UIControlState.Normal)
                            newButton.sizeToFit()
                            newButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
                            cell.hashtagHolder.addSubview(newButton)
                            cell.hashtagButtons.append(newButton)
                            
                            
                            
                        }
                        else{
                            cell.hashtagButtons[i]?.setTitle(title as String, forState: UIControlState.Normal)
                            cell.hashtagButtons[i]?.sizeToFit()
                            //cell.hashtagButtons[i]?.frame = CGRect(x: Int(xpos), y: Int(yPos), width: width, height: Int(height))
                        }
                        
                        
                    }
                    
                    //
                    if(cell.hasLoadedInfo == false){
                        let hConst = CGFloat(yPos + mH)
                        let heightConstraint = NSLayoutConstraint(item: cell.hashtagHolder, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: hConst)
                        cell.hashtagHolder.addConstraint(heightConstraint)
                        
                    }
                    
                    
                    
                    
                    let myMutableString = NSMutableAttributedString(string: "Herro", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!])
                    
                    let myMutableString2 = NSMutableAttributedString(string: "World", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 8.0)!])
                    
                    myMutableString.appendAttributedString(myMutableString2)
                    
                    
                    //     cell.comment_label?.attributedText = myMutableString
                    
                    //var doit: NSAttributedString! = self.parseHTMLString(cell.comment_label?.text!)
                    
                    let asdfasd = cell.comment_label?.text!
                    
                    var gotURL = self.parseHTMLString(asdfasd!)
                    
                    print("OH YEAH:\(gotURL)")
                    
                    if(gotURL.count == 0){
                        print("NO SHOW")
                        cell.urlLink = "none"
                    }
                    else{
                        print("LAST TIME BuDDY:\(gotURL.last)")
                        cell.urlLink = gotURL.last! as String
                    }
                    
                    
                    let userFBID = theJSON["results"]![indexPath.row]["user_id"] as! String!
                    cell.user_id = userFBID
                    let testUserImg = "http://graph.facebook.com/\(userFBID)/picture?type=small"
                    //     let imageLink = "http://graph.facebook.com/\(userFBID)/picture?type=small"
                    //    let url = NSURL(string: imageLink)
                    //   let data2 = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                    //            comImage.image = UIImage(data: data!)
                    
                    // cell.userImage.image = UIImage(data:data2!)
                    
                    
                    
                    //GET TEH USER IMAGE
                    var upimage = self.userImageCache[testUserImg]
                    if( upimage == nil ) {
                        // If the image does not exist, we need to download it
                        
                        var imgURL: NSURL = NSURL(string: testUserImg)!
                        
                        // Download an NSData representation of the image at the URL
                        let request: NSURLRequest = NSURLRequest(URL: imgURL)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if error == nil {
                                upimage = UIImage(data: data!)
                                
                                // Store the image in to our cache
                                self.userImageCache[testUserImg] = upimage
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell {
                                        cellToUpdate.userImage?.image = upimage
                                    }
                                })
                            }
                            else {
                                print("Error: \(error!.localizedDescription)")
                            }
                        })
                        
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell {
                                cellToUpdate.userImage?.image = upimage
                            }
                        })
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    let authorTap = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
                    // 4
                    authorTap.delegate = self
                    cell.author_label?.tag = indexPath.row
                    cell.author_label?.userInteractionEnabled = true
                    cell.author_label?.addGestureRecognizer(authorTap)
                    
                    
                    
                    let authorTap2 = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
                    // 4
                    authorTap2.delegate = self
                    cell.userImage?.tag = indexPath.row
                    cell.userImage?.userInteractionEnabled = true
                    cell.userImage?.addGestureRecognizer(authorTap2)
                    
                    
                    
                    let likersTap = UITapGestureRecognizer(target: self, action:Selector("showLikers:"))
                    likersTap.delegate = self
                    //            cell.likerButtonLabel?.tag = indexPath.row
                    //            cell.likerButtonLabel?.userInteractionEnabled = true
                    //            cell.likerButtonLabel?.addGestureRecognizer(likersTap)
                    cell.heart_label?.tag = indexPath.row
                    cell.heart_label?.userInteractionEnabled = true
                    cell.heart_label?.addGestureRecognizer(likersTap)
                    
                    
                    
                    //                let repliesTap = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
                    //                repliesTap.delegate = self
                    //                cell.replyButtonImage?.tag = indexPath.row
                    //                cell.replyButtonImage?.userInteractionEnabled = true
                    //                cell.replyButtonImage?.addGestureRecognizer(repliesTap)
                    //
                    //                let repliesTap2 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
                    //                repliesTap2.delegate = self
                    //                cell.replyButtonLabel?.tag = indexPath.row
                    //                cell.replyButtonLabel?.userInteractionEnabled = true
                    //                cell.replyButtonLabel?.addGestureRecognizer(repliesTap2)
                    //
                    //                let repliesTap3 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
                    //                repliesTap3.delegate = self
                    //                cell.replyNumLabel?.tag = indexPath.row
                    //                cell.replyNumLabel?.userInteractionEnabled = true
                    //                cell.replyNumLabel?.addGestureRecognizer(repliesTap3)
                    
                    
                    
                    
                    
                    //
                    
                    //
                    //
                    let shareTap = UITapGestureRecognizer(target: self, action:Selector("shareComment:"))
                    shareTap.delegate = self
                    cell.shareLabel?.tag = indexPath.row
                    cell.shareLabel?.userInteractionEnabled = true
                    cell.shareLabel?.addGestureRecognizer(shareTap)
                    // cell.bringSubviewToFront(cell.shareLabel)
                    // cell.contentView.bringSubviewToFront(cell.shareLabel)
                    
                    let shareTap2 = UITapGestureRecognizer(target: self, action:Selector("shareComment:"))
                    shareTap2.delegate = self
                    cell.shareButton?.tag = indexPath.row
                    cell.shareButton?.userInteractionEnabled = true
                    cell.shareButton?.addGestureRecognizer(shareTap2)
                    // cell.bringSubviewToFront(cell.shareButton)
                    //
                    
                    //find out if the user has liked the comment or not
                    var hasLiked = voterCache[indexPath.row] as String!
                    
                    if(hasLiked == "yes"){
                        cell.heart_icon?.userInteractionEnabled = true
                        cell.heart_icon?.image = UIImage(named: "button_heart.png")
                        
                        let voteDown = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
                        // 4
                        voteDown.delegate = self
                        cell.heart_icon?.tag = indexPath.row
                        cell.heart_icon?.addGestureRecognizer(voteDown)
                        
                        
                    }
                    else if(hasLiked == "no"){
                        cell.heart_icon?.userInteractionEnabled = true
                        cell.heart_icon?.image = UIImage(named: "button_heart_empty.png")
                        
                        let voteUp = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
                        // 4
                        voteUp.delegate = self
                        cell.heart_icon?.tag = indexPath.row
                        cell.heart_icon?.addGestureRecognizer(voteUp)
                    }
                    
                    
                    let voteUp2 = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
                    cell.likerButtonHolder?.userInteractionEnabled = true
                    voteUp2.delegate = self
                    cell.likerButtonHolder?.tag = indexPath.row
                    cell.likerButtonHolder?.addGestureRecognizer(voteUp2)
                    
                    
                    let focusImage = UITapGestureRecognizer(target: self, action:Selector("showImageFullscreen:"))
                    focusImage.delegate = self
                    cell.comImage.userInteractionEnabled = true
                    cell.comImage?.tag = indexPath.row
                    cell.comImage?.addGestureRecognizer(focusImage)
                    
                    //give a loading gif to UI
                    var urlgif = NSBundle.mainBundle().URLForResource("loader2", withExtension: "gif")
                    var imageDatagif = NSData(contentsOfURL: urlgif!)
                    
                    
                    let imagegif = UIImage.animatedImageWithData(imageDatagif!)
                    
                    cell.comImage.image = imagegif
                    
                    
                    
                    //GET TEH COMMENT IMAGE
                    var image = self.imageCache[testImage]
                    if( image == nil ) {
                        // If the image does not exist, we need to download it
                        var imgURL: NSURL = NSURL(string: testImage)!
                        
                        // Download an NSData representation of the image at the URL
                        let request: NSURLRequest = NSURLRequest(URL: imgURL)
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                            if error == nil {
                                image = UIImage(data: data!)
                                
                                // Store the image in to our cache
                                self.imageCache[testImage] = image
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell {
                                        cellToUpdate.comImage.image = image
                                    }
                                })
                            }
                            else {
                                print("Error: \(error!.localizedDescription)")
                            }
                        })
                        
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell {
                                cellToUpdate.comImage?.image = image
                            }
                        })
                    }
                    
                    
                    
                    
                    cell.hasLoadedInfo = true
                    return cell
                }
                
            }
        }
        else{
            var cell = UITableViewCell()
            return cell
        }
        
        
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let comView = mainStoryboard.instantiateViewControllerWithIdentifier("com_focus_scene_id") as! ThirdViewController
        //
        
        print("DID RECIEVE CLICK")
        // let indCell = collectionView.cellForItemAtIndexPath(indexPath) as! profile_post_cellCollectionViewCell
        
        let indCell = tableView.cellForRowAtIndexPath(indexPath)
        
        if(indCell?.tag == 100){
            let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! custom_cell_no_images
            
            //comView.sentLocation = currentUserLocation
            comView.commentID = gotCell.comment_id
            self.presentViewController(comView, animated: true, completion: nil)
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! custom_cell
            
            //comView.sentLocation = currentUserLocation
            comView.commentID = gotCell.comment_id
            self.presentViewController(comView, animated: true, completion: nil)
        }
        
        
        
        
        
        
        //
        //        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //        let comView = mainStoryboard.instantiateViewControllerWithIdentifier("com_focus_scene_id") as! ThirdViewController
        //        //
        //
        //
        //        let indCell = tableView.cellForRowAtIndexPath(indexPath)
        //
        //        let mainView = mainStoryboard.instantiateViewControllerWithIdentifier("main_view_scene_id") as! ViewController
        //
        //        if(indCell?.tag == 100){
        //            let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! custom_cell_no_images
        //
        //            comView.sentLocation = mainView.currentUserLocation
        //            comView.commentID = gotCell.comment_id
        //
        //        }
        //        if(indCell?.tag == 200){
        //            let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! custom_cell
        //
        //            comView.sentLocation = mainView.currentUserLocation
        //            comView.commentID = gotCell.comment_id
        //
        //        }
        //
        //
        //
        //        self.presentViewController(comView, animated: true, completion: nil)
    }
    
    
    
    func loadPeople(){
        
        dispatch_async(dispatch_get_main_queue(),{
            print("DID START GETTING PEOPLE")
            self.showLoadingScreen()
            let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_people")
            //START AJAX
            var request = NSMutableURLRequest(URL: url!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            print("BLACH BLACH")
            print(self.currentUserLocation)
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let fbid = defaults.stringForKey("saved_fb_id") as String!
            
            var params = ["gfbid":fbid, "recentLoc":self.currentUserLocation] as Dictionary<String, String>
            
            var err: NSError?
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch var error as NSError {
                err = error
                request.HTTPBody = nil
            } catch {
                fatalError()
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                var err: NSError?
                
                var json: NSDictionary?
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                } catch let error as NSError{
                    err = error
                } catch {
                    
                }
                
                
                self.removeLoadingScreen()
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    
                    
                    
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        
                        self.tableView.backgroundColor = UIColor.whiteColor()
                        self.theJSON = json
                        self.hasLoaded = true
                        self.numOfCells = parseJSON["results"]!.count
                        
                        self.typeOfCell = 1
                        self.reload_table()
                        
                        for index in 0...(parseJSON["results"]!.count - 1){
                            let foo = parseJSON["results"]![index]["userID"] as! String
                            self.mutualFriendsCache[foo] = (parseJSON["results"]![index]["friends"] as! String!)
//                            if(index == 2){
//                                self.getMutualFriends(foo)
//                            }
                        }
//                        for index in 0...(self.theJSON["results"]!.count - 1){
//                            let foo = self.theJSON["results"]![index]["userID"] as! String
//                            self.getMutualFriends(foo, num:index)
//                        }
                        
                        
                    
                       
                        
                        //                    let let doesNNH = parseJSON["results"]!["doesNeedNewHashtags"] as! Int
                        //
                        //                    if(doesNNH == 1){
                        //
                        //                        print("OIFJOIFJOIJF")
                        //                    }
                        
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        
                    }
                }
            })
            task.resume()
            //END AJAX
            
        })
        
    }
    
    
    func loadComments(){
        
        print("DID START GETTING COMMENTS")
        self.showLoadingScreen()
        // let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_following_comments")
        
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_user_get_comments")
        //START AJAX
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
        
        var params = ["gfbid":fbid, "recentLocation":currentUserLocation] as Dictionary<String, String>
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch var error as NSError {
            err = error
            request.HTTPBody = nil
        } catch {
            
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var err: NSError?
            
            var json: NSDictionary?
            do{
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let error as NSError{
                err = error
            } catch {
                
            }
            
            
            self.removeLoadingScreen()
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                print(err!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                
                
                
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    
                    //self.view.backgroundColor = UIColor.redColor()
                    let color: UIColor = UIColor( red: CGFloat(255.0/255.0), green: CGFloat(210.0/255.0), blue: CGFloat(11.0/255.0), alpha: CGFloat(1.0) )
                    self.tableView.backgroundColor = color
                    self.theJSON = json
                    self.writeVoterCache()
                    self.hasLoaded = true
                    self.typeOfCell = 2
                    self.numOfCells = parseJSON["results"]!.count
                    
                    self.reload_table()
                    
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                }
            }
        })
        task.resume()
        //END AJAX
        
        
        
        
    }
    
    func showImageFullscreen(sender: UIGestureRecognizer){
        print("Presenting Likers, ya heard.")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        let imView = mainStoryboard.instantiateViewControllerWithIdentifier("Image_focus_controller") as! ImageFocusController
        
        var daLink = "none"
        
        var authorLabel:AnyObject
        
        authorLabel = sender.view!
        
        
        let indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
        
        if(indCell?.tag == 100){
            _ = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell_no_images
            
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell
            
            daLink = gotCell.imageLink
        }
        
        imView.imageLink = daLink
        
        self.presentViewController(imView, animated: true, completion: nil)
        
    }
    
    
    
    
    func parseHTMLString(daString:NSString) -> [NSString]{
        
        
        print("DA STRING:\(daString)")
        let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue)
        
        let fakejf = String(daString)
        //let length = fakejf.utf16Count
        let length = fakejf.utf16.count
        let daString2 = daString as String
        // let links = detector?.matchesInString(daString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length)).map {$0 as NSTextCheckingResult}
        
        let links = detector?.matchesInString(daString2, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length)).map {$0 }
        
        //        var d = daString as StringE
        //        if (d.containsString("Http://") == true){
        //            println(daString)
        //            println("YEAH BUDDY")
        //        }
        
        var retString = NSString(string: "none")
        //
        
        return links!.filter { link in
            return link.URL != nil
            }.map { link -> NSString in
                //let urString = String(contentsOfURL: link.URL!)
                let urString = link.URL!.absoluteString
                print("DA STRING:\(urString)")
                retString = urString
                return urString
        }
        
        // var newString = retString
        //
        return [retString]
        //return "OH YEAH"
    }
    
    
    
    
    //
    //     func writeVoterCache(){
    //
    //        let finNum = (theJSON["results"]!.count - 1)
    //
    //        if(finNum >= 0){
    //
    //            for index in 0...finNum{
    //                self.voterCache[index] = theJSON["results"]![index]["has_liked"] as? String
    //                self.voterValueCache[index] = theJSON["results"]![index]["hearts"] as? String
    //            }
    //        }
    //
    //    }
    
    
    
    func writeVoterCache(){
        
        let finNum = (theJSON["results"]!.count - 1)
        
        if(finNum >= 0){
            
            for index in 0...finNum{
                self.voterCache[index] = theJSON["results"]![index]["has_liked"] as? String
                self.voterValueCache[index] = theJSON["results"]![index]["hearts"] as? String
            }
        }
        
    }
    
    func startGettingFriends(timer:NSTimer!){
        print("What is going on?")

                    if(self.typeOfCell == 1){
                        for index in 0...(self.theJSON["results"]!.count - 1){
                            
                            let foo = self.theJSON["results"]![index]["userID"] as! String
                            self.getMutualFriends(foo, num:index)
                        }
                    }
        
    }
    func reload_table(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.2 * Double(NSEC_PER_SEC)))
        
        let delayTime2 = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1.1 * Double(NSEC_PER_SEC)))
        
//        dispatch_async(dispatch_get_main_queue()){
//            
//        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "startGettingFriends:", userInfo: nil, repeats: false)
//        
//            }
        if(self.typeOfCell == 1){
            
        }
        
//                    if(self.typeOfCell == 1){
//                        for index in 0...(self.theJSON["results"]!.count - 1){
//                            let foo = self.theJSON["results"]![index]["userID"] as! String
//                            self.getMutualFriends(foo, num:index)
//                        }
//                    }
//        FBSession.openActiveSessionWithReadPermissions(self.fbLoginView.readPermissions, allowLoginUI: true, completionHandler:  {(session: FBSession!, state: FBSessionState, error: NSError!) -> Void in
//            
//            if((error) != nil){
//               // self.getFBFriends(next.substringFromIndex(27))
//                dispatch_after(delayTime2, dispatch_get_main_queue()) {
//                    
//                    if(self.typeOfCell == 1){
//                        for index in 0...(self.theJSON["results"]!.count - 1){
//                            let foo = self.theJSON["results"]![index]["userID"] as! String
//                            self.getMutualFriends(foo, num:index)
//                        }
//                    }
//                }
//            }
//            else{
//                print("THE SESSION ERROR:\(error)")
//            }
//            }
//        )
//        
        
        

        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            if(self.typeOfCell == 1){
            for index in 0...(self.theJSON["results"]!.count - 1){
                let foo = self.theJSON["results"]![index]["userID"] as! String
                self.getMutualFriends(foo, num:index)
            }
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
                //self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                self.tableView.reloadData()
                // self.removeLoadingScreen()
            })
            
        }
        
    }
    
    
    
    
    func showUserProfile(sender: UIGestureRecognizer){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        let profView = mainStoryboard.instantiateViewControllerWithIdentifier("profile_scene_id") as! ProfileViewController
        
        
        //var authorLabel = sender.view? as UILabel
        var authorLabel:AnyObject
        
        authorLabel = sender.view!
        
        let indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
        
        if(indCell?.tag == 100){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell_no_images
            
            //profView.comment = gotCell.comment_label.text!
            profView.userFBID = gotCell.user_id
            
            profView.userName = gotCell.author_label.text!
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell
            
            //profView.comment = gotCell.comment_label.text!
            profView.userFBID = gotCell.user_id
            
            profView.userName = gotCell.author_label.text!
        }
        if(indCell?.tag == 300){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell_person
            
            //profView.comment = gotCell.comment_label.text!
            profView.userFBID = gotCell.user_id
            
            profView.userName = gotCell.name_label.text!
            profView.userFriends = gotCell.friends_label.text!
        }
        
        
        self.presentViewController(profView, animated: true, completion: nil)
        
        
    }
    
    
    func showLoadingScreen(){
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let w = screenSize.width * 0.8
        let h = w * 0.283
        let squareSize = screenSize.width * 0.2
        let xPos = screenSize.width/2 - w/2
        let yPos = screenSize.height/2 - h/2
        
        let holdView = UIView(frame: CGRect(x: xPos, y: yPos, width: w, height: h))
        holdView.backgroundColor = UIColor.whiteColor()
        holdView.tag = 999
        
        holdView.layer.borderWidth=1.0
        holdView.layer.masksToBounds = false
        holdView.layer.borderColor = UIColor.clearColor().CGColor
        //profilePic.layer.cornerRadius = 13
        holdView.layer.cornerRadius = holdView.frame.size.height/10
        holdView.clipsToBounds = true
        
        self.view.addSubview(holdView)
        
        
        
        
        
        
        let label = UILabel(frame: CGRectMake(0, 0, holdView.frame.width, holdView.frame.height*0.2))
        label.textAlignment = NSTextAlignment.Center
        label.text = "Loading Comments..."
        //holdView.addSubview(label)
        
        
        
        
        // Returns an animated UIImage
        let url = NSBundle.mainBundle().URLForResource("loader", withExtension: "gif")
        let imageData = NSData(contentsOfURL: url!)
        
        
        let image = UIImage.animatedImageWithData(imageData!)//UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        
        _ = squareSize*0.6
        let gPos = (holdView.frame.width*0.2)/2
        let kPos = (holdView.frame.height*0.2)/2
        
        
        imageView.frame = CGRect(x: gPos, y: kPos, width: w*0.8, height: h*0.8)
        holdView.addSubview(imageView)
        
    }
    
    
    func getMutualFriends(id:String, num:Int){
        
        //  FBSession.activeSession().accessTokenData.userID
        //FBSession.openActiveSessionWithAllowLoginUI(true)
        
        //        let s = "05e778848e1187897b834fba967cc0c9"
        //        let data = s.dataUsingEncoding(NSUTF8StringEncoding)
        //        var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        //        CC_SHA256(data!.bytes, CC_LONG(data!.length), &hash)
        //        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
        //        let res2 = res.base64EncodedStringWithOptions(nil)
        //        let res3 = res2.toInt()
        //        let res4 = NSNumber(integer: res3!)
        //        print("TOKEN:\(FBSession.activeSession().accessTokenData.accessToken)")
        //        //appsecret_proof
        //        print("DAMN:\(res4)")
        
        let algorithm: CCHmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        let digestLen: Int = Int(CC_SHA256_DIGEST_LENGTH)
        let str0 = FBSession.activeSession().accessTokenData.accessToken
        //let str0 = FBSDKAccessToken.currentAccessToken().tokenString
        let key = "05e778848e1187897b834fba967cc0c9"
        let str = str0.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = Int(str0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        //let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        let keyStr = key.cStringUsingEncoding(NSUTF8StringEncoding)
        let keyLen = Int(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        CCHmac(algorithm, keyStr!, keyLen, str!, strLen, result)
        
        
        let hash = NSMutableString()
        //hash.appendString("<")
        var counter = 0
        for i in 0..<digestLen {
            counter = counter + 1
            hash.appendFormat("%02x", result[i])
            if(counter == 4 && i < (digestLen - 1)){
                //  hash.appendString(" ")
                counter = 0
            }
        }
        // hash.appendString(">")
        //  return String(hash)
        
        let digest = String(hash)// stringFromResult(result, length: digestLen)
        print("THE HASH:\(digest)")
        
        result.dealloc(digestLen)
        
        
        // println(FBSDKAccessToken.currentAccessToken().tokenString)
        //FBSession.openActiveSessionWithAllowLoginUI(true)
        let params = ["fields":"context.fields(mutual_friends)", "access_token":FBSession.activeSession().accessTokenData.accessToken, "appsecret_proof":digest]
        /* make the API call */
        
        //        var t2 = FBSDKGraphRequest(graphPath: "/dXNlcl9jb250ZAXh0OgGQgfRrBrfFMQrZC9POld0N9TnUSgeyL0560CZAXJt1p7Y4ZA3vXErNCgWaIZC7QZCh7ZCcSxbT3KjUxjjtfHg00C0jJ7lC9S4zkWsh8ZCLN9FEl1qG1sZD/all_mutual_friends", parameters: params, HTTPMethod: "GET")
        //        t2.startWithCompletionHandler({(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
        //            println("MUTUAL: \(result)")
        //            println(error)
        //        })
        let first = FBSDKGraphRequest(graphPath: "/\(id)", parameters: params, HTTPMethod: "GET")
        first.startWithCompletionHandler({(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            print("THE ID:\(id)")
            print("MUTUAL: \(result)")
            
            if let err = error {
                print(err)
            }
            
            
            if((result) != nil){
                if let valuec: AnyObject! = result["context"]{
                    if(valuec != nil){
                        if let vm: AnyObject! = valuec["mutual_friends"]{
                            if (vm != nil){
                                if let vs: AnyObject! = vm["summary"]{
                                    if(vs != nil){
                                        if let vt: AnyObject! = vs["total_count"]{
                                            if(vt != nil){
                                                print("NUMBER MUTUAL FRIENDS:\(vt.stringValue)", terminator: "")
                                                self.mutualFriendsCache[id] = vt.stringValue
                                                if let cellToUpdate = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: num, inSection: 0)) as? custom_cell_person {
                                                        cellToUpdate.friends_label?.text = "MUTUAL FRIENDS: \(vt.stringValue)"
                                                }
                                                
//                                                self.tableView.reloadRowsAtIndexPaths(NSIndexPath(forRow: num, inSection: 0), withRowAnimation: UITableViewRowAnimation.None)
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                if let vi: AnyObject! = valuec["id"]{
                                    if(vi != nil){
                                        
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            
                                            let contextid = vi as! String
                                            print("CID:\(contextid)", terminator: "")
                                            
                                            let t2 = FBSDKGraphRequest(graphPath: "/\(contextid)/all_mutual_friends", parameters: params, HTTPMethod: "GET")
                                            t2.startWithCompletionHandler({(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                                                print("RESULT2: \(result)")
                                                
                                                if let err = error {
                                                    print(error)
                                                }
                                                
                                            })
                                            
                                        })
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
                
            }
            else{
            }
            
            
            
            
        })
        
        
    }
    
    func removeLoadingScreen(){
        //self.loadingScreen.alpha = 0.0
        
        dispatch_async(dispatch_get_main_queue(),{
        for view in self.view.subviews {
            if(view.tag == 999){
                view.removeFromSuperview()
            }
        }
        })

    }
    
    
    
    
    
    func sendRequest(dabut: UIButton){
        
        print("START START START")
        let daCellIndex = dabut.tag
        self.userStatusCache[daCellIndex] = "requester"
        let indexPath = NSIndexPath(forRow: daCellIndex, inSection: 0)
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! custom_cell_person
        
        let requestedid = cell.user_id
        cell.relationshipLabel?.text = "pending"
        let lGif = NSBundle.mainBundle().URLForResource("loading_spinner", withExtension: "gif")
        let imageDatagif = NSData(contentsOfURL: lGif!)
        
        let image = UIImage.animatedImageWithData(imageDatagif!)
        cell.interactionButton?.setImage(image, forState: UIControlState.Normal)
        //cell.interactionButton?.addTarget(self, action:"sendReqest:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        
        
        
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_user_request_friend")
        //START AJAX
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
        
        let params = ["gfbid":fbid, "rfbid": requestedid] as Dictionary<String, String>
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
        } catch {
            
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var err: NSError?
            
            var json: NSDictionary?
            do{
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let error as NSError{
                err = error
            } catch {
                
            }
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                dispatch_async(dispatch_get_main_queue(),{
                    self.userStatusCache[daCellIndex] = "connect"
                    let image = UIImage(named: "add_friend.png")
                    cell.interactionButton?.setImage(image, forState: UIControlState.Normal)
                    cell.relationshipLabel?.text = "try again"
                    
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                });
                //CHANGE THE IMAGE BACK TO CONNECT
                
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                
                
                
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                }
            }
        })
        task.resume()
        //END AJAX
        
        
        
        
        
        
    }
    
    func message(dabut: UIButton){
        let daCellIndex = dabut.tag
        
        let status = userStatusCache[daCellIndex]!
        
        print("THE CELL TAG:\(daCellIndex)")
        
        print("THE CELL INFO:\(status)")
        let indexPath = NSIndexPath(forRow: daCellIndex, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! custom_cell_person
        let requestedid = cell.user_id
        let requestername = cell.name_label?.text
        
        // direct_messaging_scene_id
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = mainStoryboard.instantiateViewControllerWithIdentifier("direct_messaging_scene_id") as! DirectMessagingViewController
        
        vc.userFBID = requestedid
        vc.userName = requestername!
        // self.navigationController?.pushViewController(vc, animated: false)
        //   self.navigationController?.popToViewController(vc, animated: false)
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func confirmRequest(dabut: UIButton){
        var daCellIndex = dabut.tag
        self.userStatusCache[daCellIndex] = "friend"
        var indexPath = NSIndexPath(forRow: daCellIndex, inSection: 0)
        
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! custom_cell_person
        
        let requestedid = cell.user_id
        
        
        cell.relationshipLabel?.text = "message"
        
        cell.interactionButton?.addTarget(self, action:"message:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        dispatch_async(dispatch_get_main_queue(),{
            
            
            
            
            let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_user_confirm_friend")
            //START AJAX
            var request = NSMutableURLRequest(URL: url!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let fbid = defaults.stringForKey("saved_fb_id") as String!
            
            var params = ["gfbid":fbid, "rfbid": requestedid] as Dictionary<String, String>
            
            var err: NSError?
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch var error as NSError {
                err = error
                request.HTTPBody = nil
            } catch {
                fatalError()
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                var err: NSError?
                
                var json: NSDictionary?
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                } catch let error as NSError{
                    err = error
                } catch {
                    
                }
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                    
                    
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    
                    
                    
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        
                    }
                }
            })
            task.resume()
            //END AJAX
            
        })
        
        
        
        
        
    }
    
    
    
    
    
    
    //pragma mark - core location
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            
            if (error != nil) {
                print("Error:" + error!.localizedDescription)
                return
                
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks?[0]
                //self.displayLocationInfo(pm)
                
                self.currentUserLocation = String("\(pm!.location!.coordinate.latitude), \(pm!.location!.coordinate.longitude)")
                //print(pm.location.coordinate.latitude)
                //print(pm.location.coordinate.longitude)
                
                print(self.currentUserLocation)
                
            }else {
                print("Error with data")
                
            }
            
            
        })
    }
    
    
    
    
    
    @IBAction func showWriteViewController(){
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        let writeView = mainStoryboard.instantiateViewControllerWithIdentifier("write_comment_scene_id") as! WriteCommentViewController
        
        // writeView.sentLocation = currentUserLocation
        
        
        // self.dismissViewControllerAnimated(true, completion: nil)
        
        self.presentViewController(writeView, animated: true, completion: nil)
        
    }
    
    
    
    func toggleCommentVote(sender:UIGestureRecognizer){
        //get the attached sender imageview
        
        var heartImage:AnyObject
        
        heartImage = sender.view!
        
        //var heartImage = sender.view? as UIImageView
        //get the main view
        
        var indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: heartImage.tag, inSection: 0))
        
        if(indCell?.tag == 100){
            
            var cellView = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: heartImage.tag, inSection: 0)) as! custom_cell_no_images
            
            var cID = cellView.comment_id
            
            
            
            
            
            let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_toggle_comment_vote")
            //START AJAX
            var request = NSMutableURLRequest(URL: url!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            var params = ["fbid":savedFBID, "comment_id":String(cID)] as Dictionary<String, String>
            
            var err: NSError?
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch var error as NSError {
                err = error
                request.HTTPBody = nil
            } catch {
                
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                var err: NSError?
                
                var json: NSDictionary?
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                } catch let error as NSError{
                    err = error
                } catch {
                    
                }
                
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    
                    
                    
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        dispatch_async(dispatch_get_main_queue(),{
                            //change the heart image
                            
                            
                            
                            var testVote = parseJSON["results"]![0]["vote"] as! String!
                            
                            if(testVote == "no"){
                                cellView.heart_icon?.image = UIImage(named: "button_heart_empty.png")
                                
                                //get heart label content as int
                                var curHVal = Int((cellView.heart_label?.text)!)
                                //get the heart label
                                self.voterValueCache[heartImage.tag] = String(curHVal! - 1)
                                cellView.heart_label?.text = String(curHVal! - 1)
                                //self.theJSON["results"]![100]["has_liked"] = "no" as AnyObject!?
                                self.voterCache[heartImage.tag] = "no"
                            }
                            else if(testVote == "yes"){
                                cellView.heart_icon.image = UIImage(named: "button_heart.png")
                                
                                //get heart label content as int
                                var curHVal = Int((cellView.heart_label?.text)!)
                                //get the heart label
                                self.voterValueCache[heartImage.tag] = String(curHVal! + 1)
                                cellView.heart_label?.text = String(curHVal! + 1)
                                self.voterCache[heartImage.tag] = "yes"
                                // self.theJSON["results"]![heartImage.tag]["has_liked"] = "yes" as [AnyObject]
                            }
                        })
                        
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        
                    }
                }
            })
            task.resume()
            
            
            
        }
        
        if(indCell?.tag == 200){
            
            var cellView = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: heartImage.tag, inSection: 0)) as! custom_cell
            
            var cID = cellView.comment_id
            
            
            
            
            
            let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_toggle_comment_vote")
            //START AJAX
            var request = NSMutableURLRequest(URL: url!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            var params = ["fbid":savedFBID, "comment_id":String(cID)] as Dictionary<String, String>
            
            var err: NSError?
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch var error as NSError {
                err = error
                request.HTTPBody = nil
            } catch {
                
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                var err: NSError?
                
                var json: NSDictionary?
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                } catch let error as NSError{
                    err = error
                } catch {
                    
                }
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    
                    
                    
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        dispatch_async(dispatch_get_main_queue(),{
                            //change the heart image
                            
                            
                            
                            var testVote = parseJSON["results"]![0]["vote"] as! String!
                            
                            if(testVote == "no"){
                                cellView.heart_icon?.image = UIImage(named: "button_heart_empty.png")
                                
                                //get heart label content as int
                                var curHVal = Int((cellView.heart_label?.text)!)
                                //get the heart label
                                self.voterValueCache[heartImage.tag] = String(curHVal! - 1)
                                cellView.heart_label?.text = String(curHVal! - 1)
                                //save the new vote value in our array
                                self.voterCache[heartImage.tag] = "no"
                            }
                            else if(testVote == "yes"){
                                cellView.heart_icon?.image = UIImage(named: "button_heart.png")
                                
                                //get heart label content as int
                                var curHVal = Int((cellView.heart_label?.text)!)
                                //get the heart label
                                self.voterValueCache[heartImage.tag] = String(curHVal! + 1)
                                cellView.heart_label?.text = String(curHVal! + 1)
                                self.voterCache[heartImage.tag] = "yes"
                            }
                        })
                        
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        
                    }
                }
            })
            task.resume()
            
            
            
        }
        
    }
    
    
    
    
}