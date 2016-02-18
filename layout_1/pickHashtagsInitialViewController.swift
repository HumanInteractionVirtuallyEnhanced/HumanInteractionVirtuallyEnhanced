//
//  pickHashtagsInitialViewController.swift
//  layout_1
//
//  Created by Rijul Gupta on 7/19/15.
//  Copyright (c) 2015 Rijul Gupta. All rights reserved.
//
//NEW
//The first real screen you see. Lets you pick "hashtags" as interests. Can return to this screen upon request.


import UIKit



class pickHashtagsInitialViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var exitButton:UIButton!
    @IBOutlet var hashtagScrollHolder:UIScrollView!
    @IBOutlet weak var bottomLayoutConsttraint: NSLayoutConstraint!

    var fakeHashtags = ["MarioKart"]
    var hashtagIDs = [NSString?]()
    var hashtagViews = [UIView?]()
    var hashtagButtons = [UIButton?]()
    var hashtagIdIndex = [String: Int]()
    var hashtagSelectedIndex = [Int : Bool]()
    var widthFiller = 0
    var yPos = 10.0
    var hasStartedClick = false
    var isScrolling = false
    var hasSelectedAHashtag = false
    var commingFrom = "none"
    var theJSON: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: (255.0/255.0), green: (210.0/255.0), blue: (11.0/255.0), alpha: 1.0)
        
//        for i in 0...(self.fakeHashtags.count - 1){
//            self.createHashtag(fakeHashtags[i]);
//            }
        
        //centerHashtags()
        
