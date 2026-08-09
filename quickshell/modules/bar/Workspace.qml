import Quickshell.Hyprland
import QtQuick
import qs.components
import qs.theme

Item {
    id: root

    required property int workspaceId
    required property bool active

    readonly property bool hovered: mouseArea.containsMouse

    implicitWidth: active ? Metrics.workspaceActiveWidth : Metrics.workspaceWidth
    implicitHeight: 26

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Animations.normal
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Metrics.workspaceRadius
        color: Colours.surface1
        opacity: root.hovered && !root.active ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.fast
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Metrics.workspaceRadius
        opacity: root.active ? 1 : 0

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Colours.blue }
            GradientStop { position: 1.0; color: Colours.purple }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.normal
                easing.type: Easing.OutCubic
            }
        }
    }

    TokyoText {
        anchors.fill: parent

        text: ["", "一", "二", "三", "四", "五"][root.workspaceId]

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: root.active ? Colours.surface0 : Colours.text
        font.weight: root.active ? Typography.mediumWeight : Typography.normalWeight

        Behavior on color {
            ColorAnimation {
                duration: Animations.fast
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("workspace " + root.workspaceId)
    }
}
