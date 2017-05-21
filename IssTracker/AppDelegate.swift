import UIKit
import GoogleMaps
import ObjectMapper
import UserNotifications
import SystemConfiguration
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var locationUpdateTimer = Timer()
    var notificationTimer = Timer()
    var updatePassTimeTimer = Timer()
    var bootTimer = Timer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        GMSServices.provideAPIKey("AIzaSyAGiW01gpOS6jMy1CTw4294F8Kl6YRCv-A")
        Mixpanel.initialize(token: "942595f22c76415e5ede832b961ca0ee")
        
        UserLocation.Instance.manager.requestAlwaysAuthorization()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.alert], completionHandler: {didAllow, error in})
        
        notificationTimer = Timer.scheduledTimer(timeInterval: 1, target: PassTimesManager.Instance.self, selector: #selector(PassTimesManager.Instance.HandleNotifications), userInfo: nil, repeats: true)
        
        updatePassTimeTimer = Timer.scheduledTimer(timeInterval: 43200, target: self, selector: #selector(updatePassTimeAndSunStuff), userInfo: nil, repeats: true)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        window?.rootViewController = CustomTabBarController()
                
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      
        
        locationUpdateTimer.invalidate()
    }
    
    func updatePassTimeAndSunStuff(){
        
        
        PassTimesManager.Instance.updatePassTimes()
    }
}
