import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.theme

RowLayout {
    spacing: Metrics.traySpacing

    Repeater {
        model: SystemTray.items

        MouseArea {
            id: trayEntry

            required property var modelData

            implicitWidth: Metrics.iconSize
            implicitHeight: Metrics.iconSize
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    trayEntry.modelData.activate();
                } else if (mouse.button === Qt.MiddleButton) {
                    trayEntry.modelData.secondaryActivate();
                }
            }

            Image {
                anchors.fill: parent
                source: trayEntry.modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

        }

    }

}
