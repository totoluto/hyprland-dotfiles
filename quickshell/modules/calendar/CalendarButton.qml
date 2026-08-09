import QtQuick
import qs.components
import qs.theme

Rectangle {
    id: root

    property string text: ""

    signal clicked()

    implicitWidth: Math.max(28, label.implicitWidth + 14)
    implicitHeight: 28
    radius: 9
    color: hover.hovered ? Colours.surface0 : Colours.surface1
    border.width: 1
    border.color: Colours.surface0

    TokyoText {
        id: label

        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 11
        font.weight: Font.Medium
        color: Colours.text
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
