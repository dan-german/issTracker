import UIKit
import GoogleMaps
import ObjectMapper
import CoreLocation

class MapController: UIViewController {
    
    
    //MARK: - Properties
    
    var issLongitude: Double?
    var issLatitude: Double?
    var userLongitude: Double?
    var userLatitude: Double?
    var lock: Bool = true
    
    var issLocationTimer = Timer()
    
    //MARK: - GMS Properties
    
    var issMarker = GMSMarker()
    var userLocationMarker = GMSMarker()
    var issCamera = GMSCameraPosition()
    var userLocationCamera = GMSCameraPosition()
    var camera = GMSCameraPosition()
    var mapView = GMSMapView()
    
    //MARK: - UI
    
    let lockButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "map_lock"), for: .normal)
        button.setImage(UIImage(named: "map_lock_open"), for: .selected)
        return button
    }()
    
    let myLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"map_pin"), for: .normal)
        return button
    }()
    
    var bottomGuide: UILayoutSupport?
    
    //MARK: -
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupMap()
        setupUI()
        bottomGuide = inputViewController?.bottomLayoutGuide
        do {
            
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if ConnectionChecker.isConnected() {
            
            startTimer()
            lock = true
            
        } else {
            
            let alert = UIAlertController(title: "Failed to retrieve ISS location data", message: "Please check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            lock = false
            lockButton.isEnabled = false
            return
        }
        
        mapView.camera = issCamera
        mapView.animate(toZoom: 2)
        
        if let lon = UserLocation.Instance.longitude, let lat = UserLocation.Instance.latitude {
            userLongitude = lon
            userLatitude = lat
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
        issLocationTimer.invalidate()
    }
    
    //MARK: -
    
    private func startTimer() {
        
        
        issLocationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateIssMarkerLocation()
        }
    }
    
    
    private func setupMap(){
        
        
        issCamera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 5)
        camera = issCamera
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let mapConstraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":mapView])
        
        let mapConstraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0][v1]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":mapView, "v1":bottomLayoutGuide])
        
        NSLayoutConstraint.activate(mapConstraintH)
        NSLayoutConstraint.activate(mapConstraintV)
        
        issMarker.icon = UIImage(named: "iss_icon")
        issMarker.map = mapView
        
        userLocationMarker.title = "You"
        userLocationMarker.map = mapView
        
        mapView.settings.compassButton = true
        
        mapView.padding = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
    }
    
    
    private func setupUI(){
        
        
        view.addSubview(lockButton)
        view.addSubview(myLocationButton)
        
        myLocationButton.translatesAutoresizingMaskIntoConstraints = false
        lockButton.translatesAutoresizingMaskIntoConstraints = false
        
        let lockButtonConstraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:[v0]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":lockButton])
        let buttonsConstraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-[v1]-70-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":lockButton,"v1":myLocationButton])
        
        let myLocationButtonConstraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:[v0]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":myLocationButton])
        
        NSLayoutConstraint.activate(lockButtonConstraintH)
        NSLayoutConstraint.activate(myLocationButtonConstraintH)
        NSLayoutConstraint.activate(buttonsConstraintV)
        
        lockButton.addTarget(self, action: #selector(lockOnIss), for: .touchUpInside)
        myLocationButton.addTarget(self, action: #selector(showMyLocation), for: .touchUpInside)
    }
    
    private func updateIssMarkerLocation(){
        
        
        let url = URL(string: "http://api.open-notify.org/iss-now.json")
        do {
            let jsonData = try Data.init(contentsOf: url!)
            let jsonString = NSString(data: jsonData, encoding: 1)
            let location = Mapper<IssLocation>().map(JSONString: jsonString! as String)
            issLongitude = Double(location!.lon!)
            issLatitude = Double(location!.lat!)
            issMarker.position = CLLocationCoordinate2D(latitude: issLatitude!, longitude: issLongitude!)
            issCamera = GMSCameraPosition.camera(withLatitude: issLatitude!, longitude: issLongitude!, zoom: mapView.camera.zoom)
        } catch {
            NSLog("Failed to retrieve ISS location data. \(error)")
        }
        
        if lock {
            mapView.animate(to: issCamera)
        }
    }
    
    @objc private func lockOnIss() {
        
        
        if lock {
            lock = false
            lockButton.setImage(UIImage(named: "map_lock_open"), for: .normal)
        } else {
            lock = true
            lockButton.setImage(UIImage(named: "map_lock"), for: .normal)
        }
    }
    
    @objc private func showMyLocation() {
        
        
        guard let lon = UserLocation.Instance.longitude , let lat = UserLocation.Instance.latitude else  { return }
        lock = false
        lockButton.setImage(UIImage(named: "map_lock_open"), for: .normal)
        userLocationCamera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 6.5)
        mapView.animate(to: userLocationCamera)
        userLocationMarker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)        
    }
}





