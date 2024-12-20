import Foundation
import Alamofire
import ObjectMapper

public class GooglePlaces: GoogleMapsService {
    
    fileprivate static var pendingRequest: DataRequest?
    
    public static let placeAutocompleteURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    public class func placeAutocomplete(forInput input: String,
                                        offset: Int? = nil,
                                        locationCoordinate: LocationCoordinate2D? = nil,
                                        radius: Int? = nil,
                                        language: String? = nil,
                                        types: [PlaceType]? = nil,
                                        components: String? = nil,
                                        cancelPendingRequestsAutomatically: Bool = true,
                                        completion: ((PlaceAutocompleteResponse?, NSError?) -> Void)?)
    {
        var requestParameters: [String : Any] = baseRequestParameters + [
            "input" : input
        ]
        
        if let offset = offset {
            requestParameters["offset"] = offset
        }
        
        if let locationCoordinate = locationCoordinate {
            requestParameters["location"] = "\(locationCoordinate.latitude),\(locationCoordinate.longitude)"
        }
        
        if let radius = radius {
            requestParameters["radius"] = radius
        }
        
        if let language = language {
            requestParameters["language"] = language
        }
        
        if let types = types {
            requestParameters["types"] = types.map { $0.rawValue }.joined(separator: "|")
        }
        
        if let components = components {
            requestParameters["components"] = components
        }
        
        if pendingRequest != nil && cancelPendingRequestsAutomatically {
            pendingRequest?.cancel()
            pendingRequest = nil
        }
        
        let request = AF.request(placeAutocompleteURLString, parameters: requestParameters)
        request.responseJSON { response in
            if response.error?.isExplicitlyCancelledError == true {
                return // Request was cancelled, so we exit early
            }
            
            if let error = response.error {
                NSLog("Error: GET failed")
                completion?(nil, NSError(domain: "GooglePlacesError", code: -1, userInfo: nil))
                return
            }
            
            guard let json = response.value as? [String : AnyObject] else {
                NSLog("Error: Parsing json failed")
                completion?(nil, NSError(domain: "GooglePlacesError", code: -2, userInfo: nil))
                return
            }
            
            guard let response = Mapper<PlaceAutocompleteResponse>().map(JSON: json) else {
                NSLog("Error: Mapping directions response failed")
                completion?(nil, NSError(domain: "GooglePlacesError", code: -3, userInfo: nil))
                return
            }
            
            var error: NSError?
            
            switch response.status {
            case .none:
                let userInfo = [
                    NSLocalizedDescriptionKey : NSLocalizedString("StatusCodeError", value: "Status Code not found", comment: ""),
                    NSLocalizedFailureReasonErrorKey : NSLocalizedString("StatusCodeError", value: "Status Code not found", comment: "")
                ]
                error = NSError(domain: "GooglePlacesError", code: -1, userInfo: userInfo)
            case .some(let status):
                switch status {
                case .ok:
                    break
                default:
                    let userInfo = [
                        NSLocalizedDescriptionKey : NSLocalizedString("StatusCodeError", value: status.rawValue, comment: ""),
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString("StatusCodeError", value: response.errorMessage ?? "", comment: "")
                    ]
                    error = NSError(domain: "GooglePlacesError", code: -1, userInfo: userInfo)
                }
            }
            
            pendingRequest = nil
            completion?(response, error)
        }
        
        pendingRequest = request
    }
}



// MARK: - Place Details
public extension GooglePlaces {
    
    static let placeDetailsURLString = "https://maps.googleapis.com/maps/api/place/details/json"
    
    class func placeDetails(forPlaceID placeID: String, extensions: String? = nil, language: String? = nil, completion: ((_ response: PlaceDetailsResponse?, _ error: NSError?) -> Void)?) {
        var requestParameters = baseRequestParameters + [
            "placeid" : placeID
        ]
        
        if let extensions = extensions {
            requestParameters["extensions"] = extensions
        }
        
        if let language = language {
            requestParameters["language"] = language
        }
        
        AF.request(placeDetailsURLString, parameters: requestParameters).responseJSON { response in
            if let error = response.error {
                NSLog("Error: GET failed")
                completion?(nil, NSError(domain: "GooglePlacesError", code: -1, userInfo: nil))
                return
            }
            
            guard let json = response.value as? [String : Any] else {
                NSLog("Error: Parsing json failed")
                completion?(nil, NSError(domain: "GooglePlacesError", code: -2, userInfo: nil))
                return
            }
            
            guard let response = Mapper<PlaceDetailsResponse>().map(JSON: json) else {
                NSLog("Error: Mapping directions response failed")
                completion?(nil, NSError(domain: "GooglePlacesError", code: -3, userInfo: nil))
                return
            }
            
            var error: NSError?
            
            switch response.status {
            case .none:
                let userInfo = [
                    NSLocalizedDescriptionKey : NSLocalizedString("StatusCodeError", value: "Status Code not found", comment: ""),
                    NSLocalizedFailureReasonErrorKey : NSLocalizedString("StatusCodeError", value: "Status Code not found", comment: "")
                ]
                error = NSError(domain: "GooglePlacesError", code: -1, userInfo: userInfo)
            case .some(let status):
                switch status {
                case .ok:
                    break
                default:
                    let userInfo = [
                        NSLocalizedDescriptionKey : NSLocalizedString("StatusCodeError", value: status.rawValue, comment: ""),
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString("StatusCodeError", value: response.errorMessage ?? "", comment: "")
                    ]
                    error = NSError(domain: "GooglePlacesError", code: -1, userInfo: userInfo)
                }
            }
            
            completion?(response, error)
        }
    }
}
