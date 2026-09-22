---
name: quickshell
description: Comprehensive development guide, architectural reference, and best practices for building Wayland desktop shells, panels, widgets, and dynamic island overlays with Quickshell (v0.3+), Qt 6 QML, Pipewire, MPRIS, UPower, Hyprland, and WlrLayershell.
---

# Quickshell Development Guide

Quickshell is a high-performance, reactive Wayland desktop shell manager powered by Qt 6 Quick and QML. It allows you to build completely bespoke taskbars, dynamic islands, notification daemons, status overlays, app launchers, and control centers with direct native system bindings.

---

## 1. Project Structure & Organization

A standard Quickshell configuration follows this hierarchy:

```text
~/.config/quickshell/
├── shell.qml             # Root entry point loaded by quickshell
├── qmldir                # Module declaration (singletons, plugin paths)
├── theme/
│   ├── qmldir            # Declares Theme singleton: "singleton Theme 1.0 Theme.qml"
│   └── Theme.qml         # Color palettes, radii, spacing, typography, reactive state
└── components/
    ├── NowBar.qml        # Pill / status island
    ├── QuickPanel.qml    # Control center / dropdown overlay
    ├── SliderPill.qml    # Modular volume/brightness slider
    └── QuickToggle.qml   # Toggle switches / action buttons
```

### Module Imports
Quickshell v0.2.0+ introduces root module imports using the `qs` prefix:
```qml
// Import folders relative to the directory containing shell.qml
import qs.theme
import qs.components
```
> [!TIP]
> Always prefer `import qs.<directory>` over relative paths (`import "../components"`) or legacy schemes (`import "root:/..."`). Quickshell module imports provide superior Language Server (LSP) indexing and resolve reliably regardless of nested file depths.

---

## 2. Window Types & Display Management

### `PanelWindow` (Layer Shell Surfaces)
`PanelWindow` represents a Wayland layer shell surface (`zwlr_layer_shell_v1`).

```qml
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: rootWindow
    
    // Target display (ShellScreen)
    screen: Quickshell.screens[0]

    // Layer Shell positioning & margins
    anchors {
        top: true
        left: true
        right: false
        bottom: false
    }
    margins {
        top: 8
        left: 8
    }

    // Auto-sizing: ALWAYS use implicit dimensions on PanelWindow
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    // Transparent window surface so QML shapes control geometry and roundness
    color: "transparent"

    // Wayland LayerShell Configuration
    WlrLayershell.layer: WlrLayer.Top        // Background, Bottom, Top, Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None // None, Exclusive, OnDemand
    WlrLayershell.namespace: "quickshell:nowbar"

    // Desktop window avoidance
    exclusionMode: ExclusionMode.Normal      // Normal, Ignore, Auto
    exclusiveZone: 48                        // Reserves 48px from tiling window managers

    Item {
        id: content
        // Child elements here...
    }
}
```

> [!WARNING]
> - Setting `height` directly on `PanelWindow` is **deprecated** in Quickshell v0.3+. Use `implicitHeight` and `implicitWidth`.
> - If two opposite anchors are enabled simultaneously (e.g. `left: true` and `right: true`), that dimension is **forced to full screen width**. To create centered floating islands, anchor only `top: true` or `bottom: true` and leave horizontal anchors `false`.

### Multi-Monitor Panels (`Variants`)
To create panels across every connected display:
```qml
Variants {
    model: Quickshell.screens
    delegate: Component {
        PanelWindow {
            screen: modelData
            anchors.top: true
            // Panel implementation...
        }
    }
}
```

### Click-Through Masks (`Region`)
To make areas outside a floating widget click-through to underlying windows:
```qml
mask: Region {
    item: contentBoundingItem // Only clicks within this Item are captured
}
```

---

## 3. Layout Rules & Sizing Invariants

### Sizing Direction
- **Implicit size flows UP**: From children to parent (`implicitWidth`, `implicitHeight`).
- **Actual size flows DOWN**: From parent to children (`width`, `height`, `anchors.fill: parent`).

### Avoiding Binding Loops
> [!CAUTION]
> **NEVER** use `childrenRect.width` or `childrenRect.height` to set a container's `implicitWidth`/`implicitHeight` if any child inside anchors to `parent` or calculates its size relative to the parent. This creates an infinite cyclic binding loop and crashes or freezes the QML engine.

Instead:
1. Calculate implicit size explicitly from children:
   ```qml
   implicitWidth: leftIcon.implicitWidth + label.implicitWidth + spacing
   ```
2. Or use Quickshell's built-in wrapper items:
   ```qml
   import Quickshell.Widgets
   WrapperRectangle {
       margin: 8
       // Child implicitly sizes wrapper; wrapper controls child geometry
   }
   ```

### Layouts vs. Row/Column
- Always prefer `RowLayout` and `ColumnLayout` from `QtQuick.Layouts`.
- Raw `Row` and `Column` lack pixel-alignment support (fractional scaling can cause jitter) and do not support `Layout.fillWidth`, `Layout.fillHeight`, or `Layout.alignment`.

