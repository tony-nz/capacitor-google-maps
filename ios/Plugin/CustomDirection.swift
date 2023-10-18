import Foundation
import GoogleMaps
import Capacitor

class CustomDirection {
    var id: String! = NSUUID().uuidString.lowercased()
    var mapId: String! = ""
    var origin: CLLocationCoordinate2D! = CLLocationCoordinate2D()
    var destination: CLLocationCoordinate2D! = CLLocationCoordinate2D()
    var waypoints: [String]! = [String]()
    var travelMode: String! = "DRIVING"
    
    
    public func updateFromJSObject(_ directionData: JSObject) {
        // see src/interfaces/models/Directions for reference
        let preferences = directionData["preferences"] as! JSObject

        if let preferences = preferences as? [String: [String: Double]], // Check if preferences is the expected dictionary structure
            let originLatitude = preferences["origin"]?["latitude"],
            let originLongitude = preferences["origin"]?["longitude"] {
                self.origin = CLLocationCoordinate2D(
                    latitude: originLatitude,
                    longitude: originLongitude
                )
            }
        if let preferences = preferences as? [String: [String: Double]], // Check if preferences is the expected dictionary structure
        let destinationLatitude = preferences["destination"]?["latitude"],
        let destinationLongitude = preferences["destination"]?["longitude"] {
            self.destination = CLLocationCoordinate2D(
                latitude: destinationLatitude,
                longitude: destinationLongitude
            )
        }
        if let preferences = preferences as? [String: [String: Double]], // Check if preferences is the expected dictionary structure
        let waypointsLatitude = preferences["waypoints"]?["latitude"],
        let waypointsLongitude = preferences["waypoints"]?["longitude"] {
            self.waypoints = [String]()
        }
        if let preferences = preferences as? [String: [String: Double]], // Check if preferences is the expected dictionary structure
        let travelMode = preferences["travelMode"] as? String {
            self.travelMode = travelMode
        }
        if let preferences = preferences as? [String: [String: Double]], // Check if preferences is the expected dictionary structure
        let mapId = directionData["mapId"] as? String {
            self.mapId = mapId
        }

    }
    
    // public static func getResultForDirection(_ direction: Direction, mapId: String) -> PluginCallResultData {
    //     let result = direction
        // let status = result.status
        // let error = result.error 
        // let routes = result.routes
        // let geocodedWaypoints = result.geocodedWaypoints
        // let bounds = result.bounds
        // let fare = result.fare
        // let waypointOrder = result.waypointOrder
        // let overviewPolyline = result.overviewPolyline
        // let warnings = result.warnings
        // let waypointOrderArray = waypointOrder?.map { $0.intValue }
        // let overviewPolylinePath = overviewPolyline?.path
        // let overviewPolylinePathArray = jsonFromPath(overviewPolylinePath)
        // let routesArray = routes?.map { route -> JSObject in
        //     let legs = route.legs
        //     let legsArray = legs?.map { leg -> JSObject in
        //         let steps = leg.steps
        //         let stepsArray = steps?.map { step -> JSObject in
        //             let polyline = step.polyline
        //             let polylinePath = polyline?.path
        //             let polylinePathArray = jsonFromPath(polylinePath)
        //             return [
        //                 "distance": [
        //                     "text": step.distance.text,
        //                     "value": step.distance.value
        //                 ],
        //                 "duration": [
        //                     "text": step.duration.text,
        //                     "value": step.duration.value
        //                 ],
        //                 "endLocation": [
        //                     "latitude": step.endLocation.latitude,
        //                     "longitude": step.endLocation.longitude
        //                 ],
        //                 "htmlInstructions": step.htmlInstructions,
        //                 "maneuver": step.maneuver,
        //                 "polyline": [
        //                     "points": step.polyline.points,
        //                     "path": polylinePathArray
        //                 ],
        //                 "startLocation": [
        //                     "latitude": step.startLocation.latitude,
        //                     "longitude": step.startLocation.longitude
        //                 ],
        //                 "travelMode": step.travelMode
        //             ]
        //         }
        //         return [
        //             "distance": [
        //                 "text": leg.distance.text,
        //                 "value": leg.distance.value
        //             ],
        //             "duration": [
        //                 "text": leg.duration.text,
        //                 "value": leg.duration.value
        //             ],
        //             "endAddress": leg.endAddress,
        //             "endLocation": [
        //                 "latitude": leg.endLocation.latitude,
        //                 "longitude": leg.endLocation.longitude
        //             ],
        //             "startAddress": leg.startAddress,
        //             "startLocation": [
        //                 "latitude": leg.startLocation.latitude,
        //                 "longitude": leg.startLocation.longitude
        //             ],
        //             "steps": stepsArray,
        //             "trafficSpeedEntry": leg.trafficSpeedEntry,
        //             "viaWaypoint": leg.viaWaypoint
        //         ]
        //     }
        // }
    // }
    

    private static func jsonFromPath(_ path: GMSPath?) -> [JSObject] {
        guard let path = path else {
            return [JSObject]()
        }
        let size = path.count()
        var pathArray = [JSObject]()
        for i in 0..<size {
            let coordinate = path.coordinate(at: i)
            pathArray.append([
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ])
        }
        return pathArray
    }

    private static func pathFromJson(_ pathArray: [JSObject]) -> GMSPath {
        let path = GMSMutablePath()
        for coordinate in pathArray {
            let latitude = coordinate["latitude"] as? Double ?? 0
            let longitude = coordinate["longitude"] as? Double ?? 0
            path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        return path
    }
}
