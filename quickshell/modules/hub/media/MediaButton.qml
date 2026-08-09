import QtQuick
import qs.components
import qs.theme

Rectangle {
    id: root

    required property string icon
    property bool enabled: true
    property bool primary: false

    signal clicked()

    implicitWidth: root.primary ? Metrics.mediaPlaySize : Metrics.mediaControlSize
    implicitHeight: implicitWidth
    radius: width / 2
    color: {
        if (!root.enabled) {
            return "transparent";
        }

        if (root.primary) {
            return Colours.blue;
        }

        return hover.hovered ? Colours.surface1 : "transparent";
    }

    opacity: root.enabled ? 1 : 0.3

    TokyoIcon {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: root.primary ? 23 : 20
        color: root.primary ? Colours.surface0 : Colours.text
    }

    HoverHandler {
        id: hover

        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        enabled: root.enabled
        onTapped: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
        }
    }
}
