pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Leave blank to auto-select the Hyprland monitor whose origin is 0,0.
    // If that is not your main monitor, set its connector name here,
    // e.g. "eDP-1" or "DP-1" (check with: hyprctl monitors).
    readonly property string mainScreenName: ""
}
