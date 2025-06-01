import { Marker } from "../../definitions";

export interface DidTapCustomInfoWindowActionResult {
  marker: Marker;
  action: string;
}

export type DidTapCustomInfoWindowActionCallback = (
  result: DidTapCustomInfoWindowActionResult | null,
  err?: any
) => void;
