import QtQuick
import qs.theme

Rectangle {
    id: root

    property string edge: "left"
    required property string icon
    property bool drawerOpen: false
    property real retreat: root.drawerOpen ? Metrics.drawerHandleHiddenOffset : 0

    signal entered()
    signal exited()

    implicitWidth: Metrics.drawerHandleWidth
    implicitHeight: Metrics.drawerHandleHeight
    radius: Metrics.drawerHandleRadius
    color: Colours.cyan
    opacity: root.drawerOpen ? 0 : 1

    Rectangle {
        y: 0
        x: root.edge === "left" ? 0 : parent.width - width
        width: root.radius
        height: parent.height
        color: root.color
    }

    TokyoIcon {
        anchors.fill: parent
        text: root.icon
        font.pixelSize: Metrics.drawerHandleIconSize
        color: Colours.surface1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        transform: Translate {
            y: 1
        }

    }

    HoverHandler {
        id: hover

        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered) {
                root.entered();
            } else {
                root.exited();
            }
        }
    }

    Behavior on retreat {
        NumberAnimation {
            duration: Animations.normal
            easing.type: Easing.OutCubic
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }

    }

    transform: Translate {
        x: root.edge === "left" ? -root.retreat : root.retreat
    }

}
