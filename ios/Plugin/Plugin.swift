import Foundation
import Capacitor
import GoogleMaps
import CoreLocation

// not needed but useful for decoding polyline points
func decodePolyline(_ polylinePoints: String) -> [CLLocationCoordinate2D] {
    var coordinates = [CLLocationCoordinate2D]()
    
    var index = polylinePoints.startIndex
    var lat = 0
    var lng = 0
    
    while index < polylinePoints.endIndex {
        var shift: UInt = 0
        var result: Int = 0

        var byte: UInt8 = 0
        var counter: UInt = 0

        repeat {
            guard index < polylinePoints.endIndex else { break }
            byte = UInt8(polylinePoints[index].unicodeScalars.first!.value - 63)
            index = polylinePoints.index(after: index)
            result |= (Int(byte & 0x1F) << shift)
            shift += 5
            counter += 1
        } while byte >= 0x20

        let dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
        lat += dlat

        shift = 0
        result = 0

        counter = 0

        repeat {
            guard index < polylinePoints.endIndex else { break }
            byte = UInt8(polylinePoints[index].unicodeScalars.first!.value - 63)
            index = polylinePoints.index(after: index)
            result |= (Int(byte & 0x1F) << shift)
            shift += 5
            counter += 1
        } while byte >= 0x20

        let dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
        lng += dlng

        let latitude = Double(lat) / 1e5
        let longitude = Double(lng) / 1e5

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        coordinates.append(coordinate)
    }
    return coordinates
}

