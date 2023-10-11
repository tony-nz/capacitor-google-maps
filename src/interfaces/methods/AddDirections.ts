import { LatLng } from "../models/LatLng";
import { Direction, TravelMode } from "../models/GoogleMap/Direction/Direction";
import { DirectionsPreferences } from "../models/GoogleMap/Direction/DirectionPreferences";

export interface AddDirectionsOptions {
  mapId: string;
  origin: LatLng;
  destination: LatLng;
  travelMode: TravelMode;
  preferences?: DirectionsPreferences;
}

export interface AddDirectionsResult {
  directions: Direction;
}
