//
//  UserFriendsViewController.swift
//  layout_1
//
//  Created by Rijul Gupta on 3/15/15.
//  Copyright (c) 2015 Rijul Gupta. All rights reserved.
//


import UIKit



class UserFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userFBID = "none"
    var ajaxRequestString = "none"
    
   @IBOutlet var tableView:UITableView!
    @IBOutlet var titleItem:UINavigationItem!
    
    
    var userImageCache = [String: UIImage]()
    
    var theJSON: NSDictionary!
    var hasLoaded:Bool = false
    var numOfCells = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = tableView.frame.height/8
        
        if(ajaxRequestString == "followers"){
            titleItem.title = "Followers"
            get_user_followers()
            
            let tracker = GAI.sharedInstance().trackerWithTrackingId("UA-58702464-2")
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("User Friends", action: "Show", label: "Followers", value: nil).build() as [NSObject : AnyObject])
            
        }
        else if(ajaxRequestString == "following"){
            titleItem.title = "Following"
            get_user_following()
            
            let tracker = GAI.sharedInstance().trackerWithTrackingId("UA-58702464-2")
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("User Friends", action: "Show", label: "Following", value: nil).build() as [NSObject : AnyObject])
        }
        
       
        
        
    }
    
    override func viewDidLayoutSubviews() {
        let color: UIColor = UIColor( red: CGFloat(255.0/255.0), green: CGFloat(217.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0) )
        self.tableView.separatorColor = color
        //self.tableView.separatorStyle
        self.tableView.separatorInset.left = 0
        self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidAppear(animated: Bool) {
        print(ajaxRequestString)
        print(userFBID)
        
    
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func did_press_back(){
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    //pragma mark - table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //make sure the json has loaded before we do anything
        return numOfCells
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("user_cell") as! user_cell
        
    
        var fbid = theJSON["results"]![indexPath.row]["userID"] as! String!

        let testUserImg = "http://graph.facebook.com/\(fbid)/picture?width=40&height=40"
        
        //let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?width=50&height=50")
       // let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        
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
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? user_cell {
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
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? user_cell {
                    cellToUpdate.userImage?.image = upimage
                }
            })
        }
        

        
        
        
        
       // cell.userImage?.image = UIImage(data: data!)
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
    
//    
//    func DidPressFollow(sender: UIButton!){
//        println("KLSDFJKSDFJ:\(sender.tag)")
//        
//
//        //self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
//    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        let profView = mainStoryboard.instantiateViewControllerWithIdentifier("profile_scene_id") as! ProfileViewController
        
        
      //  var authorLabel = sender.view? as UILabel
        
     //   let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
        
        
         let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! user_cell

            profView.userFBID = gotCell.userFBID
            profView.userName = gotCell.nameLabel.text!

        
        
        self.presentViewController(profView, animated: true, completion: nil)
        
        
        
    }
    
    
    
    //pragma mark - ajax
    func get_user_followers(){
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
        
        
        
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_user_followers")
        //START AJAX
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params = ["gUser_fbID":fbid, "iUser_fbID":userFBID] as Dictionary<String, String>
        
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
                
                if let parseJSON = json {
                    
                    
                    self.theJSON = json
                    self.hasLoaded = true
                    self.numOfCells = parseJSON["results"]!.count
                    
                    self.reload_table()
                    
                    
                    
                }
                else {
                    
                    
                }
            }
        })
        task.resume()
        //END AJAX

        
    }

    
    func get_user_following(){
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
        
        
        
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_user_following")
        //START AJAX
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params = ["gUser_fbID":fbid, "iUser_fbID":userFBID] as Dictionary<String, String>
        
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
                
                if let parseJSON = json {
                    
                    
                    self.theJSON = json
                    self.hasLoaded = true
                    self.numOfCells = parseJSON["results"]!.count
                    
                    self.reload_table()
                    
                    
                    
                }
                else {
                    
                    
                }
            }
        })
        task.resume()
        //END AJAX
        
        
    }
    
    
    func reload_table(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.1 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
                //self.removeLoadingScreen()
            })
            
        }
        
    }

    
    
    
    
    
    
    
    
       
    
}
