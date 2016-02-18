//
//  FollowingViewController.swift
//  layout_1
//
//  Created by Rijul Gupta on 4/15/15.
//  Copyright (c) 2015 Rijul Gupta. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var tableView: UITableView!
    
    var imageCache = [String : UIImage]()
    var userImageCache = [String: UIImage]()
    var voterCache = [Int : String]()
    var voterValueCache = [Int : String]()
    var refreshControl:UIRefreshControl!
    
    
    var hasLoaded = false
    var theJSON: NSDictionary!
    var savedFBID = "none"
    var numOfCells = 0
    var oldScrollPost:CGFloat = 0.0
    //var radValue = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = NSUserDefaults.standardUserDefaults()
        savedFBID =
            defaults.stringForKey("saved_fb_id")!
        
        
        tableView.estimatedRowHeight = 300.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        let color: UIColor = UIColor( red: CGFloat(255.0/255.0), green: CGFloat(210.0/255.0), blue: CGFloat(11.0/255.0), alpha: CGFloat(1.0) )
        self.tableView.separatorColor = color
        //self.tableView.separatorStyle
        self.tableView.separatorInset.left = 0
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.backgroundColor = color
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        loadUserComments()
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
        let testImage = theJSON["results"]![indexPath.row]["image"] as! String!
        
        if(testImage == "none"){
            let cell = tableView.dequeueReusableCellWithIdentifier("custom_cell_no_images") as! custom_cell_no_images
//            
//            
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            cell.separatorInset.left = -10
//            cell.layoutMargins = UIEdgeInsetsZero
//            cell.imageLink = testImage
//            cell.tag = 100
//            
//            
//            
//            //set the cell contents with the ajax data
//            cell.comment_label?.text = theJSON["results"]![indexPath.row]["comments"] as! String!
//            cell.comment_id = theJSON["results"]![indexPath.row]["c_id"] as! String!
//            cell.author_label?.text = theJSON["results"]![indexPath.row]["author"] as! String!
//            cell.loc_label?.text = theJSON["results"]![indexPath.row]["location"] as! String!
//            cell.heart_label?.text = voterValueCache[indexPath.row] as String!
//            cell.time_label?.text = theJSON["results"]![indexPath.row]["time"] as! String!
//            cell.replyNumLabel?.text = theJSON["results"]![indexPath.row]["numComments"] as! String!
//            let myMutableString = NSMutableAttributedString(string: "Herro", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!])
//            
//            let myMutableString2 = NSMutableAttributedString(string: "World", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 8.0)!])
//            
//            myMutableString.appendAttributedString(myMutableString2)
//            
//            
//            //     cell.comment_label?.attributedText = myMutableString
//            
//            //var doit: NSAttributedString! = self.parseHTMLString(cell.comment_label?.text!)
//            
//            let asdfasd = cell.comment_label?.text!
//            
//            var gotURL = self.parseHTMLString(asdfasd!)
//            
//            println("OH YEAH:\(gotURL)")
//            
//            if(gotURL.count == 0){
//                println("NO SHOW")
//                cell.urlLink = "none"
//            }
//            else{
//                println("LAST TIME BuDDY:\(gotURL.last)")
//                cell.urlLink = gotURL.last! as! String
//            }
//            
//            
//            let userFBID = theJSON["results"]![indexPath.row]["user_id"] as! String!
//            cell.user_id = userFBID
//            
//            // cell.userImage.frame = CGRectMake(20, 20, 20, 20)
//            let testUserImg = "http://graph.facebook.com/\(userFBID)/picture?type=small"
//            //     let imageLink = "http://graph.facebook.com/\(userFBID)/picture?type=small"
//            //let url = NSURL(string: imageLink)
//            // let data2 = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
//            // comImage.image = UIImage(data: data!)
//            
//            //  cell.userImage.image = UIImage(data:data2!)
//            
//            
//            
//            //GET TEH USER IMAGE
//            var upimage = self.userImageCache[testUserImg]
//            if( upimage == nil ) {
//                // If the image does not exist, we need to download it
//                
//                var imgURL: NSURL = NSURL(string: testUserImg)!
//                
//                // Download an NSData representation of the image at the URL
//                let request: NSURLRequest = NSURLRequest(URL: imgURL)
//                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//                    if error == nil {
//                        upimage = UIImage(data: data)
//                        
//                        // Store the image in to our cache
//                        self.userImageCache[testUserImg] = upimage
//                        dispatch_async(dispatch_get_main_queue(), {
//                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell_no_images {
//                                cellToUpdate.userImage?.image = upimage
//                            }
//                        })
//                    }
//                    else {
//                        println("Error: \(error.localizedDescription)")
//                    }
//                })
//                
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? custom_cell_no_images {
//                        cellToUpdate.userImage?.image = upimage
//                    }
//                })
//            }
//            
//            
//            
//            
//            
//            
//            
//            
//            let authorTap = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
//            // 4
//            authorTap.delegate = self
//            cell.author_label?.tag = indexPath.row
//            cell.author_label?.userInteractionEnabled = true
//            cell.author_label?.addGestureRecognizer(authorTap)
//            
//            let authorTap2 = UITapGestureRecognizer(target: self, action:Selector("showUserProfile:"))
//            // 4
//            authorTap2.delegate = self
//            cell.userImage?.tag = indexPath.row
//            cell.userImage?.userInteractionEnabled = true
//            cell.userImage?.addGestureRecognizer(authorTap2)
//            
//            
//            
//            let likersTap = UITapGestureRecognizer(target: self, action:Selector("showLikers:"))
//            likersTap.delegate = self
////            cell.likerButtonLabel?.tag = indexPath.row
////            cell.likerButtonLabel?.userInteractionEnabled = true
////            cell.likerButtonLabel?.addGestureRecognizer(likersTap)
//            cell.heart_label?.tag = indexPath.row
//            cell.heart_label?.userInteractionEnabled = true
//            cell.heart_label?.addGestureRecognizer(likersTap)
//            
//            
//            
//            let repliesTap = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
//            repliesTap.delegate = self
//            cell.replyButtonImage?.tag = indexPath.row
//            cell.replyButtonImage?.userInteractionEnabled = true
//            cell.replyButtonImage?.addGestureRecognizer(repliesTap)
//            
//            let repliesTap2 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
//            repliesTap2.delegate = self
//            cell.replyButtonLabel?.tag = indexPath.row
//            cell.replyButtonLabel?.userInteractionEnabled = true
//            cell.replyButtonLabel?.addGestureRecognizer(repliesTap2)
//            
//            let repliesTap3 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
//            repliesTap3.delegate = self
//            cell.replyNumLabel?.tag = indexPath.row
//            cell.replyNumLabel?.userInteractionEnabled = true
//            cell.replyNumLabel?.addGestureRecognizer(repliesTap3)
//            
//            
//            
//            
//            
//            //
//            
//            //
//            //
//            let shareTap = UITapGestureRecognizer(target: self, action:Selector("shareComment:"))
//            shareTap.delegate = self
//            cell.shareLabel?.tag = indexPath.row
//            cell.shareLabel?.userInteractionEnabled = true
//            cell.shareLabel?.addGestureRecognizer(shareTap)
//            // cell.bringSubviewToFront(cell.shareLabel)
//            // cell.contentView.bringSubviewToFront(cell.shareLabel)
//            
//            let shareTap2 = UITapGestureRecognizer(target: self, action:Selector("shareComment:"))
//            shareTap2.delegate = self
//            cell.shareButton?.tag = indexPath.row
//            cell.shareButton?.userInteractionEnabled = true
//            cell.shareButton?.addGestureRecognizer(shareTap2)
//            // cell.bringSubviewToFront(cell.shareButton)
//            //
//            
//            //find out if the user has liked the comment or not
//            var hasLiked = voterCache[indexPath.row] as String!
//            
//            if(hasLiked == "yes"){
//                cell.heart_icon?.userInteractionEnabled = true
//                cell.heart_icon?.image = UIImage(named: "button_heart.png")
//                
//                let voteDown = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
//                // 4
//                voteDown.delegate = self
//                cell.heart_icon?.tag = indexPath.row
//                cell.heart_icon?.addGestureRecognizer(voteDown)
//                
//                
//            }
//            else if(hasLiked == "no"){
//                cell.heart_icon?.userInteractionEnabled = true
//                cell.heart_icon?.image = UIImage(named: "button_heart_empty.png")
//                
//                let voteUp = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
//                // 4
//                voteUp.delegate = self
//                cell.heart_icon?.tag = indexPath.row
//                cell.heart_icon?.addGestureRecognizer(voteUp)
//            }
//            
//            
//            
//            let voteUp2 = UITapGestureRecognizer(target: self, action:Selector("toggleCommentVote:"))
//            cell.likerButtonHolder?.userInteractionEnabled = true
//            voteUp2.delegate = self
//            cell.likerButtonHolder?.tag = indexPath.row
//            cell.likerButtonHolder?.addGestureRecognizer(voteUp2)
//            
//            
            
            
            
            return cell
            
            
            
        }
        else{
            //image
            let cell = tableView.dequeueReusableCellWithIdentifier("custom_cell") as! custom_cell
            
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.separatorInset.left = -10
            cell.layoutMargins = UIEdgeInsetsZero
            cell.imageLink = testImage
            cell.tag = 200
            
            
            
            //set the cell contents with the ajax data
            cell.comment_label?.text = theJSON["results"]![indexPath.row]["comments"] as! String!
            cell.comment_id = theJSON["results"]![indexPath.row]["c_id"] as! String!
            cell.author_label?.text = theJSON["results"]![indexPath.row]["author"] as! String!
            cell.loc_label?.text = theJSON["results"]![indexPath.row]["location"] as! String!
            cell.heart_label?.text = voterValueCache[indexPath.row] as String!
            cell.time_label?.text = theJSON["results"]![indexPath.row]["time"] as! String!
            cell.replyNumLabel?.text = theJSON["results"]![indexPath.row]["numComments"] as! String!
            let myMutableString = NSMutableAttributedString(string: "Herro", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!])
            
            let myMutableString2 = NSMutableAttributedString(string: "World", attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 8.0)!])
            
            myMutableString.appendAttributedString(myMutableString2)
            
            
            //     cell.comment_label?.attributedText = myMutableString
            
            //var doit: NSAttributedString! = self.parseHTMLString(cell.comment_label?.text!)
            
            let asdfasd = cell.comment_label?.text!
            
            let gotURL = self.parseHTMLString(asdfasd!)
            
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
                
                let imgURL: NSURL = NSURL(string: testUserImg)!
                
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
            
            
            
            let repliesTap = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
            repliesTap.delegate = self
            cell.replyButtonImage?.tag = indexPath.row
            cell.replyButtonImage?.userInteractionEnabled = true
            cell.replyButtonImage?.addGestureRecognizer(repliesTap)
            
            let repliesTap2 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
            repliesTap2.delegate = self
            cell.replyButtonLabel?.tag = indexPath.row
            cell.replyButtonLabel?.userInteractionEnabled = true
            cell.replyButtonLabel?.addGestureRecognizer(repliesTap2)
            
            let repliesTap3 = UITapGestureRecognizer(target: self, action:Selector("showReplies:"))
            repliesTap3.delegate = self
            cell.replyNumLabel?.tag = indexPath.row
            cell.replyNumLabel?.userInteractionEnabled = true
            cell.replyNumLabel?.addGestureRecognizer(repliesTap3)
            
            
            
            
            
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
            let hasLiked = voterCache[indexPath.row] as String!
            
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
            let urlgif = NSBundle.mainBundle().URLForResource("loader2", withExtension: "gif")
            let imageDatagif = NSData(contentsOfURL: urlgif!)
            
            
            let imagegif = UIImage.animatedImageWithData(imageDatagif!)
            
            cell.comImage.image = imagegif
            
            
            
            //GET TEH COMMENT IMAGE
            var image = self.imageCache[testImage]
            if( image == nil ) {
                // If the image does not exist, we need to download it
                let imgURL: NSURL = NSURL(string: testImage)!
                
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
            
            
            
            
            
            return cell
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
       
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let comView = mainStoryboard.instantiateViewControllerWithIdentifier("com_focus_scene_id") as! ThirdViewController
        //
        
        
        let indCell = tableView.cellForRowAtIndexPath(indexPath)
        
        let mainView = mainStoryboard.instantiateViewControllerWithIdentifier("main_view_scene_id") as! ViewController
        
        if(indCell?.tag == 100){
            let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! custom_cell_no_images
            
            comView.sentLocation = mainView.currentUserLocation
            comView.commentID = gotCell.comment_id
   
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(indexPath) as! custom_cell
            
            comView.sentLocation = mainView.currentUserLocation
            comView.commentID = gotCell.comment_id

        }
        
        
        
        self.presentViewController(comView, animated: true, completion: nil)
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

    
    
    
    
    func loadUserComments(){
        
        
         showLoadingScreen()
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_following_comments")
        //START AJAX
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
    
        let params = ["gfbid":fbid] as Dictionary<String, String>
        
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
                    
                    self.theJSON = json
                    self.writeVoterCache()
                    self.hasLoaded = true
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
    
    func writeVoterCache(){
        
        let finNum = (theJSON["results"]!.count - 1)
        
        if(finNum >= 0){
            
            for index in 0...finNum{
                self.voterCache[index] = theJSON["results"]![index]["has_liked"] as? String
                self.voterValueCache[index] = theJSON["results"]![index]["hearts"] as? String
            }
        }
        
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
        
        
        self.presentViewController(profView, animated: true, completion: nil)
        
        
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

    
    
    func showLikers(sender: UIGestureRecognizer){
        
        print("Presenting Likers, ya heard.")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        let likeView = mainStoryboard.instantiateViewControllerWithIdentifier("comment_likers_id") as! CommentLikersViewController
        
        var authorLabel:AnyObject
        
        authorLabel = sender.view!
        
        
        let indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
        
        let mainView = mainStoryboard.instantiateViewControllerWithIdentifier("main_view_scene_id") as! ViewController
        
        if(indCell?.tag == 100){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell_no_images
            
            likeView.sentLocation = mainView.currentUserLocation
            likeView.commentID = gotCell.comment_id
            
            //profView.comment = gotCell.comment_label.text!
            // profView.userFBID = gotCell.user_id
            
            //profView.userName = gotCell.author_label.text!
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell
            
            likeView.sentLocation = mainView.currentUserLocation
            likeView.commentID = gotCell.comment_id
            //profView.comment = gotCell.comment_label.text!
            //profView.userFBID = gotCell.user_id
            
            //profView.userName = gotCell.author_label.text!
        }
        
        
        self.presentViewController(likeView, animated: true, completion: nil)
        
    }
    
    func showReplies(sender: UIGestureRecognizer){
        
        print("SLKFJS:LDKFJ")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        let repView = mainStoryboard.instantiateViewControllerWithIdentifier("comment_reply_id") as! CommentReplyViewController
        
        var authorLabel:AnyObject
        
        authorLabel = sender.view!
        
        
        let indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0))
        
        let mainView = mainStoryboard.instantiateViewControllerWithIdentifier("main_view_scene_id") as! ViewController
        
        
        if(indCell?.tag == 100){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell_no_images
            
            repView.sentLocation = mainView.currentUserLocation
            repView.commentID = gotCell.comment_id
            //profView.comment = gotCell.comment_label.text!
            // profView.userFBID = gotCell.user_id
            
            //profView.userName = gotCell.author_label.text!
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: authorLabel.tag, inSection: 0)) as! custom_cell
            
            repView.sentLocation = mainView.currentUserLocation
            repView.commentID = gotCell.comment_id
            //profView.comment = gotCell.comment_label.text!
            //profView.userFBID = gotCell.user_id
            
            //profView.userName = gotCell.author_label.text!
        }
        
        
        self.presentViewController(repView, animated: true, completion: nil)
        
    }
    
    
    func shareComment(sender: UIGestureRecognizer){
        
        
        print("DID PRESS SHARE")
        var sharedButton:AnyObject
        //        if(sender.view? == UIImageView()){
        //
        //          sharedButton = sender.view? as UIImageView
        //
        //        }
        //        else{
        //            sharedButton = sender.view? as UILabel
        //        }
        
        sharedButton = sender.view!
        
        
        
        let indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sharedButton.tag, inSection: 0))
        
        if(indCell?.tag == 100){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sharedButton.tag!, inSection: 0)) as! custom_cell_no_images
            
            
            let shareCom = gotCell.comment_label.text as String!
            let shareAuth = gotCell.author_label.text as String!
            
            let giveMess = "'\(shareCom)'  @\(shareAuth) \n\n @SoLoCoHive (http://apple.co/1yTV9Fj)"
            
            
            
            
            let objectsToShare = [giveMess]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
             activityVC.popoverPresentationController?.sourceView = self.view
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop,
                UIActivityTypeAddToReadingList,
                UIActivityTypePostToTencentWeibo,
                UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact,UIActivityTypeMail,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToWeibo,UIActivityTypePrint]
            //
            
            self.presentViewController(activityVC, animated: true, completion: nil)
            
            
            
        }
        if(indCell?.tag == 200){
            let gotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sharedButton.tag!, inSection: 0)) as! custom_cell
            
            
            let shareCom = gotCell.comment_label.text as String!
            let shareAuth = gotCell.author_label.text as String!
            
            let giveMess = "'\(shareCom)'  @\(shareAuth) \n\n @SoLoCoHive (http://apple.co/1yTV9Fj)"
            _ = NSURL(string: "http://apple.co/1yTV9Fj")
            
            let shareImage = gotCell.comImage?.image as UIImage!
            
            let objectsToShare = [giveMess, shareImage]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
             activityVC.popoverPresentationController?.sourceView = self.view
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop,
                UIActivityTypeAddToReadingList,
                UIActivityTypePostToTencentWeibo,
                UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact,UIActivityTypeMail,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToWeibo,UIActivityTypePrint]
            //
            
            self.presentViewController(activityVC, animated: true, completion: nil)
            
            
        }
        
        
        
        
        
        
    }
    
    
    func toggleCommentVote(sender:UIGestureRecognizer){
        //get the attached sender imageview
        
        var heartImage:AnyObject
        
        heartImage = sender.view!
        
        //var heartImage = sender.view? as UIImageView
        //get the main view
        
        let indCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: heartImage.tag, inSection: 0))
        
        if(indCell?.tag == 100){
            
            let cellView = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: heartImage.tag, inSection: 0)) as! custom_cell_no_images
            
            let cID = cellView.comment_id
            
            
            
            
            
            let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_toggle_comment_vote")
            //START AJAX
            let request = NSMutableURLRequest(URL: url!)
            let session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            let params = ["fbid":savedFBID, "comment_id":String(cID)] as Dictionary<String, String>
            
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
                            //change the heart image
                            
                            
                            
                            let testVote = parseJSON["results"]![0]["vote"] as! String!
                            
                            if(testVote == "no"){
                                cellView.heart_icon?.image = UIImage(named: "button_heart_empty.png")
                                
                                //get heart label content as int
                                let curHVal = Int((cellView.heart_label?.text)!)
                                //get the heart label
                                self.voterValueCache[heartImage.tag] = String(curHVal! - 1)
                                cellView.heart_label?.text = String(curHVal! - 1)
                                //self.theJSON["results"]![100]["has_liked"] = "no" as AnyObject!?
                                self.voterCache[heartImage.tag] = "no"
                            }
                            else if(testVote == "yes"){
                                cellView.heart_icon.image = UIImage(named: "button_heart.png")
                                
                                //get heart label content as int
                                let curHVal = Int((cellView.heart_label?.text)!)
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
            
            let cellView = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: heartImage.tag, inSection: 0)) as! custom_cell
            
            let cID = cellView.comment_id
            
            
            
            
            
            let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_toggle_comment_vote")
            //START AJAX
            let request = NSMutableURLRequest(URL: url!)
            let session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            let params = ["fbid":savedFBID, "comment_id":String(cID)] as Dictionary<String, String>
            
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
                            //change the heart image
                            
                            
                            
                            let testVote = parseJSON["results"]![0]["vote"] as! String!
                            
                            if(testVote == "no"){
                                cellView.heart_icon?.image = UIImage(named: "button_heart_empty.png")
                                
                                //get heart label content as int
                                let curHVal = Int((cellView.heart_label?.text)!)
                                //get the heart label
                                self.voterValueCache[heartImage.tag] = String(curHVal! - 1)
                                cellView.heart_label?.text = String(curHVal! - 1)
                                //save the new vote value in our array
                                self.voterCache[heartImage.tag] = "no"
                            }
                            else if(testVote == "yes"){
                                cellView.heart_icon?.image = UIImage(named: "button_heart.png")
                                
                                //get heart label content as int
                                let curHVal = Int((cellView.heart_label?.text)!)
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
        
        view.addSubview(holdView)
        
        
        
        
        
        
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
    
    
    func removeLoadingScreen(){
        //self.loadingScreen.alpha = 0.0
        
        for view in self.view.subviews {
            if(view.tag == 999){
                view.removeFromSuperview()
            }
        }
    }

    

    
    
    
    
    

}
