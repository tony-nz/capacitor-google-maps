export interface DirectionResults {
  routes: Route[];
}

export interface Route {
  summary?: string;
  legs: Leg[];
  waypointOrder?: number[];
  overviewPolylinePoints?: string;
  bounds?: Bounds;
  copyrights?: string;
  warnings: string[];
  fare?: Fare;
}

export interface Leg {
  steps: Step[];
  distance?: Distance;
  duration?: Duration;
  durationInTraffic?: Duration;
  arrivalTime?: string;
  departureTime?: string;
  startLocation: LocationCoordinate2D;
  endLocation: LocationCoordinate2D;
  startAddress: string;
  endAddress: string;
}

export interface Step {
  htmlInstructions?: string;
  distance: Distance;
  duration: Duration;
  startLocation: LocationCoordinate2D;
  endLocation: LocationCoordinate2D;
  polylinePoints: string;
  steps?: Step[];
  travelMode: TravelMode;
  maneuver?: string;
  transitDetails?: TransitDetails;
}

export interface Distance {
  text?: string;
  value: number;
}

export interface Duration {
  text?: string;
  value: number;
}

export interface LocationCoordinate2D {
  latitude: number;
  longitude: number;
}

export interface Bounds {
  northeast?: LocationCoordinate2D;
  southwest: LocationCoordinate2D;
}

export interface Fare {
  currency?: string;
  value: number;
}

export interface TransitDetails {
  arrivalStop?: TransitStop;
  arrivalTime?: TransitTime;
  departureStop?: TransitStop;
  departureTime?: TransitTime;
  headsign?: string;
  headway: number;
  line: TransitLine;
  numStops: number;
}

export interface TransitStop {
  location?: LocationCoordinate2D;
  name: string;
}

export interface TransitTime {
  text?: string;
  value: number;
}

export interface TransitLine {
  agencies?: TransitAgency[];
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

export type TravelMode = "DRIVING" | "WALKING" | "BICYCLING" | "TRANSIT";
