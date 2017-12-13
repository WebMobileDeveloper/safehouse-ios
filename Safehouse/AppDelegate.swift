//
//  AppDelegate.swift
//  Safehouse
//
//  Created by Delicious on 9/18/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import CoreData

import CoreLocation
import Alamofire
import FirebaseCore
import FirebaseAuth
import FBSDKLoginKit
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var lastLocation:CLLocation = CLLocation()
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        debugPrint("###> 1 AppDelegate DidFinishLaunchingWithOptions")
/* MARK:-- battery notification register ---*/
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange(notification:)), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryLevelDidChange(notification:)), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
/* --   end of battery notification register end  ---*/
        
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        self.initializeFCM(application)
        let token = InstanceID.instanceID().token()
        debugPrint("GCM TOKEN = \(String(describing: token))")
        
        setupLocationManager()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebook =  FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return facebook
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint("###> 1.2 AppDelegate DidEnterBackground")
        createRegion(location: lastLocation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        Messaging.messaging().shouldEstablishDirectChannel = true
        debugPrint("###> 1.3 AppDelegate DidBecomeActive")
    }
    
    
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("###> 1.3 AppDelegate applicationWillTerminate")
        // createRegion(location: lastLocation)
        self.saveContext()
    }
    
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Safehouse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    //MARK:- -  Modal Methods
    func showCheckInModal(){
        if let currentViewController = self.window?.rootViewController {
            let mVC = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "checkInFromChildViewController") as! checkInFromChildViewController
            mVC.modalPresentationStyle = .overCurrentContext
            currentViewController.present(mVC, animated: true, completion: nil)
        }
        
    }
    func showEmergencyInModal(){
        if let currentViewController = self.window?.rootViewController {
            let mVC = UIStoryboard(name: "Actions", bundle: nil).instantiateViewController(withIdentifier: "emergencyFromChildViewController") as! emergencyFromChildViewController
            mVC.modalPresentationStyle = .overCurrentContext
            currentViewController.present(mVC, animated: true, completion: nil)
        }
    }
    
    
