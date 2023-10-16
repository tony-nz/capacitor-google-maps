import { LatLng } from "../models/LatLng";
import { Direction } from "../models/GoogleMap/Direction/Direction";
import {
  DirectionPreferences,
  TravelMode,
} from "../models/GoogleMap/Direction/DirectionPreferences";

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