//        let contentSizeHeight = hashtagButtons.last??.center.y
//        self.hashtagScrollHolder.contentSize = CGSize(width: self.view.frame.width - 100.0, height: contentSizeHeight! + 20.0)
      //  self.hashtagScrollHolder.contentOffset = CGPointMake(self.hashtagScrollHolder.contentOffset.x, 0)
        
        self.hashtagScrollHolder.delegate = self
        
       // self.createHashtag("Loading Hashtags", id: -1);
        
        if(self.commingFrom == "firstView"){
            self.descriptionLabel.text = "Loading..."
            self.exitButton.alpha = 0.0
            self.exitButton.userInteractionEnabled = false
            loadHashtags()
        }
        else{
            self.descriptionLabel.text = "Loading..."
            loadHashtagsForUser()
            //self.descriptionLabel.text = "Check out some new hashtags."
            self.exitButton.addTarget(self, action: "dismissSelf", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        
        //self.testDaMutualFriends()
        
    }
    
    func testDaMutualFriends(){
        //testMutualFriends
//        
//        NSDictionary *params = @{
//            @"fields": @"context.fields(mutual_friends)",
//        };
      //  FBSession.activeSession().accessTokenData.userID
        //FBSession.openActiveSessionWithAllowLoginUI(true)
        print("TOKEN:\(FBSession.activeSession().accessTokenData.accessToken)", terminator: "")
       // println(FBSDKAccessToken.currentAccessToken().tokenString)
        let params = ["fields":"context.fields(mutual_friends)", "access_token":FBSession.activeSession().accessTokenData.accessToken]
        /* make the API call */
        
        //dXNlcl9jb250ZAXh0OgGQgfRrBrfFMQrZC9POld0N9TnUSgeyL0560CZAXJt1p7Y4ZA3vXErNCgWaIZC7QZCh7ZCcSxbT3KjUxjjtfHg00C0jJ7lC9S4zkWsh8ZCLN9FEl1qG1sZD
        //var t = FBSDKGraphRequest(graphPath: "/100000118201399", parameters: params)
        //var t2 = FBSDKGraphRequest(graphPath: "/100000118201399", parameters: params, HTTPMethod: "GET")
        let t2 = FBSDKGraphRequest(graphPath: "/dXNlcl9jb250ZAXh0OgGQgfRrBrfFMQrZC9POld0N9TnUSgeyL0560CZAXJt1p7Y4ZA3vXErNCgWaIZC7QZCh7ZCcSxbT3KjUxjjtfHg00C0jJ7lC9S4zkWsh8ZCLN9FEl1qG1sZD/all_mutual_friends", parameters: params, HTTPMethod: "GET")
        t2.startWithCompletionHandler({(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            print("MUTUAL: \(result)")
            print(error)
        })
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    

    func dismissSelf(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(decelerate == false){
            self.isScrolling = false
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //self.isScrolling = false
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.isScrolling = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
            let scrollViewHeight = scrollView.frame.size.height;
            let scrollContentSizeHeight = scrollView.contentSize.height;
            let scrollOffset = scrollView.contentOffset.y;
        
        _ = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.5 * Double(NSEC_PER_SEC)))
        
        self.isScrolling = true
        
            if (scrollOffset < 0)
            {
                self.isScrolling = true
            }
            else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight)
            {
                self.isScrolling = true
            }
    }
    
    func addHashtagToUser(hashId: String){
        //
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_user_add_hashtag")
        //START AJAX
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
        
        var params = ["gfbid":fbid, "hashId":hashId] as Dictionary<String, String>
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch var error as NSError {
            err = error
            request.HTTPBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var err: NSError? = nil
            
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
       
                    //self.hashtagScrollHolder.reloadInputViews()
                    
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                }
            }
        })
        task.resume()
        //END AJAX

        
    }
    
    
    func makeHashtagunSelected(hashtag:UIButton){
        let daFontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha:0.8)
        hashtag.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha:0.3)
        hashtag.setTitleColor(daFontColor, forState: .Normal)
        hashtag.titleLabel?.font = UIFont(name: "Lato-Light", size: 24.0)
        
        var isOneHashtagTrue = false
        for i in 0...(self.fakeHashtags.count - 1){
            let hashId = self.hashtagIdIndex[self.fakeHashtags[i]]
            if(self.hashtagSelectedIndex[hashId!] == true){
                isOneHashtagTrue = true
            }
        }
        self.hasSelectedAHashtag = isOneHashtagTrue
        if(self.hasSelectedAHashtag == false){
            let testContinue = self.view.viewWithTag(-100) as? UIButton
            if(testContinue == nil){
                
            }
            else{
                
                UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                    
                    testContinue?.frame = CGRect(x:self.view.frame.width/2.0, y: self.view.frame.height, width: 0, height: 0)
                    self.bottomLayoutConsttraint.constant = 0
                    }, completion: { finished in
                        
                       testContinue?.removeFromSuperview()
                        
                        
                })
                
            }
        }
        
        
    }
    
    func makeHashtagSelected(hashtag:UIButton){
        hashtag.backgroundColor = UIColor(red: (255.0/255.0), green: (119.0/255.0), blue: (0.0/255.0), alpha: 1.0);7
    }
    
    func clearAllHashtags(){
        if(self.hashtagButtons.count > 0){
        for i in 0...(self.hashtagButtons.count - 1){
            self.hashtagButtons[i]?.removeFromSuperview()
            
        }
        }
        self.fakeHashtags.removeAll(keepCapacity: false)
        self.hashtagButtons.removeAll(keepCapacity: false)
        self.yPos = 10.0
        
    }
    func createHashtag(title: NSString, id:NSInteger){
        //let width = Int(title.length)*12
        let title = title as String
        if(self.hashtagIdIndex[title] != nil){//if we've already used this hashtag
            return
        }
        
        let f = UIFont(name: "Lato-Light", size: 23.0)
        let width = Int(title.sizeWithAttributes([NSFontAttributeName: f!]).width) + 15
        let height = Int(title.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(24.0)]).height) + 15
        var xpos = 5.0
        let widthSpacing = 12.0
        if(hashtagButtons.count > 0){
            let holder = hashtagButtons.last! as UIButton!
            xpos = Double(holder.frame.origin.x) + Double(holder.frame.width) + widthSpacing;
        }
        
        let testWidthFiller = self.widthFiller + width + Int(widthSpacing)
        //self.widthFiller += width + Int(widthSpacing)
        
        if(Int(testWidthFiller) > Int(self.view.frame.width - 22)){//self.hashtagScrollHolder.frame.width
            var onBut = self.hashtagButtons.count - 1
            print("THE WIDTH:\(self.hashtagScrollHolder.frame.width)")
            print("The WIDTH2:\(self.view.frame.width)")
            print("ON THE BUTTON:\(onBut)")
            if(onBut > (self.fakeHashtags.count - 1)){
                onBut = self.fakeHashtags.count - 1
            }
            for i in onBut...(self.fakeHashtags.count - 1){//for the rest of the hashtags left to go
                if(self.hashtagIdIndex[self.fakeHashtags[i]] == nil){//if these hashtags haven't been used for
                    let testWidth = Int(self.fakeHashtags[i].sizeWithAttributes([NSFontAttributeName: f!]).width) + 15
                    let testFiller2 = self.widthFiller + testWidth + Int(widthSpacing)
                    if(Int(testFiller2) <= Int(self.view.frame.width - 22)){//hashtagScrollHolder
                        let hashId = self.theJSON["results"]![i]["id"] as! NSString
                        let hashId2 = hashId.integerValue
                        self.createHashtag(self.fakeHashtags[i], id: hashId2)
                    }
                }
            }

            self.widthFiller = width + Int(widthSpacing)
            self.yPos += Double(height) + 12.0
            xpos = 5.0
        }
        else{
            self.widthFiller = testWidthFiller
        }
 
        let newButton = UIButton(frame: CGRect(x: Int(xpos), y: Int(yPos), width: width, height: height))
        newButton.backgroundColor = UIColor(red: (255.0/255.0), green: (165.0/255.0), blue: (0.0/255.0), alpha: 1.0)
        
        newButton.setTitle(title as String, forState: UIControlState.Normal)
        newButton.titleLabel?.font = UIFont(name: "Lato-Light", size: 24.0)

        self.hashtagScrollHolder.addSubview(newButton)
        self.hashtagButtons.append(newButton)
        newButton.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchDown)
        newButton.addTarget(self, action: "unpressed:", forControlEvents: UIControlEvents.TouchDragExit)
        newButton.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchDragEnter)
        newButton.addTarget(self, action: "selected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.hashtagIdIndex[title] = id
        self.hashtagSelectedIndex[id] = false
        

    }
    
