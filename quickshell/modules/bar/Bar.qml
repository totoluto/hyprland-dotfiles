import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.config
import qs.modules.calendar
import qs.theme

Scope {
    id: root

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

    CalendarPopup {
        id: calendarPopup

        targetScreen: root.mainScreen
    }

    PanelWindow {
        id: barWindow

        screen: root.mainScreen
        visible: root.mainScreen !== null
        implicitHeight: Metrics.attachedBarHeight
        color: "transparent"
        focusable: false

        anchors {
            top: true
            left: true
            right: true
        }

        TopIsland {
            placement: "left"
            anchors.left: parent.left
            anchors.top: parent.top

            Tray {
            }

            Battery {
            }

        }

        TopIsland {
            placement: "center"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            horizontalPadding: 10

            Workspaces {
                screen: barWindow.screen
            }

        }

        TopIsland {
            placement: "right"
            anchors.right: parent.right
            anchors.top: parent.top
            contentSpacing: Metrics.rightModuleSpacing

            Clock {
                onClicked: calendarPopup.toggle()
            }

        }

    }

}
