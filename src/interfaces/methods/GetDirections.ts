import { LatLng } from "../models/LatLng";
import { DirectionResults } from "../models/GoogleMap/Direction/DirectionResults";
import {
  RouteRestriction,
  TrafficMode,
  TransitRoutingPreference,
  TransitMode,
  TravelMode,
  UnitSystem,
} from "../models/GoogleMap/Direction/Direction";

export interface GetDirectionsOptions {
  origin: LatLng;
  destination: LatLng;
  waypoints?: LatLng[];
  travelMode?: TravelMode;
  alternatives?: Boolean;
  avoid?: [RouteRestriction];
  language?: String;
  units?: UnitSystem;
  region?: String;
  arrivalTime?: Date;
  departureTime?: Date;
  trafficModel?: TrafficMode;
  transitMode?: TransitMode;
  transitRoutingPreference?: TransitRoutingPreference;
}

export interface GetDirectionsResult {
  result: DirectionResults;
}
