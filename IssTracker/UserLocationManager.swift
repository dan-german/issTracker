import CoreLocation
import SystemConfiguration
import UIKit

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    
    //MARK: - Singleton
    
    static var Instance = UserLocation()
    
    //MARK: - Properties
    
    private var location = CLLocation()
    let manager = CLLocationManager()
    private(set) var latitude: Double?
    private(set) var longitude: Double?
    private(set) var altitude: Double?
    
    //MARK: - Initializers
    
    override init() {
        
        
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    //MARK: - CLLocationManager Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        let newLocation = locations.last
        
        let timeDiff = newLocation?.timestamp.timeIntervalSinceNow
        
        let isLocationAccurate: Bool = (newLocation?.horizontalAccuracy)!<=kCLLocationAccuracyThreeKilometers
        
        if let diff = timeDiff, diff < 5.0 && isLocationAccurate {
            
            self.manager.stopUpdatingLocation()
            
            self.location = newLocation!
            self.latitude = self.location.coordinate.latitude
            self.longitude = self.location.coordinate.longitude
            
            PassTimesManager.Instance.updatePassTimes()
            
            self.manager.delegate = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        if status == .denied {
            let alertController = UIAlertController(title: "Location access denied", message: "In order to get most of the application, please change location permissions in Settings.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            getTopViewController().present(alertController, animated: true, completion: nil)            
        }        
    }
    
    //MARK: -
    
    func getTopViewController() -> UIViewController {
        
        
        var viewController = UIViewController()
        
        if let vc =  UIApplication.shared.delegate?.window??.rootViewController {
            
            viewController = vc
            
            while let top = vc.presentedViewController {
                viewController = top
            }
        }
        
        return viewController
    }
}
