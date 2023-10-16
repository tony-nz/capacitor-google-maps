import { LatLng } from "../../LatLng";
import { DirectionPreferences, TravelMode } from "./DirectionPreferences";

export interface Direction {
  mapId: string;
  origin: LatLng;
  destination: LatLng;
  waypoints: LatLng[];
  travelMode: TravelMode;
  preferences?: DirectionPreferences;
}
