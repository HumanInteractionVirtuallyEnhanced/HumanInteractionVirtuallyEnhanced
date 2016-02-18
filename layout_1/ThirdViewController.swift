
//
//  ThirdViewController.swift
//  layout_1
//
//  Created by Rijul Gupta on 3/7/15.
//  Copyright (c) 2015 Rijul Gupta. All rights reserved.
//

import UIKit



class ThirdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
     
     
     // @IBOutlet var commentLabel: UILabel!
     @IBOutlet var topRightButton:UIBarButtonItem!
     @IBOutlet var authorLabel: UILabel!
     @IBOutlet var authorPicture: UIImageView!
     @IBOutlet var commentView: UITextView!
     @IBOutlet var replyHolderView: UIView!
     @IBOutlet var tableView: UITableView! //holds replies and likes
     @IBOutlet var tabBar: UITabBar! //controls tableview
     @IBOutlet var scrollView: UIScrollView!
     
     @IBOutlet var locLabel:UILabel!
     var locString = "none"
     @IBOutlet var timeLabel:UILabel!
     var timeString = "none"
     @IBOutlet var replyCommentView: UITextField!
     
     @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
     
     @IBOutlet var replyButton: UIButton!
     
     @IBOutlet weak var comImageConstraint: NSLayoutConstraint!
     @IBOutlet weak var comWidthConstraint: NSLayoutConstraint!
     var testString = "1"
     var comment = "empty"
     var author = "empty"
     var imgLink = "empty"
     var authorFBID = "empty"
     
     var commentID = "empty"
     
     var imageLink = "none"
     
     var savedFBID = "none"
     
     //  var comImage: UIImageView!
     @IBOutlet var comImage: UIImageView!
     
     var sentLocation = "none"
     var isLoading = false
     
     var hasLoaded = false
     var theJSON: NSDictionary!
     var focusTableOn = "none"
     var numOfCells = 0
     //let transportItems = ["Bus","Helicopter","Truck","Boat","Bicycle","Motorcycle","Plane","Train","Car","Scooter","Caravan"]
     
     
     
     
     
     override func viewDidLoad() {
          super.viewDidLoad()
          self.commentView.text = "wait for it..."
          self.authorLabel.text = "..."
          self.locLabel.text = "..."
          self.timeLabel.text = "..."
          let defaults = NSUserDefaults.standardUserDefaults()
          savedFBID = defaults.stringForKey("saved_fb_id")!
          
          
          
          tableView.estimatedRowHeight = 108.0
          tableView.rowHeight = UITableViewAutomaticDimension
          
          tabBar.delegate = self
          
          let firstItem = tabBar.items![0] 
          firstItem.tag = 1
          let secondItem = tabBar.items![1] 
          secondItem.tag = 2
          
          
          
          
          
          comImage.layer.masksToBounds = false
          comImage.layer.cornerRadius = 6
          comImage.clipsToBounds = true
          
          
          getCommentInfo()
          
          
          
     }
     
     override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          
          
          
          print(imgLink)
          //START AJAX
          
          if(authorFBID == savedFBID){
               self.topRightButton.title = "Delete"
               //self.topRightButton.target = nil
               self.topRightButton.action = nil
               //self.topRightButton.target = self
               self.topRightButton.action = "did_hit_delete"
          }
          
          
          //println("THIS IS THE SENT LOCATION:\(sentLocation)")
          
          
          
     }
     
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     override func viewWillAppear(animated: Bool) {
          
          
          super.viewWillAppear(animated)
          
          
          if(self.focusTableOn == "likers"){
               let secondItem = tabBar.items![1] 
               tabBar.selectedItem = secondItem
               get_comment_likers()
          }
          else{
               let firstItem = tabBar.items![0] 
               tabBar.selectedItem = firstItem
               get_comment_replies()
               
          }
          
          
          
          NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
          NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
          
          
          
          
          //  getUserPicture()
          
     }
     
     func loadCommentPicture(){
          
          if(imgLink == "none" || imgLink == "none2" || imgLink == "None"){
               
               let height2 = commentView.frame.height + tableView.frame.height + tabBar.frame.height + 40
               scrollView.contentSize = CGSize(width:scrollView.frame.width, height:height2)
          }
          else{
               let height2 = commentView.frame.height + comImage.frame.height + tableView.frame.height + tabBar.frame.height + 80
               scrollView.contentSize = CGSize(width:scrollView.frame.width, height:height2)
               
               
          }
          
          
          if(imgLink == "none2" || imgLink == "none" || imgLink == "None"){
               self.comImage.removeFromSuperview()
               
               let fakeCon = NSLayoutConstraint(item: self.commentView,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.tabBar,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1,
                    constant: -20 )
               //
               //               var fakeCon2 = NSLayoutConstraint(item: self.commentView,
               //                    attribute: NSLayoutAttribute.Left,
               //                    relatedBy: NSLayoutRelation.Equal,
               //                    toItem: self.locLabel,
               //                    attribute: NSLayoutAttribute.Left,
               //                    multiplier: 1.0,
               //                    constant:0)
               //
               //               var fakeCon3 = NSLayoutConstraint(item: self.commentView,
               //                    attribute: NSLayoutAttribute.Right,
               //                    relatedBy: NSLayoutRelation.Equal,
               //                    toItem: self.view,
               //                    attribute: NSLayoutAttribute.Right,
               //                    multiplier: 1.0,
               //                    constant:-10)
               //
               //               self.commentView.frame = CGRectMake(self.commentView.frame.origin.x, self.commentView.frame.origin.y, 300, self.commentView.frame.height)
               //               var fakeCon2 = NSLayoutConstraint(item: self.commentView,
               //                    attribute: NSLayoutAttribute.Width,
               //                    relatedBy: NSLayoutRelation.Equal,
               //                    toItem: self.locLabel,
               //                    attribute: NSLayoutAttribute.Left,
               //                    multiplier: 1.0,
               //                    constant:0)
               //
               
               
               self.view.addConstraint(fakeCon)
               //               self.view.addConstraint(fakeCon2)
               //               self.view.addConstraint(fakeCon3)
               // self.commentView.addConstraint(fakeCon)
               self.view.updateConstraints()
          }
          else{
               
               print("THE WIDTH:\(self.view.frame.width)")
               if(self.view.frame.width <= 320.0){
                    self.comWidthConstraint.constant = 250
               }
               //give a loading gif to UI
               let urlgif = NSBundle.mainBundle().URLForResource("loader", withExtension: "gif")
               let imageDatagif = NSData(contentsOfURL: urlgif!)
               
               
               let imagegif = UIImage.animatedImageWithData(imageDatagif!)
               
               comImage.image = imagegif
               
               
               var imgURL:NSURL = NSURL(string: imgLink)!
               let url = NSURL(string: imgLink)
               let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
               comImage.image = UIImage(data: data!)
               
          }
          
     }
     
     func getUserPicture(){
          
          
          if(authorFBID != "empty"){
               let url = NSURL(string: "http://graph.facebook.com/\(authorFBID)/picture?width=720&height=720")
               let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
               authorPicture.image = UIImage(data: data!)
               authorPicture.layer.borderWidth=1.0
               authorPicture.layer.masksToBounds = false
               authorPicture.layer.borderColor = UIColor.whiteColor().CGColor
               //profilePic.layer.cornerRadius = 13
               authorPicture.layer.cornerRadius = authorPicture.frame.size.height/2
               authorPicture.clipsToBounds = true
          }
     }
     
     override func viewWillDisappear(animated: Bool) {
          super.viewWillDisappear(animated)
          NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
          NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
     }
     
     
     @IBAction func did_press_back(){
          
          
          self.dismissViewControllerAnimated(true, completion: nil)
     }
     
     func keyboardWillShowNotification(notification: NSNotification) {
          updateBottomLayoutConstraintWithNotification(notification)
     }
     
     func keyboardWillHideNotification(notification: NSNotification) {
          updateBottomLayoutConstraintWithNotification(notification)
     }
     
     
     
     func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
          
          let userInfo = notification.userInfo!
          
          let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
          let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
          
          
          
          let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
          let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
          
          bottomLayoutConstraint.constant = -1*keyboardFrame.size.height + 1
          UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState.union(animationCurve), animations: {
               self.view.layoutIfNeeded()
               }, completion: nil)
     }
     
     
     
     
     
     
     
     
     
     
     //pragma mark - table view
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          if(hasLoaded == false){
               return numOfCells
          }
          else{
               //return 5
               return numOfCells
          }
          
     }
     
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
     {
          
          if(self.focusTableOn == "replies"){
               let cell = tableView.dequeueReusableCellWithIdentifier("reply_cell") as! reply_cell
               
               
               let fbid = theJSON["results"]![indexPath.row]["user_id"] as! String!
               
               
               let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?width=50&height=50")
               let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
               
               
               cell.userImage?.image = UIImage(data: data!)
               cell.nameLabel.text = theJSON["results"]![indexPath.row]["author"] as! String!
               
               cell.replyLabel.text = theJSON["results"]![indexPath.row]["comments"] as! String!
               //cell.replyLabel.text = "SLKFJSLKJF"
               cell.userFBID = fbid
               
               return cell
          }
          else{
               let cell = tableView.dequeueReusableCellWithIdentifier("user_cell") as! user_cell
               
               
               let fbid = theJSON["results"]![indexPath.row]["userID"] as! String!
               
               
               let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?width=50&height=50")
               let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
               
               
               cell.userImage?.image = UIImage(data: data!)
               cell.nameLabel.text = theJSON["results"]![indexPath.row]["userName"] as! String!
               
               
               let followTest = theJSON["results"]![indexPath.row]["userFollow"] as! String!
               //test if general user is following the presented user
               //cell.followButton.titleLabel?.text = "test"
               
               if(followTest == "yes"){//the user is follow, we give option to change
                    //cell.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                    cell.followButton.setImage(UIImage(named: "Unfollow.png"), forState: UIControlState.Normal)
               }
               else{
                    // cell.followButton.setTitle("Follow", forState: UIControlState.Normal)
                    cell.followButton.setImage(UIImage(named: "Follow.png"), forState: UIControlState.Normal)
               }
               
               // cell.followButton.addTarget(self, action: "DidPressFollow:", forControlEvents: .TouchUpInside)
               //cell.followButton.tag = indexPath.row
               cell.userFBID = fbid
               
               return cell
          }
          
          
     }
     
     
     
     
     
     
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
          
          if(self.focusTableOn == "replies"){
               
               let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
               //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
               let profView = mainStoryboard.instantiateViewControllerWithIdentifier("profile_scene_id") as! ProfileViewController
               
               
               //  var authorLabel = sender.view? as UILabel
               
               //   let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
               
               
               let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! reply_cell
               //let indCell = tableView.cellForRowAtIndexPath(indexPath) as user_cell
               
               profView.userFBID = gotCell.userFBID
               profView.userName = gotCell.nameLabel.text!
               
               
               
               self.presentViewController(profView, animated: true, completion: nil)
          }
          else if(self.focusTableOn == "likers"){
               
               
               let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
               //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
               let profView = mainStoryboard.instantiateViewControllerWithIdentifier("profile_scene_id") as! ProfileViewController
               
               
               //  var authorLabel = sender.view? as UILabel
               
               //   let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
               
               
               let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! user_cell
               //let indCell = tableView.cellForRowAtIndexPath(indexPath) as user_cell
               
               profView.userFBID = gotCell.userFBID
               profView.userName = gotCell.nameLabel.text!
               
               
               
               self.presentViewController(profView, animated: true, completion: nil)
               
          }
          
          
     }
     
     func get_comment_replies(){
          let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_comment_replies")
          //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
          //START AJAX
          let request = NSMutableURLRequest(URL: url!)
          let session = NSURLSession.sharedSession()
          request.HTTPMethod = "POST"
          
          let params = ["fb_id":savedFBID, "latLon":sentLocation, "cID":commentID] as Dictionary<String, String>
          
          
          var err: NSError?
          do {
           request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
          } catch let error as NSError {
           err = error
           request.HTTPBody = nil
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
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
               }
               else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                         
                         
                         
                         self.theJSON = parseJSON
                         self.hasLoaded = true
                         self.focusTableOn = "replies"
                         self.numOfCells = parseJSON["results"]!.count
                         
                         self.reload_table()
                         //  self.dismissViewControllerAnimated(true, completion: nil)
                         
                    }
                    else {
                         
                    }
               }
          })
          task.resume()
          
     }
     
     func get_comment_likers(){
          let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_comment_likers")
          //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
          //START AJAX
          let request = NSMutableURLRequest(URL: url!)
          let session = NSURLSession.sharedSession()
          request.HTTPMethod = "POST"
          
          let params = ["fb_id":savedFBID, "latLon":sentLocation, "cID":commentID] as Dictionary<String, String>
          
          
          var err: NSError?
          do {
           request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
          } catch let error as NSError {
           err = error
           request.HTTPBody = nil
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
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
               }
               else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                         
                         
                         
                         self.theJSON = parseJSON
                         self.hasLoaded = true
                         self.focusTableOn = "likers"
                         self.numOfCells = parseJSON["results"]!.count
                         
                         self.reload_table()
                         //  self.dismissViewControllerAnimated(true, completion: nil)
                         
                    }
                    else {
                         
                    }
               }
          })
          task.resume()
          
     }
     
    func did_hit_delete(){
     
     let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
     let vc = mainStoryboard.instantiateViewControllerWithIdentifier("MyProfileViewId") as! MyProfileViewController
     vc.commingFrom = "delete_comment"
     
                    let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_user_delete_comment")
                    //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
                    //START AJAX
                    let request = NSMutableURLRequest(URL: url!)
                    let session = NSURLSession.sharedSession()
                    request.HTTPMethod = "POST"
          
                    let authorN = authorLabel.text! as String
                    let params = ["c_id":commentID, "fbid":authorFBID,  "g_fbid":savedFBID] as Dictionary<String, String>
          
          
                    var err: NSError?
                    do {
                     request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                    } catch let error as NSError {
                     err = error
                     request.HTTPBody = nil
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
                              print(err!.localizedDescription)
                              let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                              print("Error could not parse JSON: '\(jsonStr)'")
                         }
                         else {
                              // The JSONObjectWithData constructor didn't return an error. But, we should still
                              // check and make sure that json has a value using optional binding.
                              if let parseJSON = json {
          
                                   dispatch_async(dispatch_get_main_queue(),{
                                             let alert = UIAlertView()
                                             alert.title = "Post Deleted"
                                             alert.message = "Don't to it again!"
                                             alert.addButtonWithTitle("I won't, I promise.")
                                             alert.show()
                                   
                                   
                                   
                                   self.dismissViewControllerAnimated(true, completion: nil)
                                   })
          
                              }
                              else {
          
                              }
                         }
                    })
                    task.resume()
          
     }
     
     
     @IBAction func did_hit_flag(){
          //          let alert = UIAlertView()
          //          alert.title = "You flagged this post."
          //          alert.message = "We will take any inappropriate content down. Flag three posts to block a user."
          //          alert.addButtonWithTitle("Okay, thank you.")
          //          alert.show()
          //
          //
          //          let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_user_flagged")
          //          //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
          //          //START AJAX
          //          var request = NSMutableURLRequest(URL: url!)
          //          var session = NSURLSession.sharedSession()
          //          request.HTTPMethod = "POST"
          //
          //          let authorN = authorLabel.text! as String
          //          var params = ["c_id":commentID, "author":authorN, "fbid":authorFBID,  "g_fbid":savedFBID] as Dictionary<String, String>
          //
          //
          //          var err: NSError?
          //          request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
          //          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          //          request.addValue("application/json", forHTTPHeaderField: "Accept")
          //
          //          var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
          //               println("Response: \(response)")
          //               var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
          //               println("Body: \(strData)")
          //               var err: NSError?
          //               var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
          //
          //
          //               // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
          //               if(err != nil) {
          //                    println(err!.localizedDescription)
          //                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
          //                    println("Error could not parse JSON: '\(jsonStr)'")
          //               }
          //               else {
          //                    // The JSONObjectWithData constructor didn't return an error. But, we should still
          //                    // check and make sure that json has a value using optional binding.
          //                    if let parseJSON = json {
          //
          //
          //                    }
          //                    else {
          //
          //                    }
          //               }
          //          })
          //          task.resume()
          //
          
          
          
     }
     
     @IBAction func did_hit_reply(){
          //func did_hit_reply(){
          
          if(isLoading == false){
               isLoading = true
               
               print("Data is: \(self.replyCommentView.text)")
               
               let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_reply_to_comment")
               //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
               //START AJAX
               let request = NSMutableURLRequest(URL: url!)
               let session = NSURLSession.sharedSession()
               request.HTTPMethod = "POST"
               
               let params = ["rBody":self.replyCommentView.text!, "fb_id":savedFBID, "latLon":sentLocation, "imgLink":imageLink, "cID":commentID] as Dictionary<String, String>
               
               
               var err: NSError?
               do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
               } catch let error as NSError {
                err = error
                request.HTTPBody = nil
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
                         print(err!.localizedDescription)
                         let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                         print("Error could not parse JSON: '\(jsonStr)'")
                    }
                    else {
                         // The JSONObjectWithData constructor didn't return an error. But, we should still
                         // check and make sure that json has a value using optional binding.
                         if let parseJSON = json {
                              
                              
                              
                              self.finishedReply()
                              
                              
                              //  self.dismissViewControllerAnimated(true, completion: nil)
                              
                         }
                         else {
                              
                         }
                    }
               })
               task.resume()
               
          }
          
          
          // println("SLKDJFLSKDJFSDFLKJS")
          //     self.dismissViewControllerAnimated(true, completion: nil)
     }
     
     func finishedReply(){
          dispatch_async(dispatch_get_main_queue(),{
               
               self.isLoading = false
               self.replyCommentView?.resignFirstResponder()
               
               // UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)
               self.focusTableOn = "replies"
               self.get_comment_replies()
               
               
               let animationDuration = 0.2
               self.replyCommentView?.text = ""
               
               self.bottomLayoutConstraint.constant = 0.0
               UIView.animateWithDuration(animationDuration, delay: 0.0, options:[], animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
               
               
               // self.removeLoadingScreen()
          })
     }
     
     
     func getCommentInfo(){
          
          let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_comment_info")
          //START AJAX
          let request = NSMutableURLRequest(URL: url!)
          let session = NSURLSession.sharedSession()
          request.HTTPMethod = "POST"
          
          let defaults = NSUserDefaults.standardUserDefaults()
          let fbid = defaults.stringForKey("saved_fb_id") as String!
          
          let params = ["c_id":commentID] as Dictionary<String, String>
          
          var err: NSError?
          do {
           request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
          } catch let error as NSError {
           err = error
           request.HTTPBody = nil
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
               
               
               //self.theJSON = NSJSONSerialization.JSONObjectWithData(json, options:.MutableLeaves, error: &err) as? NSDictionary
               
               
               // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
               if(err != nil) {
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                    //  self.removeLoadingScreen()
                    
               }
               else {
                    
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    
                    
                    
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                         // let leftHandItems: [String] = ["","Last Check In", "Posts", "Followers", "Following"]
                         
                         
                         dispatch_async(dispatch_get_main_queue(), {
                              
                              self.commentView.text = parseJSON["results"]![0]["body"] as! String!
                              self.authorLabel.text = parseJSON["results"]![0]["author"] as! String!
                              self.locLabel.text = parseJSON["results"]![0]["location"] as! String!
                              self.timeLabel.text = parseJSON["results"]![0]["time"] as! String!
                              // self.imageLink = parseJSON["results"]![0]["imgLink"] as String!
                              self.imgLink = parseJSON["results"]![0]["imgLink"] as! String!
                              self.authorFBID = parseJSON["results"]![0]["authorFBID"] as! String!
                              
                              self.getUserPicture()
                              self.loadCommentPicture()
                              
                              
                         })
                         //
                         
                         
                         //   self.reload_table()
                         
                    }
                    else {
                         // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                         //   self.showErrorScreen("top")
                    }
               }
          })
          task.resume()
          //END AJAX
          
          
          
     }
     
     
     
     
     
     func reload_table(){
          let delayTime = dispatch_time(DISPATCH_TIME_NOW,
               Int64(0.3 * Double(NSEC_PER_SEC)))
          
          dispatch_after(delayTime, dispatch_get_main_queue()) {
               
               dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                    // self.removeLoadingScreen()
               })
               
          }
          
     }
     
     
     
     func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
          if(item.tag == 1){
               //  println("PPSDJFOSDJF")
               get_comment_replies()
          }
          if(item.tag == 2){
               get_comment_likers()
          }
     }
     
     
}
