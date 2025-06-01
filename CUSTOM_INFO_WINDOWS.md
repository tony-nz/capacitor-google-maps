# Custom Info Windows

This guide explains how to use the custom info windows feature in the Capacitor Google Maps plugin.

## Overview

Custom info windows allow you to create interactive, styled info windows that appear when users tap on markers. Unlike the default Google Maps info windows, these custom info windows support:

- Interactive buttons
- Custom styling (colors, fonts, etc.)
- Custom content layout
- Button click events

## Setup

### 1. Enable Custom Info Windows

First, enable custom info windows for your map:

```typescript
import { CapacitorGoogleMaps } from "@capacitor-community/capacitor-google-maps";

// Enable custom info windows
await CapacitorGoogleMaps.enableCustomInfoWindows({
  mapId: "your-map-id",
  enabled: true,
});
```

### 2. Add Markers with Custom Info Window Data

When adding markers, include custom info window data in the metadata:

```typescript
await CapacitorGoogleMaps.addMarker({
  mapId: "your-map-id",
  position: {
    latitude: 37.7749,
    longitude: -122.4194,
  },
  preferences: {
    title: "San Francisco",
    snippet: "A beautiful city",
    metadata: {
      infoWindow: {
        title: "Custom Title",
        snippet: "Custom description text",
        buttonText: "Learn More",
        titleColor: "#333333",
        snippetColor: "#666666",
        buttonColor: "#007AFF",
        backgroundColor: "#FFFFFF",
      },
    },
  },
});
```

### 3. Listen for Button Clicks

Set up a listener for custom info window button clicks:

```typescript
await CapacitorGoogleMaps.didTapCustomInfoWindowAction(
  {
    mapId: "your-map-id",
  },
  (result) => {
    if (result) {
      console.log("Button clicked for marker:", result.marker.markerId);
      console.log("Action:", result.action);

      // Handle the button click
      // For example, navigate to a detail page or show more information
    }
  }
);
```

## Custom Info Window Properties

The `infoWindow` object in the marker metadata supports the following properties:

| Property          | Type   | Description                          | Default         |
| ----------------- | ------ | ------------------------------------ | --------------- |
| `title`           | string | The title text                       | Marker title    |
| `snippet`         | string | The description text                 | Marker snippet  |
| `buttonText`      | string | Text for the action button           | No button shown |
| `titleColor`      | string | Hex color for title text             | `#000000`       |
| `snippetColor`    | string | Hex color for snippet text           | `#666666`       |
| `buttonColor`     | string | Hex color for button background      | `#007AFF`       |
| `backgroundColor` | string | Hex color for info window background | `#FFFFFF`       |

## Example: Complete Implementation

```typescript
import { CapacitorGoogleMaps } from "@capacitor-community/capacitor-google-maps";

class MapService {
  private mapId = "main-map";

  async initializeMap() {
    // Create map
    const mapResult = await CapacitorGoogleMaps.createMap({
      element: document.getElementById("map"),
      boundingRect: {
        x: 0,
        y: 0,
        width: window.innerWidth,
        height: window.innerHeight,
      },
      cameraPosition: {
        latitude: 37.7749,
        longitude: -122.4194,
        zoom: 12,
      },
    });

    this.mapId = mapResult.googleMap.mapId;

    // Enable custom info windows
    await CapacitorGoogleMaps.enableCustomInfoWindows({
      mapId: this.mapId,
      enabled: true,
    });

    // Set up button click listener
    await CapacitorGoogleMaps.didTapCustomInfoWindowAction(
      {
        mapId: this.mapId,
      },
      this.handleInfoWindowAction.bind(this)
    );

    // Add markers with custom info windows
    await this.addCustomMarkers();
  }

  async addCustomMarkers() {
    const locations = [
      {
        id: "location-1",
        position: { latitude: 37.7749, longitude: -122.4194 },
        title: "San Francisco",
        description: "The Golden Gate City",
      },
      {
        id: "location-2",
        position: { latitude: 37.7849, longitude: -122.4094 },
        title: "Fisherman's Wharf",
        description: "Famous waterfront area",
      },
    ];

    for (const location of locations) {
      await CapacitorGoogleMaps.addMarker({
        mapId: this.mapId,
        position: location.position,
        preferences: {
          title: location.title,
          snippet: location.description,
          metadata: {
            locationId: location.id,
            infoWindow: {
              title: location.title,
              snippet: location.description,
              buttonText: "View Details",
              titleColor: "#2C3E50",
              snippetColor: "#7F8C8D",
              buttonColor: "#3498DB",
              backgroundColor: "#FFFFFF",
            },
          },
        },
      });
    }
  }

  private handleInfoWindowAction(result: any) {
    if (result && result.marker) {
      const markerId = result.marker.markerId;
      const locationId = result.marker.metadata?.locationId;

      console.log(`Info window button clicked for marker: ${markerId}`);

      // Handle the action - for example, navigate to a detail page
      this.showLocationDetails(locationId);
    }
  }

  private showLocationDetails(locationId: string) {
    // Implement your detail view logic here
    console.log(`Showing details for location: ${locationId}`);
  }

  async disableCustomInfoWindows() {
    await CapacitorGoogleMaps.enableCustomInfoWindows({
      mapId: this.mapId,
      enabled: false,
    });
  }
}
```

## Notes

- Custom info windows are only available on iOS currently
- If a marker doesn't have custom info window data, it will use the default Google Maps info window
- Custom info windows automatically hide when the user taps elsewhere on the map
- The info window position updates automatically when the camera moves
- You can disable custom info windows at any time by calling `enableCustomInfoWindows` with `enabled: false`

## Styling Tips

- Use hex colors for consistent styling across devices
- Keep button text short and descriptive
- Consider the contrast between text and background colors
- The info window has a fixed width of 200 points but height adjusts to content