@objc(CapacitorGoogleMaps)
public class CapacitorGoogleMaps: CustomMapViewEvents, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    
    var GOOGLE_MAPS_KEY: String = "";

    var customMarkers = [String : CustomMarker]();
    
    var customPolygons = [String: CustomPolygon]();

    var customPolylines = [String: CustomPolyline]();

    var customDirections = [String: CustomDirection]();

    // private let googleMapsDirections = GoogleMapsDirections()
    // public typealias Route = googleMapsDirections.Route

    var customWebView: CustomWKWebView?

    @objc func initialize(_ call: CAPPluginCall) {
        self.GOOGLE_MAPS_KEY = call.getString("key", "")

        if self.GOOGLE_MAPS_KEY.isEmpty {
            call.reject("GOOGLE MAPS API key missing!")
            return
        }

        GMSServices.provideAPIKey(self.GOOGLE_MAPS_KEY)

        self.customWebView = self.bridge?.webView as? CustomWKWebView

        DispatchQueue.main.async {
            // remove all custom maps views from the main view
            if let values = self.customWebView?.customMapViews.map({ $0.value }) {
                CAPLog.print("mapId \(values)")
                for mapView in values {
                    (mapView as CustomMapView).view.removeFromSuperview()
                }
            }
            // reset custom map views holder
            self.customWebView?.customMapViews = [:]
        }

        call.resolve([
            "initialized": true
        ])
    }

    @objc func getLocation(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager = CLLocationManager() // Explicitly use 'self'
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.requestWhenInUseAuthorization()
                self.locationManager?.startUpdatingLocation()

                // Save the plugin call to resolve later
                self.bridge?.saveCall(call) // Explicitly use 'self'
            } else {
                call.reject("Location services are not enabled")
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let result: [String: Double] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]

            // Resolve the saved call using the new method
            if let savedCall = self.bridge?.savedCall(withID: "getLocation") {
                savedCall.resolve(result)
            }
            manager.stopUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Reject the saved call using the new method
        if let savedCall = self.bridge?.savedCall(withID: "getLocation") {
            savedCall.reject("Failed to get location: \(error.localizedDescription)")
        }
    }
    
    @objc func createMap(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let customMapView : CustomMapView = CustomMapView(customMapViewEvents: self)

            self.bridge?.saveCall(call)
            customMapView.savedCallbackIdForCreate = call.callbackId

            let boundingRect = call.getObject("boundingRect", JSObject())
            customMapView.boundingRect.updateFromJSObject(boundingRect)

            let mapCameraPosition = call.getObject("cameraPosition", JSObject())
            customMapView.mapCameraPosition.updateFromJSObject(mapCameraPosition, baseCameraPosition: nil)

            let preferences = call.getObject("preferences", JSObject())
            customMapView.mapPreferences.updateFromJSObject(preferences)

            self.customWebView?.scrollView.addSubview(customMapView.view)

            if (customMapView.GMapView == nil) {
                call.reject("Map could not be created. Did you forget to update the class in Main.storyboard? If you do not know what that is, please read the documentation.")
                return
            }

            self.customWebView?.scrollView.sendSubviewToBack(customMapView.view)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.setupWebView()
            }

            customMapView.GMapView.delegate = customMapView;
            self.customWebView?.customMapViews[customMapView.id] = customMapView
        }
    }
    
    @objc func updateMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            let preferences = call.getObject("preferences", JSObject());
            customMapView.mapPreferences.updateFromJSObject(preferences);
            
            let result = customMapView.invalidateMap()
            
            call.resolve(result)
        }

    }


    @objc func removeMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            (customMapView).view.removeFromSuperview()
            self.customWebView?.customMapViews.removeValue(forKey: mapId)

            call.resolve()
        }
    }
    
    @objc func getMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            let result = customMapView.getMap()
            
            call.resolve(result)
        }

    }
    
    @objc func clearMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            let result: () = customMapView.clearMap()
            
            call.resolve()
        }

    }

    @objc func moveCamera(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            let mapCameraPosition = customMapView.mapCameraPosition

            var currentCameraPosition: GMSCameraPosition?;

            let useCurrentCameraPositionAsBase = call.getBool("useCurrentCameraPositionAsBase", true)

            if (useCurrentCameraPositionAsBase) {
                currentCameraPosition = customMapView.getCameraPosition()
            }

            let cameraPosition = call.getObject("cameraPosition", JSObject())
            mapCameraPosition.updateFromJSObject(cameraPosition, baseCameraPosition: currentCameraPosition)

            let duration = call.getInt("duration", 0)

            customMapView.moveCamera(duration)

            call.resolve()
        }
    }

    @objc func addMarker(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            let position = call.getObject("position", JSObject())
            let preferences = call.getObject("preferences", JSObject())

            self.addMarker([
                "position": position,
                "preferences": preferences
            ], customMapView: customMapView) { marker in
                call.resolve(CustomMarker.getResultForMarker(marker, mapId: mapId))
            }
        }
    }

    @objc func addMarkers(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        guard let customMapView = self.customWebView?.customMapViews[mapId] else {
            call.reject("map not found")
            return
        }

        if let markers = call.getArray("markers")?.capacitor.replacingNullValues() as? [JSObject?] {
            // Group markers by icon url and size
            let markersGroupedByIcon = Dictionary(grouping: markers) { (marker) -> String in
                let preferences = marker?["preferences"] as? JSObject ?? JSObject()

                if let icon = preferences["icon"] as? JSObject {
                    if let url = icon["url"] as? String {
                        let size = icon["size"] as? JSObject ?? JSObject()
                        let resizeWidth = size["width"] as? Int ?? 30
                        let resizeHeight = size["height"] as? Int ?? 30
                        
                        // Generate custom key based on the size,
                        // so we can cache the resized variant of the image as well.
                        let groupByKey = "\(url)\(resizeWidth)\(resizeHeight)"
                        
                        return groupByKey
                    }
                }
                
                return ""
            }
            
            for markersGroup in markersGroupedByIcon {
                // Get the icon for this group by using the first marker value
                // (which should be the same as the following ones, since they are grouped by icon).
                if let firstMarker = markersGroup.value[0] {
                    let preferences = firstMarker["preferences"] as? JSObject ?? JSObject()

                    if let icon = preferences["icon"] as? JSObject {
                        if let url = icon["url"] as? String {
                            let size = icon["size"] as? JSObject ?? JSObject()
                            let resizeWidth = size["width"] as? Int ?? 30
                            let resizeHeight = size["height"] as? Int ?? 30

                            // Preload this icon into the cache.
                            self.imageCache.image(at: url, resizeWidth: resizeWidth, resizeHeight: resizeHeight) { image in
                                // Since the icon is already loaded,
                                // it is now possible to quickly render all the markers with this icon.
                                for marker in markersGroup.value {
                                    let position = marker?["position"] as? JSObject ?? JSObject();
                                    let preferences = marker?["preferences"] as? JSObject ?? JSObject();

                                    self.addMarker([
                                        "position": position,
                                        "preferences": preferences
                                    ], customMapView: customMapView) { marker in
                                        // Image is loaded
                                    }
                                }
                            }
                            
                            continue
                        }
                    }
                }
                
                // Render all markers on the map without a custom icon attached to them.
                for marker in markersGroup.value {
                    let position = marker?["position"] as? JSObject ?? JSObject();
                    let preferences = marker?["preferences"] as? JSObject ?? JSObject();

                    self.addMarker([
                        "position": position,
                        "preferences": preferences
                    ], customMapView: customMapView) { marker in
                        // Image is loaded
                    }
                }
            }
        }

        call.resolve()
    }

    @objc func removeMarker(_ call: CAPPluginCall) {
        let markerId: String = call.getString("markerId", "");

        DispatchQueue.main.async {
            let customMarker = self.customMarkers[markerId];

            if (customMarker != nil) {
                customMarker?.map = nil;
                self.customMarkers[markerId] = nil;
                call.resolve();
            } else {
                call.reject("marker not found");
            }
        }
    }
    
    @objc func updateMarker(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")
        let markerId: String = call.getString("markerId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            let position = call.getObject("position", JSObject())
            let preferences = call.getObject("preferences", JSObject())
            self.updateMarker(markerId: markerId, newMarkerData: [
                "position": position,
                "preferences": preferences
            ], customMapView: customMapView) { marker in
                call.resolve(CustomMarker.getResultForMarker(marker, mapId: mapId))
            }
        }
    }


    @objc func addPolygon(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "");

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            if let path = call.getArray("path")?.capacitor.replacingNullValues() as? [JSObject?] {
                let preferences = call.getObject("preferences", JSObject())

                self.addPolygon([
                    "path": path,
                    "preferences": preferences
                ], customMapView: customMapView) { polygon in
                    call.resolve(CustomPolygon.getResultForPolygon(polygon, mapId: mapId))
                }
            }
        }
    }
        
    @objc func removePolygon(_ call: CAPPluginCall) {
        let polygonId: String = call.getString("polygonId", "");

        DispatchQueue.main.async {
            if let customPolygon = self.customPolygons[polygonId] {
                customPolygon.map = nil;
                customPolygon.layer.removeFromSuperlayer()
                self.customPolygons[polygonId] = nil;
                call.resolve();
            } else {
                call.reject("polygon not found");
            }
        }
    }

    @objc func addPolyline(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "");

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            if let path = call.getArray("path")?.capacitor.replacingNullValues() as? [JSObject?] {
                let preferences = call.getObject("preferences", JSObject())

                self.addPolyline([
                    "path": path,
                    "preferences": preferences
                ], customMapView: customMapView) { polyline in
                    call.resolve(CustomPolyline.getResultForPolyline(polyline, mapId: mapId))
                }
            }
        }
    }
        
    @objc func removePolyline(_ call: CAPPluginCall) {
        let polylineId: String = call.getString("polylineId", "");

        DispatchQueue.main.async {
            if let customPolyline = self.customPolylines[polylineId] {
                customPolyline.map = nil;
                // customPolyline.layer.removeFromSuperlayer()
                self.customPolylines[polylineId] = nil;
                call.resolve();
            } else {
                call.reject("polyline not found");
            }
        }
    }

    @objc func getDirections(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            // Retrieve data from the call
            let origin = GoogleMapsService.Place.coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: call.getObject("origin")?["latitude"] as? Double ?? 0.0, longitude: call.getObject("origin")?["longitude"] as? Double ?? 0.0))
            let destination = GoogleMapsService.Place.coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: call.getObject("destination")?["latitude"] as? Double ?? 0.0, longitude: call.getObject("destination")?["longitude"] as? Double ?? 0.0))
            
            let travelMode: GoogleMapsDirections.TravelMode = (call.getObject("travelMode")?["travelMode"] as? String)
                .flatMap { GoogleMapsDirections.TravelMode(rawValue: $0) } ?? .driving

            let alternatives = call.getObject("alternatives")?["alternatives"] as? Bool ?? false
            let arrivalTime = call.getObject("arrivalTime")?["arrivalTime"] as? String
            let avoid = call.getObject("avoid")?["avoid"] as? [String]
            let departureTime = call.getObject("departureTime")?["departureTime"] as? String
            let language = call.getObject("language")?["language"] as? String
            let region = call.getObject("region")?["region"] as? String
            let transitMode = call.getObject("transitMode")?["transitMode"] as? String
            let trafficModel = call.getObject("trafficModel")?["trafficModel"] as? String
            let transitRoutingPreference = call.getObject("transitRoutingPreference")?["transitRoutingPreference"] as? String
            let units = call.getObject("units")?["units"] as? String

            var waypoints: [GoogleMapsService.Place] = []

            if let waypointsArray = call.getArray("waypoints") {
                for waypoint in waypointsArray {
                    if let waypointDict = waypoint as? [String: Any] {
                        if let latitude = waypointDict["latitude"] as? Double, let longitude = waypointDict["longitude"] as? Double {
                            // Create a coordinate-based Place
                            let coordinate = GoogleMapsService.LocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let waypointData = GoogleMapsService.Place.coordinate(coordinate: coordinate)
                            waypoints.append(waypointData)
                        } else if let address = waypointDict["address"] as? String {
                            // Create a Place with an address
                            waypoints.append(.stringDescription(address: address))
                        }
                    }
                }
            }

            // Google Maps Directions
            GoogleMapsDirections.provide(apiKey: self.GOOGLE_MAPS_KEY)
            GoogleMapsDirections.direction(
                fromOrigin: origin,
                toDestination: destination,
                travelMode: travelMode,
                wayPoints: waypoints
            ) { (response, error) -> Void in
                // Check Status Code and  if response is not nil
                guard response?.status == GoogleMapsDirections.StatusCode.ok else {
                    // Status Code is Not OK
                    print(response?.errorMessage ?? "")
                    return
                }
                guard let response = response else {
                    call.reject("Response is nil")
                    return
                }
                call.resolve(CustomDirection.getResultForDirection(response))
            }
        }
    }

    @objc func triggerInfoWindow(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let mapId = call.getString("mapId"),
                let markerId = call.getString("markerId") else {
                call.reject("Missing mapId or markerId")
                return
            }
            
            // Access the customMapView from customWebView
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("Map not found")
                return
            }
            
            // Now access the marker and trigger the info window click
            if let marker = self.customMarkers[markerId] {
                customMapView.triggerInfoWindowClick(for: marker)
                call.resolve()
            } else {
                call.reject("Marker not found")
            }
        }
    }

    @objc func didTapInfoWindow(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_INFO_WINDOW);
    }

    @objc func didCloseInfoWindow(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_CLOSE_INFO_WINDOW);
    }

    @objc func didTapMap(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MAP);
    }

    @objc func didLongPressMap(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_LONG_PRESS_MAP);
    }
    
    @objc func didTapMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MARKER);
    }
    
    @objc func didBeginDraggingMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_BEGIN_DRAGGING_MARKER);
    }
    
    @objc func didDragMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_DRAG_MARKER);
    }
    
    @objc func didEndDraggingMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_END_DRAGGING_MARKER);
    }
    
    @objc func didTapMyLocationButton(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MY_LOCATION_BUTTON);
    }

    @objc func didTapMyLocationDot(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MY_LOCATION_DOT);
    }
    
    @objc func didTapPoi(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_POI);
    }
    
    @objc func didBeginMovingCamera(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_BEGIN_MOVING_CAMERA);
    }
    
    @objc func didMoveCamera(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_MOVE_CAMERA);
    }
    
    @objc func didEndMovingCamera(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_END_MOVING_CAMERA);
    }

    @objc func enableCustomInfoWindows(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")
        let enabled: Bool = call.getBool("enabled", true)

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            customMapView.isCustomInfoWindowEnabled = enabled
            
            // If disabling custom info windows, hide any currently shown custom info window
            if !enabled {
                customMapView.hideCustomInfoWindow()
            }
            
            call.resolve([
                "enabled": enabled
            ])
        }
    }

    @objc func didTapCustomInfoWindowAction(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: "didTapCustomInfoWindowAction");
    }

    func setCallbackIdForEvent(call: CAPPluginCall, eventName: String) {
        let mapId: String = call.getString("mapId", "")

        guard let customMapView = self.customWebView?.customMapViews[mapId] else {
            call.reject("map not found")
            return
        }

        call.keepAlive = true;
        let callbackId = call.callbackId;

        let preventDefault: Bool = call.getBool("preventDefault", false);
        customMapView.setCallbackIdForEvent(callbackId: callbackId, eventName: eventName, preventDefault: preventDefault);
    }

    override func lastResultForCallbackId(callbackId: String, result: PluginCallResultData) {
        let call = bridge?.savedCall(withID: callbackId);
        call?.resolve(result);
        bridge?.releaseCall(call!);
    }

    override func resultForCallbackId(callbackId: String, result: PluginCallResultData?) {
        let call = bridge?.savedCall(withID: callbackId);
        if (result != nil) {
            call?.resolve(result!);
        } else {
            call?.resolve();
        }
    }
}

