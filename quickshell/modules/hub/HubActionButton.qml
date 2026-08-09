import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Rectangle {
    id: root

    required property string label
    required property string icon
    property color accent: Colours.blue

    signal clicked()

    implicitWidth: 130
    implicitHeight: 38
    radius: 13
    color: hover.hovered ? Colours.surface1 : "transparent"

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        TokyoIcon {
            text: root.icon
            font.pixelSize: 17
            color: root.accent
        }

        TokyoText {
            text: root.label
            font.pixelSize: 13
        }

    }

    HoverHandler {
        id: hover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

}
