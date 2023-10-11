import { LatLng } from "../../LatLng";
import { TravelMode, UnitSystem } from "./Direction";

export interface DirectionsPreferences {
  avoidHighways?: boolean;
  avoidTolls?: boolean;
  avoidFerries?: boolean;
  avoidIndoor?: boolean;
  avoidIndoorWalkways?: boolean;
  travelMode?: TravelMode;
  unitSystem?: UnitSystem;
  waypoints?: LatLng[];
}
