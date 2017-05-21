import ObjectMapper

class IssLocation: Mappable {
    
    
    //MARK: - Properties
    
    var lat: String?
    var lon: String?
    
    //MARK: - Initializers
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        
        lat <- map["iss_position.latitude"]
        lon <- map["iss_position.longitude"]
    }
}



