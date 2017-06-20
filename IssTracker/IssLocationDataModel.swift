import ObjectMapper

class IssLocation: Mappable {
    
    
    //MARK: - Properties
    
    private(set) var lat: String?
    private(set) var lon: String?
    
    //MARK: - Initializers
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        
        lat <- map["iss_position.latitude"]
        lon <- map["iss_position.longitude"]
    }
}



