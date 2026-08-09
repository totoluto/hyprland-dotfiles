import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.config
import qs.services
import qs.theme

Scope {
    id: root

    property bool shown: false
    property bool armed: false
    readonly property bool hasBrightness: Brightness.available
    readonly property int panelBodyWidth: root.hasBrightness ? Metrics.osdBodyWidthDual : Metrics.osdBodyWidthSingle
    readonly property var mainScreen: selectMainScreen()

    function selectMainScreen() {
        const screens = Quickshell.screens;
        if (!screens || screens.length === 0) {
            return null;
        }

        if (Settings.mainScreenName.length > 0) {
            for (let i = 0; i < screens.length; ++i) {
                if (screens[i].name === Settings.mainScreenName) {
                    return screens[i];
                }
            }
        }

        for (let i = 0; i < screens.length; ++i) {
            const monitor = Hyprland.monitorFor(screens[i]);
            if (monitor && monitor.x === 0 && monitor.y === 0) {
                return screens[i];
            }
        }

        return screens[0];
    }

    function reveal() {
        root.shown = true;
        hideTimer.restart();
    }

    Timer {
        interval: 1200
        running: true
        repeat: false
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer

        interval: Metrics.osdTimeout
        repeat: false
        onTriggered: root.shown = false
    }

    Connections {
        function onVolumeChanged() {
            if (root.armed) {
                root.reveal();
            }
        }

        function onMutedChanged() {
            if (root.armed) {
                root.reveal();
            }
        }

        target: Audio
    }

    Connections {
        function onValueChanged() {
            if (root.armed && Brightness.available) {
                root.reveal();
            }
        }

        target: Brightness
    }

    OsdWindow {
        id: osdWindow

        screen: root.mainScreen
        visible: root.mainScreen !== null
        shown: root.shown
        handleIcon: Audio.icon
        cardWidth: root.panelBodyWidth + Metrics.osdShoulderWidth
        cardHeight: Metrics.osdCardHeight
        interactiveHold: volumeControl.pressed || brightnessControl.pressed

        SideIsland {
            anchors.fill: parent
            bodyWidth: root.panelBodyWidth

            RowLayout {
                anchors.centerIn: parent
                width: root.panelBodyWidth
                height: parent.height - Metrics.osdVerticalPadding * 2
                spacing: root.hasBrightness ? Metrics.osdControlSpacing : 0

                VerticalControl {
                    id: volumeControl

                    Layout.fillHeight: true
                    Layout.preferredWidth: Metrics.osdControlWidth
                    value: Audio.muted ? 0 : Math.min(Audio.volume, 1)
                    icon: Audio.icon
                    label: Audio.muted ? "M" : Audio.percent + "%"
                    controlEnabled: Audio.available
                    onValueEdited: (value) => {
                        Audio.setVolume(value);
                        root.reveal();
                    }
                }

                VerticalControl {
                    id: brightnessControl

                    visible: root.hasBrightness
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.hasBrightness ? Metrics.osdControlWidth : 0
                    Layout.minimumWidth: root.hasBrightness ? Metrics.osdControlWidth : 0
                    Layout.maximumWidth: root.hasBrightness ? Metrics.osdControlWidth : 0
                    value: Brightness.value
                    icon: "󰃠"
                    label: Math.round(Brightness.value * 100) + "%"
                    controlEnabled: Brightness.available
                    onValueEdited: (value) => {
                        Brightness.setBrightness(value);
                        root.reveal();
                    }
                }
            }
        }
    }
}
