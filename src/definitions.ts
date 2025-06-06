import { PluginListenerHandle } from "@capacitor/core";

import {
  // methods
  InitializeOptions,
  CreateMapOptions,
  GetLocationResult,
  CreateMapResult,
  UpdateMapOptions,
  UpdateMapResult,
  RemoveMapOptions,
  ClearMapOptions,
  MoveCameraOptions,
  ElementFromPointResultOptions,
  AddMarkerOptions,
  AddMarkerResult,
  AddMarkersOptions,
  AddMarkersResult,
  RemoveMarkerOptions,
  UpdateMarkerOptions,
  AddPolygonOptions,
  AddPolygonResult,
  RemovePolygonOptions,
  AddPolylineOptions,
  AddPolylineResult,
  RemovePolylineOptions,
  TriggerInfoWindowOptions,
  GetDirectionsOptions,
  EnableCustomInfoWindowsOptions,
  EnableCustomInfoWindowsResult,
  // events
  DidTapInfoWindowCallback,
  DidCloseInfoWindowCallback,
  DidTapMapCallback,
  DidLongPressMapCallback,
  DidTapMarkerCallback,
  DidBeginDraggingMarkerCallback,
  DidDragMarkerCallback,
  DidEndDraggingMarkerCallback,
  DidTapMyLocationButtonCallback,
  DidTapMyLocationDotCallback,
  DidTapPoiCallback,
  DidBeginMovingCameraCallback,
  DidMoveCameraCallback,
  DidEndMovingCameraCallback,
  DidTapCustomInfoWindowActionCallback,
} from "./interfaces";

export type CallbackID = string;

export interface DefaultEventOptions {
  mapId: string;
}

export interface DefaultEventWithPreventDefaultOptions {
  mapId: string;
  preventDefault?: boolean;
}

export interface DidRequestElementFromPointResult {
  eventChainId: string;
  point?: {
    x: number;
    y: number;
  };
}

export interface CapacitorGoogleMapsPlugin {
  initialize(options: InitializeOptions): Promise<void>;

  getLocation(): Promise<GetLocationResult>;

  createMap(options: CreateMapOptions): Promise<CreateMapResult>;

  updateMap(options: UpdateMapOptions): Promise<UpdateMapResult>;

  removeMap(options: RemoveMapOptions): Promise<void>;

  clearMap(options: ClearMapOptions): Promise<void>;

  moveCamera(options: MoveCameraOptions): Promise<void>;

  addMarker(options: AddMarkerOptions): Promise<AddMarkerResult>;

  addMarkers(options: AddMarkersOptions): Promise<AddMarkersResult>;

  removeMarker(options: RemoveMarkerOptions): Promise<void>;

  updateMarker(options: UpdateMarkerOptions): Promise<UpdateMapResult>;

  addPolygon(options: AddPolygonOptions): Promise<AddPolygonResult>;

  removePolygon(options: RemovePolygonOptions): Promise<void>;

  addPolyline(options: AddPolylineOptions): Promise<AddPolylineResult>;

  removePolyline(options: RemovePolylineOptions): Promise<void>;

  triggerInfoWindow(options: TriggerInfoWindowOptions): Promise<void>;

  getDirections(options: GetDirectionsOptions): Promise<void>;

  enableCustomInfoWindows(
    options: EnableCustomInfoWindowsOptions
  ): Promise<EnableCustomInfoWindowsResult>;

  didTapInfoWindow(
    options: DefaultEventOptions,
    callback: DidTapInfoWindowCallback
  ): Promise<CallbackID>;

  didCloseInfoWindow(
    options: DefaultEventOptions,
    callback: DidCloseInfoWindowCallback
  ): Promise<CallbackID>;

  didTapMap(
    options: DefaultEventOptions,
    callback: DidTapMapCallback
  ): Promise<CallbackID>;

  didLongPressMap(
    options: DefaultEventOptions,
    callback: DidLongPressMapCallback
  ): Promise<CallbackID>;

  didTapMarker(
    options: DefaultEventWithPreventDefaultOptions,
    callback: DidTapMarkerCallback
  ): Promise<CallbackID>;

  didBeginDraggingMarker(
    options: DefaultEventOptions,
    callback: DidBeginDraggingMarkerCallback
  ): Promise<CallbackID>;

  didDragMarker(
    options: DefaultEventOptions,
    callback: DidDragMarkerCallback
  ): Promise<CallbackID>;

  didEndDraggingMarker(
    options: DefaultEventOptions,
    callback: DidEndDraggingMarkerCallback
  ): Promise<CallbackID>;

  didTapMyLocationButton(
    options: DefaultEventWithPreventDefaultOptions,
    callback: DidTapMyLocationButtonCallback
  ): Promise<CallbackID>;

  didTapMyLocationDot(
    options: DefaultEventOptions,
    callback: DidTapMyLocationDotCallback
  ): Promise<CallbackID>;

  didTapPoi(
    options: DefaultEventOptions,
    callback: DidTapPoiCallback
  ): Promise<CallbackID>;

  didBeginMovingCamera(
    options: DefaultEventOptions,
    callback: DidBeginMovingCameraCallback
  ): Promise<CallbackID>;

  didMoveCamera(
    options: DefaultEventOptions,
    callback: DidMoveCameraCallback
  ): Promise<CallbackID>;

  didEndMovingCamera(
    options: DefaultEventOptions,
    callback: DidEndMovingCameraCallback
  ): Promise<CallbackID>;

  /**
   * After `didRequestElementFromPoint` fires, this method is used to let the WebView know whether or not to delegate the touch event to a certain MapView.
   * It is handled automatically and you should probably not use it.
   */
  elementFromPointResult(options: ElementFromPointResultOptions): Promise<void>;

  /**
   * This listens for touch events on the WebView.
   * It is handled automatically and you should probably not use it.
   */
  addListener(
    eventName: "didRequestElementFromPoint",
    listenerFunc: (result: DidRequestElementFromPointResult) => void
  ): PluginListenerHandle;

  didTapCustomInfoWindowAction(
    options: DefaultEventOptions,
    callback: DidTapCustomInfoWindowActionCallback
  ): Promise<CallbackID>;
}

export * from "./interfaces";

// methods to implement:
// - GoogleMap.animateCamera
// - GoogleMap.snapshot
// - GoogleMap.setInfoWindowAdapter (HTMLElement)

// listeners to implement:
// - a lot
