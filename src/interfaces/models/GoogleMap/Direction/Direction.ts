import { LatLng } from "../../LatLng";

export interface Direction {
  // mapId: string;
  // origin: LatLng;
  // destination: LatLng;
  // waypoints: LatLng[];
  // travelMode: TravelMode;
  // preferences?: DirectionPreferences;

  // wayPoints: [Place];
  // origin: Place;
  // destination: Place;
  origin: LatLng;
  destination: LatLng;
  waypoints: LatLng[];
  travelMode: TravelMode;
  alternatives: Boolean;
  avoid: [RouteRestriction];
  language: String;
  units: UnitSystem;
  region: String;
  arrivalTime: Date;
  departureTime: Date;
  trafficModel: TrafficMode;
  transitMode: TransitMode;
  transitRoutingPreference: TransitRoutingPreference;
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

export enum RouteRestriction {
  TOLLS = "tolls",
  FERRIES = "ferries",
  HIGHWAYS = "highways",
  INDOOR = "indoor",
}

export enum TrafficMode {
  BEST_GUESS = "best_guess",
  OPTIMISTIC = "optimistic",
  PESSIMISTIC = "pessimistic",
}

export enum TransitMode {
  BUS = "bus",
  SUBWAY = "subway",
  TRAIN = "train",
  TRAM = "tram",
  RAIL = "rail",
}

export enum TransitRoutingPreference {
  LESS_WALKING = "less_walking",
  FEWER_TRANSFERS = "fewer_transfers",
}
