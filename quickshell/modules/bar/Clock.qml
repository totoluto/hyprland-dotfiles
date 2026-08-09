import QtQuick
import Quickshell
import qs.components
import qs.theme

TokyoText {
    id: root

    signal clicked()

    text: Qt.formatDateTime(clock.date, "HH:mm")
    color: hover.hovered ? Colours.blue : Colours.text

    HoverHandler {
        id: hover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

}
