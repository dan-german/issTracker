import ObjectMapper

class SunManager {
    
    //MARK: - Singleton
    static var Instance = SunManager()
    
    //MARK: - Properties
    private(set) var sunRiseHour = String()
    private(set) var sunSetHour = String()
    
    func populateSunDataArray(){
        
        
        guard let lon = UserLocation.Instance.longitude, let lat = UserLocation.Instance.latitude else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        do
        {
            let url = URL(string:"https://api.sunrise-sunset.org/json?lat=\(lat)&lng=\(lon)&formatted=0")
            let jsonData = try Data.init(contentsOf: url!)
            let jsonString = NSString(data: jsonData, encoding: 1)
            
            if let response = Mapper<SunData>().map(JSONString: jsonString! as String){
                sunRiseHour = response.sunRiseSingle
                sunSetHour = response.sunSetSingle
            }
        }
        catch {
            NSLog("Failed to retrieve sunrise/sunset data. \(error)")
        }
        
    }
}


