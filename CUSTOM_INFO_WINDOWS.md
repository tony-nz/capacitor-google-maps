# Custom Info Windows

This guide explains how to use the custom info windows feature in the Capacitor Google Maps plugin.

## Overview

Custom info windows allow you to create interactive, styled info windows that appear when users tap on markers. Unlike the default Google Maps info windows, these custom info windows support:

- Custom styling (colors, fonts, text sizes, etc.)
- HTML content with rich formatting
- Custom content layout
- Automatic sizing based on content

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
// Basic example with plain text
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
        titleColor: "#333333",
        snippetColor: "#666666",
        backgroundColor: "#FFFFFF",
        titleSize: 18,
        snippetSize: 14,
        offsetX: 0,
        offsetY: -20, // Position further above the marker
      },
    },
  },
});

// Example with HTML snippet
await CapacitorGoogleMaps.addMarker({
  mapId: "your-map-id",
  position: {
    latitude: 37.7849,
    longitude: -122.4094,
  },
  preferences: {
    title: "Fisherman's Wharf",
    snippet: "Famous waterfront area",
    metadata: {
      infoWindow: {
        title: "Fisherman's Wharf",
        snippet:
          "<b>Famous waterfront area</b><br/>Visit <i>Pier 39</i> and see the sea lions!",
        isSnippetHTML: true,
        titleColor: "#2C3E50",
        titleSize: 16,
        snippetSize: 13,
      },
    },
  },
});
```

## Custom Info Window Properties

The `infoWindow` object in the marker metadata supports the following properties:

| Property          | Type    | Description                               | Default        |
| ----------------- | ------- | ----------------------------------------- | -------------- |
| `title`           | string  | The title text                            | Marker title   |
| `snippet`         | string  | The description text (plain text or HTML) | Marker snippet |
| `isSnippetHTML`   | boolean | Whether the snippet contains HTML         | `false`        |
| `titleColor`      | string  | Hex color for title text                  | `#000000`      |
| `snippetColor`    | string  | Hex color for snippet text                | `#666666`      |
| `backgroundColor` | string  | Hex color for info window background      | `#FFFFFF`      |
| `titleSize`       | number  | Font size for title text (in points)      | `16`           |
| `snippetSize`     | number  | Font size for snippet text (in points)    | `14`           |
| `offsetX`         | number  | Horizontal offset from marker (in points) | `0`            |
| `offsetY`         | number  | Vertical offset from marker (in points)   | `-10`          |

## Positioning and Offset

The info window position can be customized using offset values:

- **`offsetX`**: Horizontal offset from the marker center
  - Positive values move the info window to the right
  - Negative values move the info window to the left
- **`offsetY`**: Vertical offset from the marker position
  - Positive values move the info window down (below the marker)
  - Negative values move the info window up (above the marker)
  - Default is `-10` to position the info window above the marker

### Offset Examples

```typescript
// Position info window above and to the right of marker
await CapacitorGoogleMaps.addMarker({
  mapId: "your-map-id",
  position: { latitude: 37.7749, longitude: -122.4194 },
  preferences: {
    metadata: {
      infoWindow: {
        title: "Above Right",
        snippet: "Positioned above and to the right",
        offsetX: 50, // 50 points to the right
        offsetY: -30, // 30 points above
      },
    },
  },
});

// Position info window below the marker
await CapacitorGoogleMaps.addMarker({
  mapId: "your-map-id",
  position: { latitude: 37.7849, longitude: -122.4094 },
  preferences: {
    metadata: {
      infoWindow: {
        title: "Below Marker",
        snippet: "Positioned below the marker",
        offsetX: 0, // Centered horizontally
        offsetY: 40, // 40 points below
      },
    },
  },
});
```

## HTML Snippet Support

Custom info windows support HTML content in the snippet field. This allows you to create rich, formatted text with:

- **Bold** and _italic_ text
- Links
- Lists
- Line breaks
- Custom styling

### Basic HTML Example

```typescript
await CapacitorGoogleMaps.addMarker({
  mapId: "your-map-id",
  position: {
    latitude: 37.7749,
    longitude: -122.4194,
  },
  preferences: {
    metadata: {
      infoWindow: {
        title: "San Francisco",
        snippet:
          "<b>The Golden Gate City</b><br/>Population: <i>874,961</i><br/><br/>Famous for its <b>Golden Gate Bridge</b> and historic cable cars.",
        isSnippetHTML: true,
        titleColor: "#2C3E50",
        titleSize: 18,
        snippetSize: 14,
      },
    },
  },
});
```

### Advanced HTML Example

```typescript
await CapacitorGoogleMaps.addMarker({
  mapId: "your-map-id",
  position: {
    latitude: 37.7849,
    longitude: -122.4094,
  },
  preferences: {
    metadata: {
      infoWindow: {
        title: "Fisherman's Wharf",
        snippet: `
          <div>
            <p><b>Popular Attractions:</b></p>
            <ul>
              <li>Pier 39</li>
              <li>Sea Lions</li>
              <li>Aquarium of the Bay</li>
            </ul>
            <p><i>Open daily from 10 AM - 6 PM</i></p>
          </div>
        `,
        isSnippetHTML: true,
        backgroundColor: "#F8F9FA",
        titleColor: "#495057",
        titleSize: 16,
        snippetSize: 13,
      },
    },
  },
});
```

### Supported HTML Tags

The following HTML tags are supported in snippet content:

- `<b>`, `<strong>` - Bold text
- `<i>`, `<em>` - Italic text
- `<br/>`, `<br>` - Line breaks (properly rendered)
- `<p>` - Paragraphs
- `<ul>`, `<ol>`, `<li>` - Lists
- `<div>` - Containers
- `<span>` - Inline containers

**Note:** Complex CSS styling and JavaScript are not supported. Keep HTML simple and semantic.

### HTML Rendering Notes

- Line breaks (`<br/>` or `<br>`) are properly rendered and will create new lines
- The info window automatically adjusts its height to accommodate multi-line content
- HTML content is parsed using iOS's built-in HTML rendering capabilities
- If HTML parsing fails, the content will fallback to plain text display

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
              titleColor: "#2C3E50",
              snippetColor: "#7F8C8D",
              backgroundColor: "#FFFFFF",
              titleSize: 16,
              snippetSize: 14,
            },
          },
        },
      });
    }
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
- Consider the contrast between text and background colors
- The info window has a preferred width of 250 points but adjusts based on content
- Text sizes are specified in points (typical range: 12-20 points)
- HTML content supports basic formatting but keep it simple for best results
- Use negative `offsetY` values to position above markers (default: -10)
- Use positive `offsetY` values to position below markers
- Adjust `offsetX` to avoid overlapping with other UI elements
