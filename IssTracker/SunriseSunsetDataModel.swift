import ObjectMapper

class SunData: Mappable {
    
    
    //MARK: - Properties
    
    private(set) var sunriseString: String?
    private(set) var sunsetString: String?
    
    var sunRiseSingle : String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from: sunriseString!)
            dateFormatter.dateFormat = "HHmm"
            let string = dateFormatter.string(from: date!)
            return string
        }
    }
    
    var sunSetSingle : String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from: sunsetString!)
            dateFormatter.dateFormat = "HH"
            let string = dateFormatter.string(from: date!)
            return string
        }
    }
    
    //MARK: - Initializers
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        sunriseString <- map["results.sunrise"]
        sunsetString <- map["results.sunset"]
    }
}
