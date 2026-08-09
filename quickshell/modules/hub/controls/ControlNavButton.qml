import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Rectangle {
    id: root

    required property string icon
    required property string label
    property bool active: false

    signal clicked()

    implicitWidth: 150
    implicitHeight: 42
    radius: 13
    color: root.active ? Colours.surface1 : hover.hovered ? Colours.surface2 : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 8

        Item {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            Layout.alignment: Qt.AlignVCenter

            TokyoIcon {
                anchors.fill: parent
                text: root.icon
                font.pixelSize: 16
                color: root.active ? Colours.blue : Colours.muted
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                transform: Translate {
                    y: 1
                }

            }

        }

        TokyoText {
            text: root.label
            font.pixelSize: 14
            color: root.active ? Colours.text : Colours.muted
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
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
