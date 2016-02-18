//
//  FBLoginViewController.swift
//  layout_1
//
//  Created by Rijul Gupta on 3/11/15.
//  Copyright (c) 2015 Rijul Gupta. All rights reserved.
//NEW
//The login in screen - allows you to login with facebook.

import UIKit

let fbIDConstant = "saved_fb_id"


class FBLoginViewController: UIViewController, FBLoginViewDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDataSource {
    
    @IBOutlet var fbLoginView : FBLoginView!
    @IBOutlet var tcLabel: UILabel!
    
    let pageTitles = ["Look Up", "Chat Up", "Open Up"]
    let pageImages = ["IntroImage1.jpg", "IntroImage2.jpg", "IntroImage3.jpg"]
    let pageDesc = ["Check out what people around you are talking about", "Share your thoughts and opinions with others in your vicinity", "Reach out to the people whose posts spark your interest, find the people who love what you love, skip the small talk and start connecting"]
    var pageIndex: Int?
    var pageViewController: UIPageViewController!
    @IBOutlet var pgDots: UIPageControl!
    var ffList = ""
    var theUserId = ""
    var onfriend = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        //main_view_scene_id
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Terms and Conditions", attributes: underlineAttribute)
        tcLabel.attributedText = underlineAttributedString
        
        
        
        
        let TCTap = UITapGestureRecognizer(target: self, action:Selector("didTapTandC:"))
        // 4
        TCTap.delegate = self
        tcLabel.userInteractionEnabled = true
        tcLabel.addGestureRecognizer(TCTap)
        
        //    self.reset()
        
