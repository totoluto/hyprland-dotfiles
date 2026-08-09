import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Rectangle {
    id: root

    required property var player
    property bool selected: false

    signal clicked()

    implicitHeight: Metrics.mediaPlayerChipHeight
    implicitWidth: chipContent.implicitWidth + 22
    radius: height / 2
    color: root.selected ? Colours.surface1 : "transparent"
    border.width: root.selected ? 1 : 0
    border.color: Colours.blue

    RowLayout {
        id: chipContent

        anchors.centerIn: parent
        spacing: 7

        Rectangle {
            width: 7
            height: 7
            radius: width / 2
            color: root.player.isPlaying ? Colours.green : Colours.muted
        }

        TokyoText {
            text: root.player.identity || "Media"
            font.pixelSize: 12
            color: root.selected ? Colours.text : Colours.muted
        }

    }

    HoverHandler {
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
