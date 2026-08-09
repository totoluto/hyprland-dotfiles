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

    implicitWidth: 135
    implicitHeight: Metrics.hubTabHeight
    radius: Metrics.hubTabRadius
    color: root.active ? Colours.surface1 : "transparent"

    RowLayout {
        anchors.centerIn: parent
        spacing: 4

        Item {
            Layout.preferredWidth: 15
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
            Layout.alignment: Qt.AlignVCenter
        }

    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        width: root.active ? 26 : 0
        height: 2
        radius: 1
        color: Colours.blue

        Behavior on width {
            NumberAnimation {
                duration: Animations.normal
                easing.type: Easing.OutCubic
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }
    }
}
