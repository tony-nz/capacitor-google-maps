import UIKit
import Capacitor
import GoogleMaps

class CustomMapView: UIViewController, GMSMapViewDelegate {
    var customMapViewEvents: CustomMapViewEvents!;

    var id: String!;

    var GMapView: GMSMapView!

    var savedCallbackIdForCreate: String!;

    var savedCallbackIdForDidTapInfoWindow: String!;

    var savedCallbackIdForDidCloseInfoWindow: String!;

    var savedCallbackIdForDidTapMap: String!;

    var savedCallbackIdForDidLongPressMap: String!;

    var savedCallbackIdForDidTapMarker: String!;
    var preventDefaultForDidTapMarker: Bool = false;

    var savedCallbackIdForDidBeginDraggingMarker: String!;

    var savedCallbackIdForDidDragMarker: String!;

    var savedCallbackIdForDidEndDraggingMarker: String!;

    var savedCallbackIdForDidTapMyLocationButton: String!;
    var preventDefaultForDidTapMyLocationButton: Bool = false;

    var savedCallbackIdForDidTapMyLocationDot: String!;

    var savedCallbackIdForDidTapPoi: String!;

    var savedCallbackIdForDidBeginMovingCamera: String!;
    var savedCallbackIdForDidMoveCamera: String!;
    var savedCallbackIdForDidEndMovingCamera: String!;

    // Custom info window properties
    var customInfoWindow: CustomInfoWindow?
    var currentSelectedMarker: GMSMarker?
    var isCustomInfoWindowEnabled: Bool = true
    var savedCallbackIdForDidTapCustomInfoWindowAction: String!

    static var EVENT_DID_TAP_INFO_WINDOW: String = "didTapInfoWindow";
    static var EVENT_DID_CLOSE_INFO_WINDOW: String = "didCloseInfoWindow";
    static var EVENT_DID_TAP_MAP: String = "didTapMap";
    static var EVENT_DID_LONG_PRESS_MAP: String = "didLongPressMap";
    static var EVENT_DID_TAP_MARKER: String = "didTapMarker";
    static var EVENT_DID_BEGIN_DRAGGING_MARKER: String = "didBeginDraggingMarker";
    static var EVENT_DID_DRAG_MARKER: String = "didDragMarker";
    static var EVENT_DID_END_DRAGGING_MARKER: String = "didEndDraggingMarker";
    static var EVENT_DID_TAP_MY_LOCATION_BUTTON: String = "didTapMyLocationButton";
    static var EVENT_DID_TAP_MY_LOCATION_DOT: String = "didTapMyLocationDot";
    static var EVENT_DID_TAP_POI: String = "didTapPoi";
    static var EVENT_DID_BEGIN_MOVING_CAMERA: String = "didBeginMovingCamera";
    static var EVENT_DID_MOVE_CAMERA: String = "didMoveCamera";
    static var EVENT_DID_END_MOVING_CAMERA: String = "didEndMovingCamera";
    static var EVENT_DID_TAP_CUSTOM_INFO_WINDOW_ACTION: String = "didTapCustomInfoWindowAction";

    var boundingRect = BoundingRect();
    var mapCameraPosition = MapCameraPosition();
    var mapPreferences = MapPreferences();

    // This allows you to initialise your custom UIViewController without a nib or bundle.
    convenience init(customMapViewEvents: CustomMapViewEvents) {
        self.init(nibName:nil, bundle:nil)
        self.customMapViewEvents = customMapViewEvents
        self.id = NSUUID().uuidString.lowercased()
    }

    // This extends the superclass.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        let frame = CGRect(x: self.boundingRect.x, y: self.boundingRect.y, width: self.boundingRect.width, height: self.boundingRect.height);
        
        let camera = self.mapCameraPosition.getCameraPosition();
        
        self.GMapView = GMSMapView.map(withFrame: frame, camera: camera);
        
        self.view = GMapView;

        self.invalidateMap();

