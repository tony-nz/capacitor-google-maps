import { WebPlugin } from "@capacitor/core";

import {
  CapacitorGoogleMapsPlugin,
  InitializeOptions,
  CreateOptions,
  CreateResult,
  ElementFromPointResultOptions,
  AddMarkerOptions,
  MarkerResult,
} from "./definitions";

export class CapacitorGoogleMapsWeb extends WebPlugin
  implements CapacitorGoogleMapsPlugin {
  constructor() {
    super({
      name: "CapacitorGoogleMaps",
      platforms: ["web"],
    });
  }

  async initialize(_options: InitializeOptions): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async create(_options: CreateOptions): Promise<CreateResult> {
    throw this.unimplemented("Not implemented on web.");
  }

  async elementFromPointResult(
    _options: ElementFromPointResultOptions
  ): Promise<void> {
    throw this.unimplemented("Not implemented on web.");
  }

  async addMarker(_options: AddMarkerOptions): Promise<MarkerResult> {
    throw this.unimplemented("Not implemented on web.");
  }
}
