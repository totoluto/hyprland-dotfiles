import QtQuick
import qs.components
import qs.theme

Rectangle {
    id: root

    required property string text
    property bool accent: false

    signal clicked()

    implicitWidth: Math.max(28, label.implicitWidth + 14)
    implicitHeight: 28
    radius: 9
    opacity: root.enabled ? 1 : 0.35
    color: {
        if (!root.enabled) {
            return Colours.surface2;
        }

        if (root.accent){
            return Colours.blue;
        }

        if (hover.hovered) {
            return Colours.surface0;
        }

        return Colours.surface2;
    }

    TokyoText {
        id: label

        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 11
        font.weight: Font.Medium
        color: root.accent ? Colours.base : Colours.text
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