        self.customMapViewEvents.lastResultForCallbackId(callbackId: savedCallbackIdForCreate, result: self.getResultForMap());
    }

    func invalidateMap() -> PluginCallResultData {
        // set gestures
        self.GMapView.settings.rotateGestures = self.mapPreferences.gestures.isRotateAllowed;
        self.GMapView.settings.scrollGestures = self.mapPreferences.gestures.isScrollAllowed;
        self.GMapView.settings.allowScrollGesturesDuringRotateOrZoom = self.mapPreferences.gestures.isScrollAllowedDuringRotateOrZoom;
        self.GMapView.settings.tiltGestures = self.mapPreferences.gestures.isTiltAllowed;
        self.GMapView.settings.zoomGestures = self.mapPreferences.gestures.isZoomAllowed;

        // set controls
        self.GMapView.settings.compassButton = self.mapPreferences.controls.isCompassButtonEnabled;
        self.GMapView.settings.indoorPicker = self.mapPreferences.controls.isIndoorLevelPickerEnabled;
        self.GMapView.settings.myLocationButton = self.mapPreferences.controls.isMyLocationButtonEnabled;

        // set appearance
        self.GMapView.mapType = self.mapPreferences.appearance.type;
        self.GMapView.mapStyle = self.mapPreferences.appearance.style;
        self.GMapView.isBuildingsEnabled = self.mapPreferences.appearance.isBuildingsShown;
        self.GMapView.isIndoorEnabled = self.mapPreferences.appearance.isIndoorShown;
        self.GMapView.isMyLocationEnabled = self.mapPreferences.appearance.isMyLocationDotShown;
        self.GMapView.isTrafficEnabled = self.mapPreferences.appearance.isTrafficShown;
        
        return self.getResultForMap();
    }
    
    func getMap() -> PluginCallResultData {
        return self.getResultForMap();
    }
    
    func clearMap() {
        if (self.GMapView != nil) {
            self.GMapView.clear();
            hideCustomInfoWindow()
        }
    }
    
    public func getCameraPosition() -> GMSCameraPosition? {
        if (self.GMapView != nil) {
            return self.GMapView.camera;
        }
        return nil;
    }
    
    public func moveCamera(_ duration: Int?) {
        let camera = self.mapCameraPosition.getCameraPosition()
        
        if (duration == nil || duration == 0) {
            self.GMapView.camera = camera
        } else {
            let durationFloat: Float = Float(duration ?? 1000) / 1000
            
            CATransaction.begin()
            CATransaction.setValue(durationFloat, forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock({
             // Transaction completed
            })
            self.GMapView.animate(to: camera)
            CATransaction.commit()
        }
    }

    public func setCallbackIdForEvent(callbackId: String!, eventName: String!, preventDefault: Bool!) {
        if (callbackId != nil && eventName != nil) {
            if (eventName == CustomMapView.EVENT_DID_TAP_INFO_WINDOW) {
                savedCallbackIdForDidTapInfoWindow = callbackId;
            } else if (eventName == CustomMapView.EVENT_DID_CLOSE_INFO_WINDOW) {
                savedCallbackIdForDidCloseInfoWindow = callbackId;
            } else if (eventName == CustomMapView.EVENT_DID_TAP_MAP) {
                savedCallbackIdForDidTapMap = callbackId;
            } else if (eventName == CustomMapView.EVENT_DID_LONG_PRESS_MAP) {
                savedCallbackIdForDidLongPressMap = callbackId;
            } else if (eventName == CustomMapView.EVENT_DID_TAP_MARKER) {
                savedCallbackIdForDidTapMarker = callbackId;
                preventDefaultForDidTapMarker = preventDefault ?? false;
            } else if (eventName == CustomMapView.EVENT_DID_BEGIN_DRAGGING_MARKER) {
                savedCallbackIdForDidBeginDraggingMarker = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_DRAG_MARKER) {
                savedCallbackIdForDidDragMarker = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_END_DRAGGING_MARKER) {
                savedCallbackIdForDidEndDraggingMarker = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_TAP_MY_LOCATION_BUTTON) {
                savedCallbackIdForDidTapMyLocationButton = callbackId;
                preventDefaultForDidTapMyLocationButton = preventDefault ?? false;
            } else if (eventName == CustomMapView.EVENT_DID_TAP_MY_LOCATION_DOT) {
                savedCallbackIdForDidTapMyLocationDot = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_TAP_POI) {
                savedCallbackIdForDidTapPoi = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_BEGIN_MOVING_CAMERA) {
                savedCallbackIdForDidBeginMovingCamera = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_MOVE_CAMERA) {
                savedCallbackIdForDidMoveCamera = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_END_MOVING_CAMERA) {
                savedCallbackIdForDidEndMovingCamera = callbackId
            } else if (eventName == CustomMapView.EVENT_DID_TAP_CUSTOM_INFO_WINDOW_ACTION) {
                savedCallbackIdForDidTapCustomInfoWindowAction = callbackId
            }
        }
    }

    // MARK: - Custom Info Window Methods
    
    private func showCustomInfoWindow(for marker: GMSMarker) {
        hideCustomInfoWindow()
        
        customInfoWindow = CustomInfoWindow()
        customInfoWindow?.configure(with: marker, mapId: self.id, customMapViewEvents: customMapViewEvents, callbackId: savedCallbackIdForDidTapCustomInfoWindowAction)
        
        if let infoWindow = customInfoWindow {
            self.view.addSubview(infoWindow)
            updateCustomInfoWindowPosition(for: marker)
            currentSelectedMarker = marker
        }
    }
    
    public func hideCustomInfoWindow() {
        customInfoWindow?.removeFromSuperview()
        customInfoWindow = nil
        currentSelectedMarker = nil
    }
    
    private func updateCustomInfoWindowPosition(for marker: GMSMarker) {
        guard let infoWindow = customInfoWindow else { return }
        
        // Force layout to get the actual size
        infoWindow.setNeedsLayout()
        infoWindow.layoutIfNeeded()
        
        let markerPosition = GMapView.projection.point(for: marker.position)
        
        // Use custom offset values from the info window
        let offsetX = infoWindow.offsetX
        let offsetY = infoWindow.offsetY
        
        // Position the info window with custom offset
        let infoWindowX = markerPosition.x - (infoWindow.frame.width / 2) + offsetX
        let infoWindowY = markerPosition.y - infoWindow.frame.height + offsetY
        
        infoWindow.center = CGPoint(x: markerPosition.x + offsetX, y: infoWindowY + (infoWindow.frame.height / 2))
        
        // Ensure the info window stays within the map bounds
        let mapBounds = self.view.bounds
        if infoWindow.frame.minX < mapBounds.minX {
            infoWindow.frame.origin.x = mapBounds.minX + 10
        } else if infoWindow.frame.maxX > mapBounds.maxX {
            infoWindow.frame.origin.x = mapBounds.maxX - infoWindow.frame.width - 10
        }
        
        if infoWindow.frame.minY < mapBounds.minY {
            // If info window would go above the map, show it below the marker instead
            infoWindow.center = CGPoint(x: markerPosition.x + offsetX, y: markerPosition.y + infoWindow.frame.height / 2 + abs(offsetY) + 10)
        }
    }
    
    // Check if marker has custom info window data
    private func hasCustomInfoWindow(marker: GMSMarker) -> Bool {
        guard let userData = marker.userData as? JSObject,
              let metadata = userData["metadata"] as? JSObject,
              let _ = metadata["infoWindow"] as? JSObject else {
            return false
        }
        return true
    }

    // MARK: - GMSMapViewDelegate Methods

    // Override the default info window to return empty view for custom info windows
    internal func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if isCustomInfoWindowEnabled && hasCustomInfoWindow(marker: marker) {
            return UIView() // Return empty view to disable default info window
        }
        return nil // Use default info window
    }

    internal func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapInfoWindow != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker, mapId: self.id);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapInfoWindow, result: result);
        }
    }

    internal func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidCloseInfoWindow != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker, mapId: self.id);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidCloseInfoWindow, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // Hide custom info window when tapping on the map
        hideCustomInfoWindow()
        
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMap != nil) {
            let result: PluginCallResultData = self.getResultForPosition(coordinate: coordinate);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMap, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if (customMapViewEvents != nil && savedCallbackIdForDidLongPressMap != nil) {
            let result: PluginCallResultData = self.getResultForPosition(coordinate: coordinate);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidLongPressMap, result: result);
        }
    }

    internal func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Handle custom info window display
        if isCustomInfoWindowEnabled && hasCustomInfoWindow(marker: marker) {
            showCustomInfoWindow(for: marker)
        } else {
            hideCustomInfoWindow()
        }
        
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMarker != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker, mapId: self.id);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMarker, result: result);
        }
        return preventDefaultForDidTapMarker;
    }
    
    internal func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidBeginDraggingMarker != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker, mapId: self.id);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidBeginDraggingMarker, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidDragMarker != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker, mapId: self.id);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidDragMarker, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidEndDraggingMarker != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker, mapId: self.id);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidEndDraggingMarker, result: result);
        }
    }
    
    internal func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMyLocationButton != nil) {
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMyLocationButton, result: nil);
        }
        return preventDefaultForDidTapMyLocationButton;
    }

    internal func mapView(_ mapView: GMSMapView, didTapMyLocation coordinate: CLLocationCoordinate2D) {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMyLocationDot != nil) {
            let result: PluginCallResultData = self.getResultForPosition(coordinate: coordinate);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMyLocationDot, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapPoi != nil) {
            let result: PluginCallResultData = [
                "poi": [
                    "position": [
                        "latitude": location.latitude,
                        "longitude": location.longitude
                    ],
                    "name": name,
                    "placeId": placeID
                ]
            ];
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapPoi, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (customMapViewEvents != nil && savedCallbackIdForDidBeginMovingCamera != nil) {
            var reason: Int = 2;
            if (gesture) {
                // Camera motion initiated in response to user gestures on the map.
                // For example: pan, tilt, pinch to zoom, or rotate.
                reason = 1;
            }
            let result: PluginCallResultData = [
                "reason": reason
            ];
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidBeginMovingCamera, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // Update custom info window position when camera moves
        if let marker = currentSelectedMarker {
            updateCustomInfoWindowPosition(for: marker)
        }
        
        if (customMapViewEvents != nil && savedCallbackIdForDidMoveCamera != nil) {
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidMoveCamera, result: nil);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if (customMapViewEvents != nil && savedCallbackIdForDidEndMovingCamera != nil) {
            let result: PluginCallResultData = [
                "cameraPosition": self.mapCameraPosition.getJSObject(self.getCameraPosition() ?? GMSCameraPosition())
            ];
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidEndMovingCamera, result: result);
        }
    }
    
    private func getResultForMap() -> PluginCallResultData {
        return [
            "googleMap": [
                "mapId": self.id ?? "",
                "cameraPosition": self.mapCameraPosition.getJSObject(self.getCameraPosition() ?? GMSCameraPosition()),
                "preferences": [
                    "gestures": self.mapPreferences.gestures.getJSObject(self.GMapView),
                    "controls": self.mapPreferences.controls.getJSObject(self.GMapView),
                    "appearance": self.mapPreferences.appearance.getJSObject(self.GMapView)
                ]
            ]
        ]
    }

    private func getResultForPosition(coordinate: CLLocationCoordinate2D) -> PluginCallResultData {
        return [
            "position": [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
        ]
    }

    func triggerInfoWindowClick(for marker: GMSMarker) {
      // Run UI updates on the main thread
      DispatchQueue.main.async {
        if self.isCustomInfoWindowEnabled && self.hasCustomInfoWindow(marker: marker) {
            self.showCustomInfoWindow(for: marker)
        } else {
            self.GMapView.selectedMarker = marker
        }
      }
    }

}
