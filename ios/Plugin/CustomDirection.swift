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
    
    public static func getResultForDirection(_ routes: [DirectionResults], mapId: String) -> PluginCallResultData {
        var results: [PluginCallResultData] = []

        for route in routes {
            // Process each route
            let result: PluginCallResultData = [
                "route": [
                    "mapId": mapId,
                    "summary": route.summary ?? "",
                    "waypointOrder": route.waypointOrder ?? [],
                    "overviewPolylinePoints": route.overviewPolylinePoints ?? "",
                    "copyrights": route.copyrights ?? "",
                    "warnings": route.warnings,
                    "fare": route.fare ?? [:],  // You can adjust this as needed
                    "legs": []
                ]
            ]

            // Process legs within the route
            for leg in route.legs {
                let legData: PluginCallResultData = [
                    "startLocation": [
                        "latitude": leg.startLocation.latitude,
                        "longitude": leg.startLocation.longitude
                    ],
                    "endLocation": [
                        "latitude": leg.endLocation.latitude,
                        "longitude": leg.endLocation.longitude
                    ],
                    "startAddress": leg.startAddress,
                    "endAddress": leg.endAddress,
                    "steps": [],
                    "distance": [
                        "text": leg.distance?.text ?? "",
                        "value": leg.distance?.value ?? 0.0
                    ],
                    "duration": [
                        "text": leg.duration?.text ?? "",
                        "value": leg.duration?.value ?? 0.0
                    ]
                ]

                // Process steps within the leg
                for step in leg.steps {
                    let stepData: PluginCallResultData = [
                        "htmlInstructions": step.htmlInstructions ?? "",
                        "distance": [
                            "text": step.distance?.text ?? "",
                            "value": step.distance?.value ?? 0.0
                        ],
                        "duration": [
                            "text": step.duration?.text ?? "",
                            "value": step.duration?.value ?? 0.0
                        ],
                        "startLocation": [
                            "latitude": step.startLocation.latitude,
                            "longitude": step.startLocation.longitude
                        ],
                        "endLocation": [
                            "latitude": step.endLocation.latitude,
                            "longitude": step.endLocation.longitude
                        ],
                        "polylinePoints": step.polylinePoints ?? "",
                        "travelMode": step.travelMode.rawValue,
                        "maneuver": step.maneuver ?? "",
                        "transitDetails": step.transitDetails ?? [:] // You can adjust this as needed
                    ]

                    legData["steps"]?.append(stepData)
                }

                result["legs"]?.append(legData)
            }

            results.append(result)
        }

        return results
    }

// [
//   TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route(
//     summary: Optional("Church St and High St"),
//     legs: [
//       TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Leg(
//         steps: [
//           TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Leg.Step(
//             htmlInstructions: Optional("Head <b>north</b> on <b>Church St</b> toward <b>Queen St</b>"),
//             distance: Optional(
//               TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Leg.Step.Distance(
//                 value: Optional(561),
//                 text: Optional("0.6 km")
//               )
//             ),
//             duration: Optional(
//               TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Leg.Step.Duration(
//                 value: Optional(59),
//                 text: Optional("1 min")
//               )
//             ),
//             startLocation: Optional(
//               TonyNzCapacitorGoogleMaps.GoogleMapsService.LocationCoordinate2D(
//                 latitude: -43.30918579999999,
//                 longitude: 172.5902207
//               )
//             ),
//             endLocation: Optional(
//               TonyNzCapacitorGoogleMaps.GoogleMapsService.LocationCoordinate2D(
//                 latitude: -43.3042176,
//                 longitude: 172.5890171
//               )
//             ),
//             polylinePoints: Optional("lyigG{_l|_@}AVoCd@s@J}Fz@{B\\WDwG~@UD"),
//             steps: [],
//             travelMode: Optional(TonyNzCapacitorGoogleMaps.GoogleMapsDirections.TravelMode.driving),
//             maneuver: nil,
//             transitDetails: nil
//           ),
//         ],
//         distance: Optional(
//           TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Leg.Step.Distance(
//             value: Optional(716),
//             text: Optional("0.7 km")
//           )
//         ),
//         duration: Optional(
//           TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Leg.Step.Duration(
//             value: Optional(130),
//             text: Optional("2 mins")
//           )
//         ),
//         durationInTraffic: nil,
//         arrivalTime: nil,
//         departureTime: nil,
//         startLocation: Optional(
//           TonyNzCapacitorGoogleMaps.GoogleMapsService.LocationCoordinate2D(
//             latitude: -43.3133251,
//             longitude: 172.5974065
//           )
//         ),
//         endLocation: Optional(
//           TonyNzCapacitorGoogleMaps.GoogleMapsService.LocationCoordinate2D(
//             latitude: -43.3153568,
//             longitude: 172.5904605
//           )
//         ),
//         startAddress: Optional("1 Charles Street, Rangiora 7400, New Zealand"),
//         endAddress: Optional("45 Bush Street, Rangiora 7400, New Zealand")
//       )
//     ],
//     waypointOrder: [],
//     overviewPolylinePoints: Optional("lyigG{_l|_@mF|@qHfAaMhB]{EEIKe@ECECEQBQJGBACqAa@cF{@mMy@mMWuDc@qGUkDIKIkAA?CCACAI@G@CCeA@KUqDcAoOO_C|Ce@}Cd@N~BbAnOTpDDJH|@@@@@B@@HAPEBG@ECAAw@PIAECaC^aC\\_@F\\jF]kF^G`C]bCc@LGt@S?C@A@CFCD@B@?@`@IX@vB[|Ew@xKeBbC]cC\\{HlAcEp@oFx@ILm@J?@ABABEBE?II@SE_ABQsAsS[aFyAuT_BeVp@K\\SXIxF}@ZvE[wEyF|@YH]Rq@JdCh_@fAnPzAvUFTFr@@@@?@B@@l@KJ@v@MrASnCc@x@MKyBA{@Dc@T}@s@[[KK?WBiAPSoCCGOAs@LAD?TDj@Ek@AQBIr@MH?FDTrCrASXAnAf@U|@Eb@@z@JxBy@LoCb@sARw@LEHIDg@H?@?@ABCB?@JfACNj@pIVhDbCr_@`@bFBpAB@D@FN?PCDBXA^hApPThDYDXEUiDk@uI`MiBpHgAfHmAvKgBpA~RFlADd@t@Kt@Mu@Lu@JEe@GmAqA_SUsCCAGECK?MFIBA@?Ag@Ai@BuA~BaJh@uBFs@OkDxFy@YiE`AjOhAnPl@dJzEs@"),
//     bounds: Optional(
//       TonyNzCapacitorGoogleMaps.GoogleMapsDirections.Response.Route.Bounds(
//         northeast: Optional(
//           TonyNzCapacitorGoogleMaps.GoogleMapsService.LocationCoordinate2D(
//             latitude: -43.3008508,
//             longitude: 172.6130653
//           )
//         ),
//         southwest: Optional(
//           TonyNzCapacitorGoogleMaps.GoogleMapsService.LocationCoordinate2D(
//             latitude: -43.3153568,
//             longitude: 172.5864263
//           )
//       )
//       )
//     ),
//     copyrights: Optional("Map data ©2023 Google"),
//     warnings: [],
//     fare: nil
//   )
// ]

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