func pressed(dabut: UIButton){
        
        if(self.isScrolling == false){
            
                hasStartedClick = false
            let time1 = 0.1
            let startingWidth = dabut.frame.width
            let startingHeight = dabut.frame.height
            let startingX = dabut.frame.origin.x
            let startingY = dabut.frame.origin.y
            let wChanger = CGFloat(5.0)
            let hChanger = CGFloat(10.0)
            _ = CGFloat(3.0)
            _ = CGFloat(6.0)
            
            UIView.animateWithDuration(time1, delay: 0.0, options: .CurveEaseOut, animations: {
                
                dabut.frame = CGRect(x: startingX - wChanger/2.0, y: startingY - hChanger/2.0, width: startingWidth + wChanger, height: startingHeight + hChanger)
                //dabut.titleLabel!.transform = CGAffineTransformScale(dabut.titleLabel!.transform, 1.1, 1.1);
                //dabut.titleLabel!.center = CGPoint(x: dabut.titleLabel!.center.x + wChanger, y: dabut.titleLabel!.center.y + hChanger);
                dabut.titleLabel?.font = UIFont(name: "Lato-Regular", size: 26.0)
                
                }, completion: { finished in
                    
            })
            
            }
            
        
    }
 
func unpressed(dabut: UIButton){
        
        
        
        let time1 = 0.1
        
        
        let wChanger = CGFloat(5.0)
        let hChanger = CGFloat(10.0)
        let wChanger2 = CGFloat(3.0)
        let hChanger2 = CGFloat(6.0)
        let startingWidth = dabut.frame.width - wChanger
        let startingHeight = dabut.frame.height - hChanger
        let startingX = dabut.frame.origin.x + wChanger/2.0
        let startingY = dabut.frame.origin.y + hChanger/2.0
        
        if(self.isScrolling == false){
        hasStartedClick = false
            UIView.animateWithDuration(time1, delay: time1, options: .CurveEaseOut, animations: {
                
                dabut.frame = CGRect(x: startingX + (wChanger + wChanger2)/2.0, y: startingY + (hChanger + hChanger2)/2.0, width: startingWidth - wChanger - wChanger2, height: startingHeight - hChanger - hChanger2)
                dabut.titleLabel?.font = UIFont(name: "Lato-Light", size: 20.0)
                
                }, completion: { finished in
                    
            })
            UIView.animateWithDuration(time1, delay: time1*2, options: .CurveEaseOut, animations: {
                
                dabut.frame = CGRect(x: startingX, y: startingY, width: startingWidth, height: startingHeight)
                dabut.titleLabel?.font = UIFont(name: "Lato-Light", size: 24.0)
                
                }, completion: { finished in
                    
            })
            
        }
    }
    
    func selected(dabut: UIButton){
        
        let time1 = 0.1
        
        
        let wChanger = CGFloat(5.0)
        let hChanger = CGFloat(10.0)
        let wChanger2 = CGFloat(3.0)
        let hChanger2 = CGFloat(6.0)
        let startingWidth = dabut.frame.width - wChanger
        let startingHeight = dabut.frame.height - hChanger
        let startingX = dabut.frame.origin.x + wChanger/2.0
        let startingY = dabut.frame.origin.y + hChanger/2.0
        if(self.isScrolling == false){
            if(hasStartedClick == false){
                hasStartedClick = true
                
                UIView.animateWithDuration(time1, delay: time1, options: .CurveEaseOut, animations: {
                    
                    dabut.frame = CGRect(x: startingX + (wChanger + wChanger2)/2.0, y: startingY + (hChanger + hChanger2)/2.0, width: startingWidth - wChanger - wChanger2, height: startingHeight - hChanger - hChanger2)
                    dabut.titleLabel?.font = UIFont(name: "Lato-Regular", size: 20.0)
                    
                    }, completion: { finished in
                        
                })
                UIView.animateWithDuration(time1, delay: time1*2, options: .CurveEaseOut, animations: {
                    
                    dabut.frame = CGRect(x: startingX, y: startingY, width: startingWidth, height: startingHeight)
                    dabut.titleLabel?.font = UIFont(name: "Lato-Regular", size: 24.0)
                    
                    }, completion: { finished in
                        
                })
                
                hasStartedClick = false
                self.selectedCode(dabut)
            }
            
                
        }
    }
    
    func selectedCode(dabut: UIButton){
        
        if(self.hasSelectedAHashtag == false){
            for i in 0...(self.hashtagButtons.count - 1){
                self.makeHashtagunSelected(self.hashtagButtons[i]!)
            }
            self.showNextScreenButton()
        }
        
        dabut.titleLabel?.font = UIFont(name: "Lato-Regular", size: 24.0)
        let hashtagID = self.hashtagIdIndex[dabut.titleLabel!.text!]
        let isSelected = self.hashtagSelectedIndex[hashtagID!]
        print("Hashtag is false:\(isSelected)")
        if(isSelected == false){
            self.hashtagSelectedIndex[hashtagID!] = true
            self.makeHashtagSelected(dabut)
            let hashId = String(hashtagID!)
            self.addHashtagToUser(hashId)
            hasSelectedAHashtag = true
        }
        else{
            self.hashtagSelectedIndex[hashtagID!] = false
            self.makeHashtagunSelected(dabut)
        }
        
        
        
    }
    func centerHashtags(){
        var rowHolder = [UIButton?]()
        var previousY = -1
        for i in 0...(hashtagButtons.count - 1){
            if(i == 0){
                //rowHolder.append(hashtagViews[i])
                let newY = hashtagButtons[i]?.frame.origin.y
                //rowHolder.arrayByAddingObject(hashtagViews[i]!)
                rowHolder.append(hashtagButtons[i]!)
                previousY = Int(newY!)
                
            }
            else{
                let newY = hashtagButtons[i]?.frame.origin.y
                if(previousY == Int(newY!)){
                    //rowHolder.arrayByAddingObject(hashtagViews[i]!)
                    rowHolder.append(hashtagButtons[i]!)
                    
                }
                else{
                    //let vW = self.hashtagScrollHolder.frame.width
                    let vW = self.view.frame.width - 32.0
                    let sX = rowHolder.last?!.frame.origin.x
                    let sW = rowHolder.last?!.frame.width
                    let changeX = (vW - sX! - sW!)/2.0
                    
                    for j in 0...(rowHolder.count - 1){
                        rowHolder[j]!.center = CGPoint(x:rowHolder[j]!.center.x + changeX, y:rowHolder[j]!.center.y)
                        
                    }
                    
                    rowHolder.removeAll(keepCapacity: false)
                    rowHolder.append(hashtagButtons[i]!)
                    let newY = hashtagButtons[i]?.frame.origin.y
                    previousY = Int(newY!)
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    
    func loadHashtags(){
        
        
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_hashtags")
        //START AJAX
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id") as String!
        
        var params = ["gfbid":fbid, "loc":"locatoin"] as Dictionary<String, String>
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch var error as NSError {
            err = error
            request.HTTPBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var err: NSError? = nil
            
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
                
                dispatch_async(dispatch_get_main_queue(),{
                self.showMessageWithError("Couldn't get hashtags", callback: "loadHashtags")
                })
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                
                
                
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    dispatch_async(dispatch_get_main_queue(),{

                    self.descriptionLabel.text = "What do you like talking about?"
                    self.clearAllHashtags()
                    self.theJSON = json
                    for j in 0...(self.theJSON["results"]!.count - 1){
                        self.fakeHashtags.append(self.theJSON["results"]![j]["body"] as! String)
                    }
                        self.hashtagScrollHolder.sizeToFit()
                    for i in 0...(self.fakeHashtags.count - 1){
                        let daID = self.theJSON["results"]![i]["id"] as! NSString
                        let daID2 = daID.integerValue
                        self.createHashtag(self.fakeHashtags[i], id: daID2);
                    }
                        
                        let contentSizeHeight = self.hashtagButtons.last??.center.y
                        self.hashtagScrollHolder.contentSize = CGSize(width: self.view.frame.width - 100.0, height: contentSizeHeight! + 40.0)
                        self.hashtagScrollHolder.setNeedsDisplay()
                        self.hashtagScrollHolder.setNeedsLayout()
                        
                    })
                    //self.hashtagScrollHolder.reloadInputViews()
                    
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                }
            }
        })
      
        task.resume()
        //END AJAX
        
    }
    
    func loadHashtagsForUser(){
        
        let url = NSURL(string: "http://groopie.pythonanywhere.com/mobile_get_hashtags_for_user")
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
        } catch var error as NSError {
            err = error
            request.HTTPBody = nil
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
                
                self.showMessageWithError("Couldn't get hashtags", callback: "loadHashtagsForUser")
                
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                
                
                
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        // self.removeLoadingScreen()
                        
                        self.descriptionLabel.text = "Check out some new hashtags."
                        self.clearAllHashtags()
                        self.theJSON = json
                        for j in 0...(self.theJSON["results"]!.count - 1){
                            self.fakeHashtags.append(self.theJSON["results"]![j]["body"] as! String)
                        }
                        for i in 0...(self.fakeHashtags.count - 1){
                            let daID = self.theJSON["results"]![i]["id"] as! NSString
                            let daID2 = daID.integerValue
                            self.createHashtag(self.fakeHashtags[i], id: daID2);
                        }
                        
                        let contentSizeHeight = self.hashtagButtons.last??.center.y
                        self.hashtagScrollHolder.contentSize = CGSize(width: self.view.frame.width - 100.0, height: contentSizeHeight! + 40.0)
                        self.hashtagScrollHolder.setNeedsDisplay()
                        self.hashtagScrollHolder.setNeedsLayout()
                        
                    })
                    //self.hashtagScrollHolder.reloadInputViews()
                    
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                }
            }
        })
        task.resume()
        //END AJAX
        
    }
    func showNextScreenButton(){
        let nextButton = UIButton(frame: CGRect(x:0, y: self.view.frame.height, width: self.view.frame.width, height: 40))
        nextButton.tag = -100;
        nextButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        
        nextButton.setTitle("Continue", forState: UIControlState.Normal)
        nextButton.titleLabel?.font = UIFont(name: "Lato-Light", size: 24.0)
        
        self.view.addSubview(nextButton)
        
        let time1 = 0.1

        _ = NSLayoutConstraint(item: self.hashtagScrollHolder, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: nextButton, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        UIView.animateWithDuration(time1, delay: 0.0, options: .CurveEaseOut, animations: {
            
            nextButton.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
            self.bottomLayoutConsttraint.constant = nextButton.frame.height*1.2;
            }, completion: { finished in
                
                nextButton.addTarget(self, action: "continueButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                
                
        })
        
    }
    
    

    func continueButtonPressed(dabut: UIButton){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("1", forKey: "numHashtags")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let writeView = mainStoryboard.instantiateViewControllerWithIdentifier("write_comment_scene_id") as! WriteCommentViewController
        let peopleView = mainStoryboard.instantiateViewControllerWithIdentifier("main_tab_bar_scene_id") as! UITabBarController
        
        writeView.commingFrom = "pickHashtags"
        _ = mainStoryboard.instantiateViewControllerWithIdentifier("pick_hashtags_id") as! pickHashtagsInitialViewController
        
        _ = self.presentingViewController
        let oldSelf = self
        
        
         let root = self.view.window?.rootViewController
        self.view.window?.makeKeyAndVisible()
        self.view.window?.makeKeyWindow()
       // self.dismissViewControllerAnimated(false, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        root?.presentViewController(peopleView, animated: true, completion: {
           // oldSelf.dismissViewControllerAnimated(true, completion: nil)
        })
        
//        self.presentViewController(writeView, animated: true, completion: {
//            dispatch_after(0, dispatch_get_main_queue(), {
//                oldSelf.removeFromParentViewController()
//            })
//        })

        
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        
    }
     override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    
    func showMessageWithError(message: NSString, callback:NSString)
    {
        
        
        let alert = UIAlertController(title: "Error", message:message as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reload", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                NSThread.detachNewThreadSelector(Selector(callback as String), toTarget:self, withObject: nil)
                print("default")
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
//        alert.addAction(UIAlertAction(title: "Shit!", style: .Default, handler: { action in
//            switch action.style{
//            case .Default:
//                println("default")
//                
//            case .Cancel:
//                println("cancel")
//                
//            case .Destructive:
//                println("destructive")
//            }
//        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
        
}

