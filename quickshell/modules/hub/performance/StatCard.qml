import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Rectangle {
    id: root

    required property string title
    required property string icon
    required property string valueText
    property string detailText: ""
    property real percentage: -1
    property color accent: Colours.blue

    radius: 18
    color: Colours.surface1
    border.width: 1
    border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TokyoIcon {
                text: root.icon
                font.pixelSize: 18
                color: root.accent
                Layout.alignment: Qt.AlignVCenter
            }

            TokyoText {
                text: root.title
                font.pixelSize: 13
                font.weight: Font.Medium
                color: Colours.muted
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

        }

        Item {
            Layout.fillHeight: true
        }

        TokyoText {
            text: root.valueText
            font.pixelSize: 30
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
        }

        TokyoText {
            visible: root.detailText.length > 0
            text: root.detailText
            font.pixelSize: 12
            color: Colours.muted
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
        }

        Item {
            visible: root.percentage >= 0
            Layout.fillWidth: true
            Layout.preferredHeight: 7
            Layout.topMargin: 5

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Colours.surface2
            }

            Rectangle {
                height: parent.height
                width: parent.width * Math.max(0, Math.min(1, root.percentage))
                radius: height / 2
                color: root.accent

                Behavior on width {
                    NumberAnimation {
                        duration: Animations.normal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
