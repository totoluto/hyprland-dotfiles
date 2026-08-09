import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Rectangle {
    id: root

    required property string label
    required property string icon
    property bool active: false

    signal clicked()

    implicitHeight: Metrics.activityTabHeight
    implicitWidth: content.implicitWidth + 22
    radius: 11
    color: root.active ? Colours.surface1 : hover.hovered ? Colours.surface2 : "transparent"

    RowLayout {
        id: content

        anchors.centerIn: parent
        spacing: 4

        Item {
            Layout.preferredWidth: 15
            Layout.preferredHeight: 18

            TokyoIcon {
                anchors.fill: parent
                text: root.icon
                font.pixelSize: 15
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
            font.pixelSize: 13
            color: root.active ? Colours.text : Colours.muted
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