private extension CapacitorGoogleMaps {
    func addMarker(_ markerData: JSObject, customMapView: CustomMapView, completion: @escaping VoidReturnClosure<GMSMarker>) {
        DispatchQueue.main.async {
            let marker = CustomMarker()

            marker.updateFromJSObject(markerData)

            self.customMarkers[marker.id] = marker

            let preferences = markerData["preferences"] as? JSObject ?? JSObject()

            if let icon = preferences["icon"] as? JSObject {
                if let url = icon["url"] as? String {
                    let size = icon["size"] as? JSObject ?? JSObject()
                    let resizeWidth = size["width"] as? Int ?? 30
                    let resizeHeight = size["height"] as? Int ?? 30
                    DispatchQueue.global(qos: .background).async {
                        self.imageCache.image(at: url, resizeWidth: resizeWidth, resizeHeight: resizeHeight) { image in
                            DispatchQueue.main.async {
                                marker.icon = image
                                marker.map = customMapView.GMapView
                                completion(marker)
                            }
                        }
                    }
                    return
                }
            }

            marker.map = customMapView.GMapView

            completion(marker)
        }
    }

    func updateMarker(markerId: String, newMarkerData: JSObject, customMapView: CustomMapView, completion: @escaping VoidReturnClosure<GMSMarker>) {
        DispatchQueue.main.async {
            if let marker = self.customMarkers[markerId] {
                // Update the marker with the new data
                marker.updateFromJSObject(newMarkerData)

                let preferences = newMarkerData["preferences"] as? JSObject ?? JSObject()

                if let icon = preferences["icon"] as? JSObject {
                    if let url = icon["url"] as? String {
                        let size = icon["size"] as? JSObject ?? JSObject()
                        let resizeWidth = size["width"] as? Int ?? 130
                        let resizeHeight = size["height"] as? Int ?? 130
                        DispatchQueue.global(qos: .background).async {
                            self.imageCache.image(at: url, resizeWidth: resizeWidth, resizeHeight: resizeHeight) { image in
                                DispatchQueue.main.async {
                                    marker.icon = image
                                }
                            }
                        }
                    }
                }

                completion(marker)
            }
        }
    }

    
    func addPolygon(_ polygonData: JSObject, customMapView: CustomMapView, completion: @escaping VoidReturnClosure<GMSPolygon>) {
        DispatchQueue.main.async {
            let polygon = CustomPolygon()

            polygon.updateFromJSObject(polygonData)

            polygon.map = customMapView.GMapView

            self.customPolygons[polygon.id] = polygon

            completion(polygon)
        }
    }