---

## 4. Built-in Services & Integrations

### Pipewire Audio (`Quickshell.Services.Pipewire`)
Quickshell includes native Pipewire integration without shell commands.

> [!IMPORTANT]
> Pipewire nodes are **unbound by default**. You **MUST** bind the sink/source using `PwObjectTracker` before accessing `audio.volume` or `audio.muted`.

```qml
import QtQuick
import Quickshell.Services.Pipewire

Item {
    // 1. Mandatory object tracker
    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    // 2. Reactive volume binding
    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    function setVolume(val: real) {
        if (Pipewire.defaultAudioSink?.audio) {
            Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, Math.min(1.0, val));
        }
    }

    function toggleMute() {
        if (Pipewire.defaultAudioSink?.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }
}
```

### Media Player Controls (`Quickshell.Services.Mpris`)
Access active MPRIS media players:
```qml
import QtQuick
import Quickshell.Services.Mpris

Item {
    readonly property var activePlayer: Mpris.players.values.length > 0 
        ? Mpris.players.values[0] 
        : null

    readonly property string title: activePlayer?.trackTitle ?? "No media playing"
    readonly property string artist: activePlayer?.trackArtist ?? ""
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing

    function togglePlay() {
        if (activePlayer) activePlayer.togglePlaying();
    }
    function nextTrack() {
        if (activePlayer) activePlayer.next();
    }
    function prevTrack() {
        if (activePlayer) activePlayer.previous();
    }
}
```

### Battery & Power (`Quickshell.Services.UPower`)
```qml
import QtQuick
import Quickshell.Services.UPower

Item {
    readonly property var battery: UPower.displayDevice
    readonly property int percentage: Math.round((battery?.percentage ?? 1.0) * 100)
    readonly property bool isCharging: battery?.state === UPowerDeviceState.Charging
}
```

### Hyprland Compositor (`Quickshell.Hyprland`)
```qml
import QtQuick
import Quickshell.Hyprland

Item {
    // Check if Hyprland is in Lua mode
    readonly property bool isLua: Hyprland.usingLua

    // Dispatch compositor commands
    function switchToWorkspace(id: int) {
        Hyprland.dispatch(`workspace ${id}`);
    }

    // Active window info
    readonly property string activeTitle: Hyprland.activeToplevel?.title ?? ""
}
```

### Process Execution (`Quickshell.Io`)
Run background scripts or commands asynchronously:
```qml
import QtQuick
import Quickshell.Io

Process {
    id: proc
    command: ["sh", "-c", "brightnessctl set +5%"]
    stdout: StdioCollector {
        onStreamFinished: console.log("Process finished:", this.text)
    }
}

// Trigger with:
// proc.running = true;
```

---

## 5. Quickshell IPC & CLI Commands

Quickshell includes an IPC server allowing external scripts, keybindings, or Hyprland dispatchers to invoke QML functions and inspect properties.

### Exposing IPC in QML (`IpcHandler`)
```qml
import QtQuick
import Quickshell.Io

IpcHandler {
    target: "panel"

    function toggle(): void {
        controlPanel.visible = !controlPanel.visible;
    }

    function setBrightness(level: real): void {
        brightnessSlider.value = level;
    }
}
```

### Invoking IPC via Shell
```bash
# Show registered IPC handlers
quickshell ipc show

# Call a handler function
quickshell ipc call panel toggle

# Call with arguments
quickshell ipc call panel setBrightness 0.75

# Query properties
quickshell ipc prop panel
```

### Managing Quickshell Lifecycles
```bash
# Launch default config (~/.config/quickshell/shell.qml)
quickshell

# Launch custom config path
quickshell -p ~/.dots/config/quickshell

# Launch detached in background (daemon mode)
quickshell -d -p ~/.dots/config/quickshell

# List running instances
quickshell list

# Kill instances
quickshell kill

# View live logs
quickshell log
```

---

## 6. Common Gotchas & Debugging Checklist

1. **Signal Name Conflicts:**
   Never declare a custom signal with the same name as a property change signal:
   ```qml
   // ❌ ERROR: Property 'value' already creates signal 'valueChanged'
   property real value: 0
   signal valueChanged() 

   //  CORRECT: Simply handle the automatic signal
   property real value: 0
   onValueChanged: { ... }
   ```

2. **Zero-Sized Invisible Items:**
   Standard `Item` has `width: 0` and `height: 0` by default. Always give root containers an explicit or computed `implicitWidth` and `implicitHeight`.

3. **Missing `PwObjectTracker` for Pipewire:**
   Reading `Pipewire.defaultAudioSink.audio.volume` without binding the node in `PwObjectTracker` results in null or 0.0 values.

4. **Visual Inspection on Hyprland:**
   Always test and verify Quickshell surfaces visually using:
   ```bash
   grimblast save output /tmp/ui-verify.png
   ```
   Inspect the result with `view_file` to verify margins, layers, blur, font sharpness, and squircle curvature before completing tasks.