// MARK:- Location magager functions   &&&&&&&&&&&&&&&&&&
    func setupLocationManager(){
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    func createRegion(location:CLLocation?) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
            let regionRadius = 200.0
            let region = CLCircularRegion(center: CLLocationCoordinate2D( latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: "aabb")
            region.notifyOnExit = true
            region.notifyOnEntry = true
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startMonitoring(for: region)
        }
        else {
            print("--------System can't track regions")
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("-------Entered Region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("-------Exited Region")
        locationManager.stopMonitoring(for: region)
        /*  MARK:-  REST API access
         */
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil{
                    self.locationManager.startUpdatingLocation()
                    return
                }
                let headers:HTTPHeaders = ["Authorization" : "Bearer \(idToken!)", "Accept": "application/json"]
                let parameters = ["user_id": currentUser.uid,
                                  "location": [
                                    "lat":self.lastLocation.coordinate.latitude,
                                    "long":self.lastLocation.coordinate.longitude
                    ]] as [String : Any]
                let url = "https://us-central1-safehouse-488e5.cloudfunctions.net/location"
                
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response(completionHandler: { (response) in
                    self.locationManager.startUpdatingLocation()
                })
            })
        }else{
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        lastLocation = location!
        self.createRegion(location: lastLocation)
    }
    //-------------&&&&&&&&&&&&&&&&&&
    //  Battery Notification functions &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    var batteryState: UIDeviceBatteryState {
        return UIDevice.current.batteryState
    }
    func batteryStateDidChange(notification: NSNotification){
        // The stage did change: plugged, unplugged, full charge...
        switch batteryState {
        case .unplugged:
            print("-----unplugged")
        case .unknown:
            print("-----not charging")
        case .charging:
            print("-----charging")
        case .full:
            print("-----full")
        }
    }
    
    func batteryLevelDidChange(notification: NSNotification){
        // The battery's level did change (98%, 99%, ...)
        print("-----Request Sent")
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil{
                    return
                }
                let headers:HTTPHeaders = [
                    "Authorization" : "Bearer \(idToken!)" ,
                    "Accept": "application/json"
                ]
                let parameters = [
                    "user_id": currentUser.uid,
                    "location": [
                        "lat":self.lastLocation.coordinate.latitude,
                        "long":self.lastLocation.coordinate.longitude
                    ],
                    "type":"battery_perc_change",
                    "battery_pec": self.batteryLevel
                    ] as [String : Any]
                print("######### batteryLevel:   ", self.batteryLevel)
                let url = "https://us-central1-safehouse-488e5.cloudfunctions.net/event"
                Alamofire.request(url,
                                  method: HTTPMethod.post,
                                  parameters: parameters,
                                  encoding: JSONEncoding.default,
                                  headers: headers)
                    .response(completionHandler: { (response) in
                    })
            })
        }
    }
    
    func getLocationHistory(completionHandler:@escaping ()->Void = {}){
        user.locationHistories.removeAll()
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil{
                    return
                }
                let headers:HTTPHeaders = [
                    "Authorization" : "Bearer \(idToken!)" ,
                    "Accept": "application/json"
                ]
                let url = "https://us-central1-safehouse-488e5.cloudfunctions.net/locations?child_id=\(user.child_id))"
                Alamofire.request(url,
                                  method: HTTPMethod.get,
                                  encoding: JSONEncoding.default,
                                  headers: headers)
                    .responseJSON(completionHandler: { (responseData) in
                        
                        if responseData.result.isSuccess {
                            if((responseData.result.value) != nil) {
                                let swiftyJsonVar = JSON(responseData.result.value!)
                                for dayData in swiftyJsonVar.array!{
                                    var newDayData:[historyClass] = []
                                    for templocations in dayData["locations"].arrayObject! {
                                        let newLoc:historyClass = historyClass()
                                        let locations = templocations as! [String:AnyObject]
                                        newLoc.start_timestamp = locations["start_timestamp"] as? TimeInterval ?? 0
                                        newLoc.end_timestamp = locations["end_timestamp"] as? TimeInterval ?? 0
                                        newLoc.direction_angle = locations["direction_angle"] as? Float ?? 0
                                        let loc = locations["location"] as! [String:Double]
                                        newLoc.location["lat"] = loc["lat"]
                                        newLoc.location["long"] = loc["long"]
                                        newDayData.append(newLoc)
                                    }
                                    let date = dayData["date"].stringValue
                                    user.locationHistories[date] = newDayData
                                }
                            }
                        }
                        if responseData.result.isFailure {
                            let error : NSError = responseData.result.error! as NSError
                            print("#####error:", error)
                        }
                        
                        completionHandler()
                    })
            })
        }
    }
    func checkInSend(child_id:String, completionHandler:@escaping (_ result:Bool)->Void = {_ in }){
        if let currentUser = Auth.auth().currentUser{
            currentUser.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil{
                    completionHandler(false)
                    return
                }
                let headers:HTTPHeaders = [
                    "Authorization" : "Bearer \(idToken!)" ,
                    "Accept": "application/json"
                ]
                let parameters = [
                    "parent_id": currentUser.uid,
                    "child_id": child_id
                    ] as [String : Any]
                let url = "https://us-central1-safehouse-488e5.cloudfunctions.net/event"
                Alamofire.request(url,
                                  method: HTTPMethod.post,
                                  parameters: parameters,
                                  encoding: JSONEncoding.default,
                                  headers: headers)
                    .response(completionHandler: { (response) in
                        if response.error != nil {
                            completionHandler(false)
                        }else{
                            completionHandler(true)
                        }
                    })
            })
        }
    }
    
}
// MARK:- extension AppDelegate: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate{
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        debugPrint("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    func application(received remoteMessage: MessagingRemoteMessage)
    {
        debugPrint("remoteMessage:\(remoteMessage.appData)")
    }
    
    func initializeFCM(_ application: UIApplication)
    {
        print("initializeFCM")
        //-------------------------------------------------------------------------//
        if #available(iOS 10.0, *) // enable new way for notifications on iOS 10
        {
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.badge, .alert , .sound]) { (accepted, error) in
                if !accepted
                {
                    print("Notification access denied.")
                }
                else
                {
                    print("Notification access accepted.")
                    center.delegate = self
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications();
                    }
                }
            }
        }
        else
        {
            let type: UIUserNotificationType = [.badge, .alert, .sound];
            let setting = UIUserNotificationSettings(types: type, categories: nil);
            UIApplication.shared.registerUserNotificationSettings(setting);
            UIApplication.shared.registerForRemoteNotifications();
        }
        
       
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton),
        //                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
    }
    //-------------------------------------------------------------------------//
    // enable new way for notifications on iOS 10
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        debugPrint("didRegister notificationSettings")
        if (notificationSettings.types == .alert || notificationSettings.types == .badge || notificationSettings.types == .sound)
        {
            application.registerForRemoteNotifications()
        }
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        //        //Handle the notification ON APP
        //        debugPrint("*** willPresent notification")
        //        debugPrint("*** notification: \(notification)")
        completionHandler( [.alert, .badge, .sound])
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        //        //Handle the notification ON BACKGROUND
        //        debugPrint("*** didReceive response Notification ")
        //        debugPrint("*** response: \(response)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        debugPrint("didRegisterForRemoteNotificationsWithDeviceToken: NSDATA")
        
        //let token = String(format: "%@", deviceToken as CVarArg)
        //debugPrint("*** deviceToken: \(token)")
        Messaging.messaging().apnsToken = deviceToken as Data
        debugPrint("Firebase Token:",InstanceID.instanceID().token() as Any)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        debugPrint("didRegisterForRemoteNotificationsWithDeviceToken: DATA")
        //let token = String(format: "%@", deviceToken as CVarArg)
        //debugPrint("*** deviceToken: \(token)")
        Messaging.messaging().apnsToken = deviceToken
        debugPrint("Firebase Token:",InstanceID.instanceID().token() as Any)
    }
    //-------------------------------------------------------------------------//
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let messageID = userInfo["gcm.message_id"] {
            debugPrint("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
}

// MARK:- extension AppDelegate: MessagingDelegate

extension AppDelegate: MessagingDelegate{
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String)
    {
        debugPrint("--->messaging:\(messaging)")
        debugPrint("--->didRefreshRegistrationToken:\(fcmToken)")
    }
    @available(iOS 10.0, *)
    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage)
    {
        debugPrint("--->messaging:\(messaging)")
        debugPrint("--->didReceive Remote Message:\(remoteMessage.appData)")
        guard let data =
            try? JSONSerialization.data(withJSONObject: remoteMessage.appData, options: .prettyPrinted),
            let prettyPrinted = String(data: data, encoding: .utf8) else { return }
        print("Received direct channel message:\n\(prettyPrinted)")
    }
}
