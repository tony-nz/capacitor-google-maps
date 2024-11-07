/**
  * Credit: Timileyin105 / https://github.com/Timileyin105
  * https://github.com/Timileyin105/capacitor-native-google-map/blob/master/ios/Plugin/CustomPolyline.swift
  */
import Foundation
import GoogleMaps
import Capacitor

class CustomPolyline : GMSPolyline {
    var id: String! = NSUUID().uuidString.lowercased();    
    
    public func updateFromJSObject(_ polylineData: JSObject) {
        let pathArray = polylineData["path"] as? [JSObject] ?? [JSObject]()
        let path = CustomPolyline.pathFromJson(pathArray)
        self.path = path

        let preferences = polylineData["preferences"] as? JSObject ?? JSObject()
        
        self.strokeWidth = preferences["width"] as? Double ?? 10.0
        
        if let color = preferences["color"] as? String {
            self.strokeColor = UIColor.capacitor.color(fromHex: color) ?? UIColor.black
        }
                
        self.title = preferences["title"] as? String ?? ""
        self.zIndex = Int32.init(preferences["zIndex"] as? Int ?? 1)
        self.geodesic = preferences["isGeodesic"] as? Bool ?? false
        self.isTappable = preferences["isClickable"] as? Bool ?? false
        
        let metadata: JSObject = preferences["metadata"] as? JSObject ?? JSObject()
        self.userData = [
            "polylineId": self.id!,
            "metadata": metadata
        ] as? JSObject ?? JSObject()
    }
    
    public static func getResultForPolyline(_ polyline: GMSPolyline, mapId: String) -> PluginCallResultData {
        // Get userData and ensure it's JSON-serializable
        let tag = polyline.userData as? JSObject ?? JSObject()
        
        // Convert strokeColor to hex string
        let colorHex = hexStringFromColor(polyline.strokeColor) // Convert UIColor to hex
        
        // Prepare the JSON-serializable result
        return [
            "polyline": [
                "mapId": mapId,
                "polylineId": tag["polylineId"] as? String ?? "",
                "path": CustomPolyline.jsonFromPath(polyline.path),  // Convert GMSPath to JSON array
                "preferences": [
                    "title": polyline.title ?? "",
                    "width": polyline.strokeWidth,
                    "color": colorHex,
                    "zIndex": polyline.zIndex,
                    "isGeodesic": polyline.geodesic,
                    "isClickable": polyline.isTappable,
                    "metadata": tag["metadata"] ?? JSObject()
                ]
            ]
        ]
    }
    
    private static func hexStringFromColor(_ color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    private static func jsonFromPath(_ path: GMSPath?) -> [JSObject] {
        guard let path = path else {
            return [JSObject]()
        }
        let size = path.count()
        var result: [JSObject] = []
        for i in stride(from: 0, to: size, by: 1) {
            let coord = path.coordinate(at: i)
            result.append(CustomPolyline.jsonFromCoord(coord))
        }
        return result
    }
    
    private static func jsonFromCoord(_ coord: CLLocationCoordinate2D) -> JSObject {
        return ["latitude" : coord.latitude, "longitude": coord.longitude]
    }
    
    private static func pathFromJson(_ latLngArray: [JSObject]) -> GMSPath {
        let path = GMSMutablePath()
        latLngArray.forEach { point in
            if let lat = point["latitude"] as? Double, let long = point["longitude"] as? Double {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                path.add(coord)
            }
        }
        
        return path as GMSPath
    }
}