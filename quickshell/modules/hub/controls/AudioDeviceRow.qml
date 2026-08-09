import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Layouts

import qs.components
import qs.theme

Rectangle {
    id: root

    required property var node

    property bool selected: false
    property bool output: true

    signal selectedRequested(var node)

    implicitHeight: 54
    radius: 13

    color:
        root.selected
            ? Colours.surface1
            : hover.hovered
                ? Colours.surface2
                : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }
    }

    function displayName() {
        if (!root.node)
            return "Unknown device"

        if (
            root.node.description
            && root.node.description.length > 0
        ) {
            return root.node.description
        }

        if (
            root.node.nickname
            && root.node.nickname.length > 0
        ) {
            return root.node.nickname
        }

        return root.node.name || "Audio device"
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: 14
        anchors.rightMargin: 14

        spacing: 11

        TokyoIcon {
            text:
                root.output
                    ? "󰓃"
                    : "󰍬"

            font.pixelSize: 19

            color:
                root.selected
                    ? Colours.blue
                    : Colours.muted

            Layout.preferredWidth: 24
            Layout.alignment:
                Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 1

            TokyoText {
                text:
                    root.displayName()

                font.pixelSize: 13

                font.weight:
                    root.selected
                        ? Font.DemiBold
                        : Font.Normal

                color: Colours.text

                horizontalAlignment:
                    Text.AlignLeft

                elide:
                    Text.ElideRight

                Layout.fillWidth: true
            }

            TokyoText {
                text:
                    root.selected
                        ? "Default"
                        : "Available"

                font.pixelSize: 11

                color:
                    root.selected
                        ? Colours.green
                        : Colours.muted

                horizontalAlignment:
                    Text.AlignLeft

                Layout.fillWidth: true
            }
        }

        Rectangle {
            visible:
                !root.selected

            implicitWidth: 64
            implicitHeight: 28

            radius: 9

            color:
                Colours.blue

            TokyoText {
                anchors.centerIn: parent

                text: "Select"

                font.pixelSize: 11

                color:
                    Colours.surface0
            }

            HoverHandler {
                cursorShape:
                    Qt.PointingHandCursor
            }

            TapHandler {
                onTapped:
                    root.selectedRequested(
                        root.node
                    )
            }
        }

        TokyoIcon {
            visible:
                root.selected

            text: "󰄬"

            font.pixelSize: 16
            color: Colours.green
        }
    }

    HoverHandler {
        id: hover
    }

    TapHandler {
        onTapped: {
            if (!root.selected) {
                root.selectedRequested(
                    root.node
                )
            }
        }
    }
}