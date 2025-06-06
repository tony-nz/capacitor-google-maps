import { WebPlugin } from "@capacitor/core";

import {
  CapacitorGoogleMapsPlugin,
  CallbackID,
  InitializeOptions,
  GetLocationResult,
  CreateMapOptions,
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
  UpdateMarkerOptions,
  RemoveMarkerOptions,
  AddPolygonOptions,
  AddPolygonResult,
  RemovePolygonOptions,
  AddPolylineOptions,
  AddPolylineResult,
  RemovePolylineOptions,
  GetDirectionsOptions,
  TriggerInfoWindowOptions,
  EnableCustomInfoWindowsOptions,
  EnableCustomInfoWindowsResult,
  // AddDirectionsResult,
  DidTapInfoWindowCallback,
  DidCloseInfoWindowCallback,
  DidTapCustomInfoWindowActionCallback,
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
  DefaultEventOptions,
  DefaultEventWithPreventDefaultOptions,
} from "./definitions";
// @ts-ignore
export class CapacitorGoogleMapsWeb
  extends WebPlugin
  implements CapacitorGoogleMapsPlugin
{
  constructor() {
    super({
      name: "CapacitorGoogleMaps",
      platforms: ["web"],
    });
  }

  async initialize(_options: InitializeOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async getLocation(): Promise<GetLocationResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async createMap(_options: CreateMapOptions): Promise<CreateMapResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async removeMap(_options: RemoveMapOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async clearMap(_options: ClearMapOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async updateMap(_options: UpdateMapOptions): Promise<UpdateMapResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async moveCamera(_options: MoveCameraOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async addMarker(_options: AddMarkerOptions): Promise<AddMarkerResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async addMarkers(_options: AddMarkersOptions): Promise<AddMarkersResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async removeMarker(_options: RemoveMarkerOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async updateMarker(_options: UpdateMarkerOptions): Promise<UpdateMapResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async addPolygon(_options: AddPolygonOptions): Promise<AddPolygonResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async removePolygon(_options: RemovePolygonOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async addPolyline(_options: AddPolylineOptions): Promise<AddPolylineResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async removePolyline(_options: RemovePolylineOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async triggerInfoWindow(_options: TriggerInfoWindowOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async getDirections(_options: GetDirectionsOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async enableCustomInfoWindows(
    _options: EnableCustomInfoWindowsOptions
  ): Promise<EnableCustomInfoWindowsResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapInfoWindow(
    _options: DefaultEventOptions,
    _callback: DidTapInfoWindowCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didCloseInfoWindow(
    _options: DefaultEventOptions,
    _callback: DidCloseInfoWindowCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapMap(
    _options: DefaultEventOptions,
    _callback: DidTapMapCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didLongPressMap(
    _options: DefaultEventOptions,
    _callback: DidLongPressMapCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapMarker(
    _options: DefaultEventWithPreventDefaultOptions,
    _callback: DidTapMarkerCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didBeginDraggingMarker(
    _options: DefaultEventOptions,
    _callback: DidBeginDraggingMarkerCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didDragMarker(
    _options: DefaultEventOptions,
    _callback: DidDragMarkerCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didEndDraggingMarker(
    _options: DefaultEventOptions,
    _callback: DidEndDraggingMarkerCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapMyLocationButton(
    _options: DefaultEventWithPreventDefaultOptions,
    _callback: DidTapMyLocationButtonCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapMyLocationDot(
    _options: DefaultEventWithPreventDefaultOptions,
    _callback: DidTapMyLocationDotCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapPoi(
    _options: DefaultEventOptions,
    _callback: DidTapPoiCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didBeginMovingCamera(
    _options: DefaultEventOptions,
    _callback: DidBeginMovingCameraCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didMoveCamera(
    _options: DefaultEventOptions,
    _callback: DidMoveCameraCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didEndMovingCamera(
    _options: DefaultEventOptions,
    _callback: DidEndMovingCameraCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async didTapCustomInfoWindowAction(
    _options: DefaultEventOptions,
    _callback: DidTapCustomInfoWindowActionCallback
  ): Promise<CallbackID> {
    throw this.unimplemented("Not implemented on web.");
  }

  async elementFromPointResult(
    _options: ElementFromPointResultOptions
  ): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }
}
