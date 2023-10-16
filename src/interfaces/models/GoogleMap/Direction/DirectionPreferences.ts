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

export interface DirectionsStep {
  distance: Distance;
  duration: Duration;
  endLocation: LatLng;
  instructions: string;
  polyline: string;
  startLocation: LatLng;
  steps: DirectionsStep[];
  transitDetails: TransitDetails;
  travelMode: TravelMode;
}

export interface Distance {
  text: string;
  value: number;
}

export interface Duration {
  text: string;
  value: number;
}

export interface TransitDetails {
  arrivalStop: TransitStop;
  arrivalTime: TransitTime;
  departureStop: TransitStop;
  departureTime: TransitTime;
  headsign: string;
  headway: number;
  line: TransitLine;
  numStops: number;
}

export interface TransitStop {
  location: LatLng;
  name: string;
}

export interface TransitTime {
  text: string;
  value: number;
}

export interface TransitLine {
  agencies: TransitAgency[];
  color: string;
  icon: string;
  name: string;
  shortName: string;
  textColor: string;
  url: string;
  vehicle: TransitVehicle;
}

export interface TransitAgency {
  name: string;
  phone: string;
  url: string;
}

export interface TransitVehicle {
  icon: string;
  localIcon: string;
  name: string;
  type: string;
}

export interface DirectionsResult {
  bounds: LatLngBounds;
  fare: Fare;
  legs: DirectionsLeg[];
  overviewPolyline: string;
  summary: string;
  warnings: string[];
  waypointOrder: number[];
}

export interface LatLngBounds {
  northeast: LatLng;
  southwest: LatLng;
}

export interface Fare {
  currency: string;
  value: number;
}

export interface DirectionsLeg {
  arrivalTime: TransitTime;
  departureTime: TransitTime;
  distance: Distance;
  duration: Duration;
  endAddress: string;
  endLocation: LatLng;
  startAddress: string;
  startLocation: LatLng;
  steps: DirectionsStep[];
  viaWaypoints: LatLng[];
}

export interface DirectionsRoute {
  bounds: LatLngBounds;
  fare: Fare;
  legs: DirectionsLeg[];
  overviewPolyline: string;
  summary: string;
  warnings: string[];
  waypointOrder: number[];
}

export interface Directions {
  routes: DirectionsRoute[];
  status: DirectionsStatus;
}

export enum DirectionsStatus {
  OK = "OK",
  NOT_FOUND = "NOT_FOUND",
  ZERO_RESULTS = "ZERO_RESULTS",
  MAX_WAYPOINTS_EXCEEDED = "MAX_WAYPOINTS_EXCEEDED",
  MAX_ROUTE_LENGTH_EXCEEDED = "MAX_ROUTE_LENGTH_EXCEEDED",
  INVALID_REQUEST = "INVALID_REQUEST",
  OVER_DAILY_LIMIT = "OVER_DAILY_LIMIT",
  OVER_QUERY_LIMIT = "OVER_QUERY_LIMIT",
  REQUEST_DENIED = "REQUEST_DENIED",
  UNKNOWN_ERROR = "UNKNOWN_ERROR",
}

// export interface DirectionsRenderer {
//   directions: Directions;
//   map: Map;
//   panel: HTMLElement;
//   routeIndex: number;
//   options: DirectionsRendererOptions;
// }

// export interface DirectionsRendererOptions {
//   directions: Directions;
//   map: Map;
//   panel: HTMLElement;
//   routeIndex: number;
// }

// export interface DirectionsRendererResult {
//   renderer: DirectionsRenderer;
// }
