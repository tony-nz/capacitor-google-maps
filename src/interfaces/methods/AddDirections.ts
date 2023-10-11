import { LatLng } from "../models/LatLng";
import { Direction, TravelMode } from "../models/GoogleMap/Direction/Direction";
import { DirectionPreferences } from "../models/GoogleMap/Direction/DirectionPreferences";

export interface AddDirectionsOptions {
  mapId: string;
  origin: LatLng;
  destination: LatLng;
  travelMode: TravelMode;
  preferences?: DirectionPreferences;
}

export interface AddDirectionsResult {
  directions: Direction;
}
