import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.theme

Rectangle {
    id: root

    required property var entry
    property bool selected: false
    readonly property string resolvedIcon: {
        if (!root.entry.icon || root.entry.icon.length === 0) {
            return "";
        }

        return Quickshell.iconPath(root.entry.icon, true);
    }

    readonly property bool hasIcon: root.resolvedIcon.length > 0

    signal activated()
    signal hovered()

    implicitHeight: Metrics.hubResultHeight
    radius: Metrics.hubResultRadius
    color: root.selected ? Colours.surface1 : "transparent"

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: root.selected ? 30 : 0
        radius: 2
        color: Colours.blue

        Behavior on height {
            NumberAnimation {
                duration: Animations.fast
                easing.type: Easing.OutCubic
            }

        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        Item {
            Layout.preferredWidth: Metrics.hubResultIconSize
            Layout.preferredHeight: Metrics.hubResultIconSize
            Layout.alignment: Qt.AlignVCenter

            IconImage {
                anchors.fill: parent
                visible: root.hasIcon
                source: root.resolvedIcon
                implicitSize: Metrics.hubResultIconSize
            }

            Rectangle {
                anchors.fill: parent
                visible: !root.hasIcon
                radius: 10
                color: Colours.surface2
                border.width: 1
                border.color: Colours.blue

                TokyoText {
                    anchors.fill: parent
                    text: {
                        if (root.entry.name && root.entry.name.length > 0)
                            return root.entry.name.charAt(0).toUpperCase();

                        return "?";
                    }
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                    color: Colours.blue
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            TokyoText {
                text: root.entry.name || ""
                font.pixelSize: 16
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }

            TokyoText {
                visible: root.entry.genericName && root.entry.genericName.length > 0
                text: root.entry.genericName || ""
                font.pixelSize: 12
                color: Colours.muted
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }

        }

    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered)
                root.hovered();

        }
    }

    TapHandler {
        onTapped: root.activated()
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

}