    func addPolyline(_ polylineData: JSObject, customMapView: CustomMapView, completion: @escaping VoidReturnClosure<GMSPolyline>) {
        DispatchQueue.main.async {
            
            let polyline = CustomPolyline()

            polyline.updateFromJSObject(polylineData)

            polyline.map = customMapView.GMapView

            self.customPolylines[polyline.id] = polyline

            completion(polyline)
        }
    }

    func triggerInfoWindowClick(for markerId: String, customMapView: CustomMapView, completion: @escaping (Bool) -> Void) {
        // DispatchQueue.main.async {
        //     // Find the marker by markerId
        //     if let marker = self.customMarkers[markerId] {
        //         // Trigger info window click for the marker
        //         customMapView.triggerInfoWindowClick(for: marker)
        //         completion(true)
        //     } else {
        //         completion(false)
        //     }
        // }
    }

    func setupWebView() {
        DispatchQueue.main.async {
            self.customWebView?.isOpaque = false
            self.customWebView?.backgroundColor = .clear

            let javascript = "document.documentElement.style.backgroundColor = 'transparent'"
            self.customWebView?.evaluateJavaScript(javascript)
        }
    }
}

extension CapacitorGoogleMaps: ImageCachable {
    var imageCache: ImageURLLoadable {
        NativeImageCache.shared
    }
    var googleMapsDirections: GoogleMapsDirections {
        GoogleMapsDirections()
    }
    var googlePlaces: GooglePlaces {
        GooglePlaces()
    }

    public typealias Response = GoogleMapsDirections.Response

}
