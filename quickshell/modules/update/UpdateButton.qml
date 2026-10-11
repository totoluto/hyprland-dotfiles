import QtQuick
import qs.components
import qs.theme

Rectangle {
    id: root

    property string text: "Refresh"
    property string icon: ""
    property color accent: Colours.blue
    property bool primary: false
    property bool busy: false

    signal clicked()

    implicitWidth: 130
    implicitHeight: 38
    radius: 10

    color: hover.hovered ? Colours.surface0 : Colours.surface1

    border.width: 1
    border.color: root.primary ? Colours.blue : Colours.surface0

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        TokyoIcon {
            visible: root.icon.length > 0
            text: root.icon
            font.pixelSize: 15
            color: root.accent

            anchors.verticalCenter: parent.verticalCenter
        }

        TokyoText {
            text: root.text
            font.pixelSize: 11
            color: Colours.text

            horizontalAlignment: Text.AlignLeft
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: {
            if (root.enabled)
                root.clicked()
        }
    }
}