      //  self.testDaMutualFriends()
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        var startVC = self.viewControllerAtIndex(0) as ContentViewController
        var viewControllers = NSArray(object: startVC)
       // let viewControllers = [startVC]
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        let h = UIApplication.sharedApplication().statusBarFrame.size.height
        self.pageViewController.view.frame = CGRectMake(0, h, self.view.frame.width, self.view.frame.size.height + 37 - h)
        //self.pageViewController.view.frame = self.view.frame
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.view.sendSubviewToBack(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        self.view.bringSubviewToFront(self.pgDots)
        
    }
    
//    func testDaMutualFriends(){
//        //testMutualFriends
//        
//        let url = NSURL(string: "http://groopie.pythonanywhere.com/testMutualFriends")
//        var request = NSMutableURLRequest(URL: url!)
//        var session = NSURLSession.sharedSession()
//        request.HTTPMethod = "POST"
//        
//        var params = ["ffList":self.ffList, "fbid":self.theUserId] as Dictionary<String, String>
//        
//        var err: NSError?
//        do {
//            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
//        } catch var error as NSError {
//            err = error
//            request.HTTPBody = nil
//        } catch {
//                
//        }
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            print("Response: \(response)")
//            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("Body: \(strData)")
//            var err: NSError?
//            
//            var json: NSDictionary?
//            do{
//                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
//            } catch let error as NSError{
//                err = error
//            } catch {
//                
//            }
//            
//            
//            
//            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
//            if(err != nil) {
//                print(err!.localizedDescription)
//                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print("Error could not parse JSON: '\(jsonStr)'")
//            }
//            else {
//                
//                if let parseJSON = json {
//                    
//                }
//                else {
//                    
//                }
//            }
//        })
//        task.resume()
//        //END AJAX
//    
//
//    
//    }
//    func get_mutual_friends(){
//        //        NSDictionary *params = @{
//        //            @"fields": @"context.fields(mutual_friends)",
//        //        };
//        var params: Dictionary<String, AnyObject> = Dictionary()
//        params["fields"] = "context.fields(mutual_friends)"
//        
//        
//        FBRequestConnection.startWithGraphPath("/100000118201399", parameters: params, HTTPMethod: "GET", completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
//            print("MUTUAL: \(result)")
//        })
//        
//        //        var params: Dictionary<String, AnyObject> = Dictionary()
//        //        params["fields"] = "context.fields(mutual_friends)"
//        //
//        //        FBRequestConnection.startWithGraphPath("me", parameters: params, HTTPMethod: "GET", completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
//        //            println("MUTUAL: \(result)")
//        //        })
//        
//        //        var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
//        //        var friendList = ""
//        //        friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
//        //            var resultdict = result as! NSDictionary
//        //            println("Result Dict: \(resultdict)")
//        //            var data : NSArray = resultdict.objectForKey("data") as! NSArray
//        //        }
//        //        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//        //            initWithGraphPath:@"/{user-id}"
//        //        parameters:params
//        //        HTTPMethod:@"GET"];
//        //        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//        //        id result,
//        //        NSError *error) {
//        //        // Handle the result
//        //        }];
//    }
//    
    func reset() {
        /* Getting the page View controller */
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController")as! UIPageViewController
        self.pageViewController.dataSource = self
        
        
        _ = self.viewControllerAtIndex(0)
        // self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 30)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        
        var index = vc.pageIndex as Int
        self.pgDots.currentPage = index
        if(index == NSNotFound){
            return nil
        }
        
        index++
        
        if(index == self.pageTitles.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        
        var index = vc.pageIndex as Int
        self.pgDots.currentPage = index
        
        if(index <= 0 || index == NSNotFound){
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func viewControllerAtIndex(index : Int) -> ContentViewController {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return ContentViewController()
            //return nil
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        vc.imageFile = self.pageImages[index] as String
        vc.titleText = self.pageTitles[index] as String
        vc.descText = self.pageDesc[index] as String
        vc.pageIndex = index
        return vc
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func didTapTandC(sender: UIGestureRecognizer){
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tcView = mainStoryboard.instantiateViewControllerWithIdentifier("terms_and_cond_id") as! TermsAndConditionsViewController
        
        
        // self.dismissViewControllerAnimated(true, completion: nil)
        
        self.presentViewController(tcView, animated: false, completion: nil)
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
        testUserLogin()
        let defaults = NSUserDefaults.standardUserDefaults()
        let fbid = defaults.stringForKey("saved_fb_id")
        if(fbid != nil){
            
            if(fbid == "none"){
                
            }
            else{
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
                let fbView = mainStoryboard.instantiateViewControllerWithIdentifier("main_tab_bar_scene_id") as! UITabBarController
                
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                self.presentViewController(fbView, animated: false, completion: nil)
            }
            
            
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        print("User Logged In")
        print("This is where you perform a segue.")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("test_view_switcher") as UIViewController
        _ = mainStoryboard.instantiateViewControllerWithIdentifier("main_tab_bar_scene_id") as! UITabBarController
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //self.presentViewController(fbView, animated: false, completion: nil)
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
        print("User Name: \(user.name)")
        print("Usr Edu: \(user.birthday)")
        print(user)
        let userID = user.objectForKey("id") as! String
        print("user id: \(userID)")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userID, forKey: "saved_fb_id")
        self.theUserId = userID
     //   getMyFriends()
        // self.get_mutual_friends()
        
        //        FBSession.openActiveSessionWithReadPermissions(self.fbLoginView.readPermissions, allowLoginUI: true, completionHandler: {(session, state, error) -> Void in
        //            self.sessionStateChanged(session, state: state, error: error)
        //        })
        //   self.getFBFriends("me/friends?")
    }
    
    func sessionStateChanged(session:FBSession, state:FBSessionState, error:NSError?) {
        
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        print("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        print("Error: \(handleError.localizedDescription)")
    }
    
    
//    func getFBFriends(url: String) {
//        
//        //var params: Dictionary<String, AnyObject> = Dictionary()
//        // params["fields"] = "context.fields(mutual_friends)"
//        
//        FBRequestConnection.startWithGraphPath(url, completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
//            print("MUTUAL: \(result)")
//            if(error == nil){
//                // [self parseFBResult:result];
//                
//                let paging = result["paging"] as! NSDictionary
//                //NSDictionary *paging = [result objectForKey:@"paging"];
//                //  NSString *next = [paging objectForKey:@"next"];
//                let next = paging["next"] as! NSString
//                
//                // skip the beginning of the url https://graph.facebook.com/
//                // there's probably a more elegant way of doing this
//                print("next:\(next.substringFromIndex(27))");
//                
//                if (!FBSession.activeSession().isOpen) {
//                    // if the session is closed, then we open it here, and establish a handler for state changes
//                    
//                    FBSession.openActiveSessionWithReadPermissions(self.fbLoginView.readPermissions, allowLoginUI: true, completionHandler:  {(session: FBSession!, state: FBSessionState, error: NSError!) -> Void in
//                        
//                        if((error) != nil){
//                            self.getFBFriends(next.substringFromIndex(27))
//                        }
//                        else{
//                            print("THE SESSION ERROR:\(error)")
//                        }
//                        }
//                    )
//                    
//                }
//                else{
//                    
//                    self.onfriend = self.onfriend + 25
//                    print("BLAHHHHH: me/friends?&limit=25&offset=\(self.onfriend)")
//                    self.getFBFriends("me/friends?&limit=25&offset=\(self.onfriend)")
//                    // self.getFBFriends(next.substringFromIndex(27))
//                }
//                
//                // [self getFBFriends:next.substringFromIndex(27)];
//            }
//            else{
//                print("ERROR ERROR\(error)")
//            }
//        })
//        
//        //        FBRequestConnection.startWithGraphPath(url, HTTPMethod: "GET", completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
//        //            println("MUTUAL: \(result)")
//        //        })
//        
//        //    [FBRequestConnection startWithGraphPath:url
//        //    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        //    if (!error) {
//        //    [self parseFBResult:result];
//        //
//        //    NSDictionary *paging = [result objectForKey:@"paging"];
//        //    NSString *next = [paging objectForKey:@"next"];
//        //
//        //    // skip the beginning of the url https://graph.facebook.com/
//        //    // there's probably a more elegant way of doing this
//        //
//        //    NSLog(@"next:%@", [next substringFromIndex:27]);
//        //
//        //    [self getFBFriends:[next substringFromIndex:27]];
//        //
//        //    } else {
//        //    NSLog(@"An error occurred getting friends: %@", [error localizedDescription]);
//        //    }
//        //    }];
//        //
//    }
//    
//    
//    //parse user friends list into readable string
//    func getMyFriends(){
//        
//        let friendsRequest : FBRequest = FBRequest.requestForMyFriends()
//        var friendList = ""
//        friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
//            let resultdict = result as! NSDictionary
//            print("Result Dict: \(resultdict)")
//            let data : NSArray = resultdict.objectForKey("data") as! NSArray
//            
//            for i in 0...data.count {
//                let valueDict : NSDictionary = data[i] as! NSDictionary
//                let id = valueDict.objectForKey("id") as! String
//                print("the id value is \(id)")
//                friendList = friendList + "\(id), "
//                self.ffList = self.ffList + "\(id), "
//                
//                
//                if i == data.count - 1{
//                    self.sendFinalList()
//                }
//                
//            }
//            
//            //  var friends = resultdict.objectForKey("data") as! NSArray
//            //println("Found \(friends.count) friends")
//            
//            
//        }
//        
//        print("FINAL FRIENDS LIST:\(friendList)")
//    }
//    
//    //send the friend list to our servers
//    //we use the friends list in determining which posts to show the user
//    //we also use it to show mutual friends between users
//    //the friends list is vital to our app and we need facebook login
//    func sendFinalList(){
//        print("FINAL FRIENDS FINAL LIST:\(ffList)")
//        dispatch_async(dispatch_get_main_queue(), {
//            //START AJAX
//            //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
//            let url = NSURL(string: "http://groopie.pythonanywhere.com/recieve_fbfriends_list")
//            var request = NSMutableURLRequest(URL: url!)
//            var session = NSURLSession.sharedSession()
//            request.HTTPMethod = "POST"
//            
//            var params = ["ffList":self.ffList, "fbid":self.theUserId] as Dictionary<String, String>
//            
//            var err: NSError?
//            do {
//                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
//            } catch var error as NSError {
//                err = error
//                request.HTTPBody = nil
//            } catch {
//                fatalError()
//            }
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            
//            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//                print("Response: \(response)")
//                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print("Body: \(strData)")
//                var err: NSError? = nil
//                var json: NSDictionary? = nil
//                do{
//                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
//                } catch let error as NSError{
//                    err = error
//                } catch {
//                    
//                }
//                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
//                if(err != nil) {
//                    print(err!.localizedDescription)
//                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                    print("Error could not parse JSON: '\(jsonStr)'")
//                }
//                else {
//                    
//                    if let parseJSON = json {
//                        
//                    }
//                    else {
//                        
//                    }
//                }
//            })
//            task.resume()
//            //END AJAX
//        })
//        
//        
//    }
//    
    func testUserLogin(){
        
        
        //        //START AJAX
        //        //let url = NSURL(string: "http://www.groopie.co/mobile_get2_top_comments")
        //        let url = NSURL(string: "http://groopie.pythonanywhere.com/login")
        //        var request = NSMutableURLRequest(URL: url!)
        //        var session = NSURLSession.sharedSession()
        //        request.HTTPMethod = "GET"
        //
        //        var params = ["username":"jameson", "password":"password"] as Dictionary<String, String>
        //
        //        var err: NSError?
        //        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //
        //        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        //            println("Response: \(response)")
        //            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        //            println("Body: \(strData)")
        //            var err: NSError?
        //            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        //            
        //            
        //            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
        //            if(err != nil) {
        //                println(err!.localizedDescription)
        //                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
        //                println("Error could not parse JSON: '\(jsonStr)'")
        //            }
        //            else {
        //
        //                if let parseJSON = json {
        //
        //                }
        //                else {
        //
        //                }
        //            }
        //        })
        //        task.resume()
        //        //END AJAX
        
    }
    
}