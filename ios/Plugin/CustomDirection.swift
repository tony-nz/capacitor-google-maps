import Foundation
import GoogleMaps
import Capacitor

class CustomDirection: GoogleMapsDirections {
    public typealias Response = GoogleMapsDirections.Response
    public typealias Route = GoogleMapsDirections.Response.Route

    var id: String! = NSUUID().uuidString.lowercased()
    
    public static func getResultForDirection(_ directionResults: Response) -> PluginCallResultData {
        // var results: PluginCallResultData = [:]

        // based on Response type, process the return data
        var result: PluginCallResultData = [
            "route": [
                "summary": directionResults.routes[0].summary ?? "",
                "waypointOrder": directionResults.routes[0].waypointOrder ,
                "overviewPolylinePoints": directionResults.routes[0].overviewPolylinePoints ?? "",
                "bounds": [
                    "northeast": [
                        "latitude": directionResults.routes[0].bounds?.northeast?.latitude ?? 0.0,
                        "longitude": directionResults.routes[0].bounds?.northeast?.longitude ?? 0.0
                    ],
                    "southwest": [
                        "latitude": directionResults.routes[0].bounds?.southwest?.latitude ?? 0.0,
                        "longitude": directionResults.routes[0].bounds?.southwest?.longitude ?? 0.0
                    ]
                ],
                "legs": []  // Initialize as an empty array
            ]
        ]

        // Process legs within the route
        var legs: [PluginCallResultData] = [] // Initialize as a regular array

        for leg in directionResults.routes[0].legs {
            var legData: JSObject = [
                "startAddress": leg.startAddress ?? "",
                "endAddress": leg.endAddress ?? "",
                "steps": []  // Initialize as an empty array
            ]

            if let startLocation = leg.startLocation, let endLocation = leg.endLocation {
                legData["startLocation"] = [
                    "latitude": startLocation.latitude,
                    "longitude": startLocation.longitude
                ]
                legData["endLocation"] = [
                    "latitude": endLocation.latitude,
                    "longitude": endLocation.longitude
                ]
            }

            if let distance = leg.distance {
                legData["distance"] = [
                    "text": distance.text ?? "",
                    "value": distance.value ?? 0.0
                ]
            }

            if let duration = leg.duration {
                legData["duration"] = [
                    "text": duration.text ?? "",
                    "value": duration.value ?? 0.0
                ]
            }

            // Process steps within the leg
            var steps: [PluginCallResultData] = [] // Initialize as a regular array
            for step in leg.steps {
                var stepData: JSObject = [
                    "htmlInstructions": step.htmlInstructions ?? "",
                    "distance": [
                        "text": step.distance?.text ?? "",
                        "value": step.distance?.value ?? 0.0
                    ],
                    "duration": [
                        "text": step.duration?.text ?? "",
                        "value": step.duration?.value ?? 0.0
                    ]
                ]

                if let startLocation = step.startLocation, let endLocation = step.endLocation {
                    stepData["startLocation"] = [
                        "latitude": startLocation.latitude,
                        "longitude": startLocation.longitude
                    ]
                    stepData["endLocation"] = [
                        "latitude": endLocation.latitude,
                        "longitude": endLocation.longitude
                    ]
                }
                
                if let travelMode = step.travelMode {
                    stepData["travelMode"] = travelMode.rawValue
                } else {
                    stepData["travelMode"] = "" // Provide a default value if it's nil
                }

                stepData["polylinePoints"] = step.polylinePoints ?? ""
                stepData["maneuver"] = step.maneuver ?? ""
                stepData["transitDetails"] = (step.transitDetails as? JSObject) ?? [:]

                steps.append(stepData)
            }

            legData["steps"] = steps // Set the "steps" array
            legs.append(legData)
        }

        result["legs"] = legs // Set the "legs" array

        return result
    }
}
