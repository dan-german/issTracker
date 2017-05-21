import ObjectMapper
import UserNotifications

class PassTimesManager {
    
    
    //MARK: - Singleton
    
    static var Instance = PassTimesManager()
    
    //MARK: - Properties
    
    private(set) var passTimes = [PassTime]()
    private let passes = 30
    let defaults = UserDefaults.standard
    let minuteArray = [60, 120, 300, 600, 900, 1800]
    var minuteArrayString = ["1 minute", "2 minutes", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]
    
    private var allowNotificationsBool = true
    private var notifyVisibleOnlyBool = true
    
    //MARK: - Keys
    
    let notificationsKey = "notifications"
    let visibleOnlyKey = "visibleOnly"
    let minuteArrayIndexKey = "minuteArrayIndex"
    
    init() {
        
        
        allowNotificationsBool = defaults.bool(forKey: notificationsKey)
        notifyVisibleOnlyBool = defaults.bool(forKey: visibleOnlyKey)
        
        NotificationCenter.default.addObserver(forName: Notification.Name("AllowNotificationsOn"), object: nil, queue: nil) { (Notification) in
            self.allowNotificationsBool = true
            self.defaults.set(self.allowNotificationsBool, forKey: self.notificationsKey)
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("AllowNotificationsOff"), object: nil, queue: nil) { (Notification) in
            self.allowNotificationsBool = false
            self.defaults.set(self.allowNotificationsBool, forKey: self.notificationsKey)
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("VisibleOnlyOn"), object: nil, queue: nil) { (Notification) in
            self.notifyVisibleOnlyBool = true
            self.defaults.set(self.notifyVisibleOnlyBool, forKey: self.visibleOnlyKey)
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("VisibleOnlyOff"), object: nil, queue: nil) { (Notification) in
            self.notifyVisibleOnlyBool = false
            self.defaults.set(self.notifyVisibleOnlyBool, forKey: self.visibleOnlyKey)
        }
    }
    
    @objc func updatePassTimes(){
        
        
        SunManager.Instance.populateSunDataArray()
        
        passTimes.removeAll()
        
        guard let lon = UserLocation.Instance.longitude, let lat = UserLocation.Instance.latitude else { return }
        
        let url = URL(string:"http://api.open-notify.org/iss-pass.json?lat=\(lat)&lon=\(lon)&n=\(passes)")
        
        do
        {
            let jsonData = try Data.init(contentsOf: url!)
            let jsonString = NSString(data: jsonData, encoding: 1)
            
            if let response = Mapper<Response>().map(JSONString: jsonString! as String){
                
                for i in 0..<response.passTimesArray.count {
                    
                    if response.passTimesArray[i].rawDate + Double(response.passTimesArray[i].duration!) < Date() {
                        continue
                    }
                    passTimes.append(response.passTimesArray[i])
                }
            }
        }
        catch {
            NSLog("Failed to retrieve ISS pass times data. \(error)")
        }
    }
    
    
    @objc func HandleNotifications(){
        
        
        if !passTimes.isEmpty && allowNotificationsBool == true {
            
            let riseTime = passTimes[0].risetime
            let closestDate = Date(timeIntervalSince1970:riseTime!)
            let secondsLeft = Int(closestDate.timeIntervalSince(Date()))
            let secondsBeforeNotification = minuteArray[UserDefaults.standard.integer(forKey: minuteArrayIndexKey)]
            let timeToNotify: Bool = (secondsLeft == secondsBeforeNotification)
            
            if notifyVisibleOnlyBool == false {
                
                if timeToNotify {
                    
                    let visibleIn = String(describing: minuteArrayString[UserDefaults.standard.integer(forKey: minuteArrayIndexKey)])
                    let content = NotificationContent(title: "Look up!", body: "ISS passing above in \(visibleIn)!", badge: 0)
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: "notify", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                
            } else if notifyVisibleOnlyBool == true {
                
                if timeToNotify && passTimes[0].isVisible {
                    
                    let visibleIn = String(describing: minuteArrayString[UserDefaults.standard.integer(forKey: minuteArrayIndexKey)])
                    let content = NotificationContent(title: "Look up!", body: "ISS passing above in \(visibleIn)!", badge: 0)
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: "notify", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                }
            }
        }
    }
    
    func NotificationContent(title: String, body: String, badge: NSNumber) -> UNMutableNotificationContent {
        
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = badge
        return content
    }
}
