//
//  SharedTypes.swift
//  GoogleMapsDirections
//
//  Created by Honghao Zhang on 2016-02-12.
//  Copyright © 2016 Honghao Zhang. All rights reserved.
//

import Foundation
import ObjectMapper

public extension GoogleMapsService {
    /// The status field within the Directions response object contains the status of the request,
    /// and may contain debugging information to help you track down why the Directions service failed.
    /// Reference: https://developers.google.com/maps/documentation/directions/intro#StatusCodes
    ///
    /// - ok:                   The response contains a valid result.
    /// - notFound:             At least one of the locations specified in the request's origin, destination, or waypoints could not be geocoded.
    /// - zeroResults:          No route could be found between the origin and destination.
    /// - maxWaypointsExceeded: Too many waypoints were provided in the request.
    /// - invalidRequest:       The provided request was invalid.
    /// - overQueryLimit:       The service has received too many requests from your application within the allowed time period.
    /// - requestDenied:        The service denied use of the directions service by your application.
    /// - unknownError:         Directions request could not be processed due to a server error.
    enum StatusCode: String {
        case ok = "OK"
        case notFound = "NOT_FOUND"
        case zeroResults = "ZERO_RESULTS"
        case maxWaypointsExceeded = "MAX_WAYPOINTS_EXCEEDED"
        case invalidRequest = "INVALID_REQUEST"
        case overQueryLimit = "OVER_QUERY_LIMIT"
        case requestDenied = "REQUEST_DENIED"
        case unknownError = "UNKNOWN_ERROR"
    }
}


// MARK: - Place
public extension GoogleMapsService {
    typealias LocationDegrees = Double
    struct LocationCoordinate2D {
        var latitude: LocationDegrees
        var longitude: LocationDegrees
        
        init(latitude: LocationDegrees, longitude: LocationDegrees) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    /// This struct represents a place/address/location, used in Google Map Directions API
    /// Reference: https://developers.google.com/maps/documentation/directions/intro#RequestParameters
    ///
    /// - stringDescription: Address as a string
    /// - coordinate:        Coordinate
    /// - placeID:           Place id from Google Map API
    enum Place {
        case stringDescription(address: String)
        case coordinate(coordinate: LocationCoordinate2D)
        case placeID(id: String)
        
        func toString() -> String {
            switch self {
            case .stringDescription(let address):
                return address
            case .coordinate(let coordinate):
                return "\(coordinate.latitude),\(coordinate.longitude)"
            case .placeID(let id):
                return "place_id:\(id)"
            }
        }
    }
}

public extension CustomMapViewEvents {
    
    struct Direction {
        let mapId: String
        let origin: LatLng
        let destination: LatLng
        let waypoints: [LatLng]
        let travelMode: TravelMode
        let preferences: DirectionPreferences?

        init(mapId: String, origin: LatLng, destination: LatLng, waypoints: [LatLng], travelMode: TravelMode, preferences: DirectionPreferences?) {
            self.mapId = mapId
            self.origin = origin
            self.destination = destination
            self.waypoints = waypoints
            self.travelMode = travelMode
            self.preferences = preferences
        }
    }

    struct LatLng {
        let latitude: Double
        let longitude: Double

        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    enum TravelMode: String {
        case driving = "DRIVING"
        case walking = "WALKING"
        case bicycling = "BICYCLING"
        case transit = "TRANSIT"
    }

    struct DirectionPreferences {
        let avoidHighways: Bool?
        let avoidTolls: Bool?
        let avoidFerries: Bool?
        let avoidIndoor: Bool?
        let avoidIndoorWalkways: Bool?
        let travelMode: TravelMode?
        let unitSystem: UnitSystem?
        let waypoints: [LatLng]?
    }

    enum UnitSystem: String {
        case metric = "METRIC"
        case imperial = "IMPERIAL"
    }

    // Direction results

    struct DirectionResults {
        let routes: [Route]
    }

    struct Route {
        let summary: String?
        let legs: [Leg]
        let waypointOrder: [Int]?
        let overviewPolylinePoints: String?
        let bounds: Bounds?
        let copyrights: String?
        let warnings: [String]?
        let fare: Fare?
    }

    struct Leg {
        let steps: [Step]
        let distance: Distance?
        let duration: Duration?
        let durationInTraffic: Duration?
        let arrivalTime: String?
        let departureTime: String?
        let startLocation: LocationCoordinate2D?
        let endLocation: LocationCoordinate2D?
        let startAddress: String?
        let endAddress: String?
    }

    struct Step {
        let htmlInstructions: String?
        let distance: Distance?
        let duration: Duration?
        let startLocation: LocationCoordinate2D?
        let endLocation: LocationCoordinate2D?
        let polylinePoints: String?
        let steps: [Step]?
        let travelMode: TravelMode?
        let maneuver: String?
        let transitDetails: TransitDetails?
    }

    struct Distance {
        let text: String?
        let value: Double?
    }

    struct Duration {
        let text: String?
        let value: Double?
    }

    struct LocationCoordinate2D {
        let latitude: Double
        let longitude: Double
    }

    struct Bounds {
        let northeast: LocationCoordinate2D?
        let southwest: LocationCoordinate2D?
    }

    struct Fare {
        let currency: String?
        let value: Double?
    }

    struct TransitDetails {
        let arrivalStop: TransitStop?
        let arrivalTime: TransitTime?
        let departureStop: TransitStop?
        let departureTime: TransitTime?
        let headsign: String?
        let headway: Int?
        let line: TransitLine?
        let numStops: Int?
    }

    struct TransitStop {
        let location: LocationCoordinate2D?
        let name: String?
    }

    struct TransitTime {
        let text: String?
        let value: Int?
    }

    struct TransitLine {
        let agencies: [TransitAgency]?
        let color: String?
        let icon: String?
        let name: String?
        let shortName: String?
        let textColor: String?
        let url: String?
        let vehicle: TransitVehicle?
    }

    struct TransitAgency {
        let name: String?
        let phone: String?
        let url: String?
    }

    struct TransitVehicle {
        let icon: String?
        let localIcon: String?
        let name: String?
        let type: String?
    }

}