import ObjectMapper

class Response: Mappable {
    
    //MARK: - Properties
    
    var passTimesArray = [PassTime]()
    
    //MARK: - Initializers
    
    required init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
        
        passTimesArray <- map["response"]
    }
}

class PassTime: Mappable {
    
    
    //MARK: - Private Properties
    
    private(set) var duration: Int?
    private(set) var risetime: Double?
    private let seconds:Double? = 0
    
    //MARK: Public Properties
    
    var wholeDate: String {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss | EEEE, MMM d, yyyy"
            let date = Date(timeIntervalSince1970: risetime!)
            let string = dateFormatter.string(from: date  - seconds!)
            return string as String
        }
    }
    
    var riseDate: String {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            let date = Date(timeIntervalSince1970: risetime!)
            let string = dateFormatter.string(from: date - seconds!)
            return string as String
        }
    }
    var riseHour: String {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let date = Date(timeIntervalSince1970: risetime!)
            let string = dateFormatter.string(from: date - seconds!)
            return string as String
        }
    }
    
    var rawDate: Date {
        let date = Date(timeIntervalSince1970: risetime!)
        return date  - seconds!
    }
    
    var fallHour: String {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let date = Date(timeIntervalSince1970: risetime! + Double(duration!))
            let string = dateFormatter.string(from: date  - seconds!)
            return string as String
        }
    }
    
    var singleRiseHour: String {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HHmm"
            let date = Date(timeIntervalSince1970: risetime!)
            let string = dateFormatter.string(from: date)
            return string            
        }
    }
    
    var isVisible: Bool {
        get {
            return !((singleRiseHour > SunManager.Instance.sunRiseHour) && (singleRiseHour < SunManager.Instance.sunSetHour))
        }
    }
    
    var emoji: String {
        get {
            if !isVisible {
                return "☀️"
            } else {
                return "🌑"
            }
        }
    }
    
    // MARK: - Initializers
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        duration <- map["duration"]
        risetime <- map["risetime"]
    }
    
    //MARK: -
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
