import QtQuick

import qs.theme

Rectangle {
    id: root

    property bool checked: false
    property bool enabled: true

    signal toggled(bool checked)

    implicitWidth: 42
    implicitHeight: 24

    radius: height / 2
    opacity: root.enabled ? 1 : 0.45

    color: root.checked ? Colours.blue : (hover.hovered ? Colours.surface0 : Colours.surface2)

    border.width: 1
    border.color: root.checked ? Colours.blue : Colours.surface0

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

    Rectangle {
        id: knob

        width: 18
        height: 18
        radius: 9

        y: 3
        x: root.checked ? root.width - width - 3 : 3

        color: root.checked ? Colours.base : Colours.text

        Behavior on x {
            NumberAnimation {
                duration: Animations.fast
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Animations.fast
            }
        }
    }

    HoverHandler {
        id: hover

        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        enabled: root.enabled

        onTapped: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}