import { LatLng } from "../../LatLng";

export interface DirectionPreferences {
  avoidHighways?: boolean;
  avoidTolls?: boolean;
  avoidFerries?: boolean;
  avoidIndoor?: boolean;
  avoidIndoorWalkways?: boolean;
  travelMode?: TravelMode;
  unitSystem?: UnitSystem;
  waypoints?: LatLng[];
}

export enum TravelMode {
  DRIVING = "DRIVING",
  WALKING = "WALKING",
  BICYCLING = "BICYCLING",
  TRANSIT = "TRANSIT",
}

export enum UnitSystem {
  METRIC = "METRIC",
  IMPERIAL = "IMPERIAL",
}
