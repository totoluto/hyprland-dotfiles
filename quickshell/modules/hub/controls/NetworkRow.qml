import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.components
import qs.theme

Rectangle {
    id: root

    required property var network

    signal connectRequested(var network)

    function signalIcon() {
        const strength = root.network.signalStrength;
        if (strength >= 0.75) {
            return "󰤨";
        }

        if (strength >= 0.5) {
            return "󰤥";
        }

        if (strength >= 0.25) {
            return "󰤢";
        }

        return "󰤟";
    }

    function securityIcon() {
        if (root.network.security === WifiSecurityType.Open) {
            return "";
        }

        return "󰌾";
    }

    implicitHeight: 54
    radius: 13
    color: root.network.connected ? Colours.surface1 : hover.hovered ? Colours.surface2 : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        TokyoIcon {
            text: root.signalIcon()
            font.pixelSize: 20
            color: root.network.connected ? Colours.blue : Colours.muted
            Layout.preferredWidth: 24
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            TokyoText {
                text: root.network.name
                font.pixelSize: 14
                font.weight: root.network.connected ? Font.DemiBold : Font.Normal
                color: Colours.text
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            TokyoText {
                text: {
                    if (root.network.connected) {
                        return "Connected";
                    }

                    if (root.network.stateChanging) {
                        return "Connecting…";
                    }

                    if (root.network.known) {
                        return "Saved";
                    }

                    return Math.round(root.network.signalStrength * 100) + "%";
                }
                font.pixelSize: 11
                color: root.network.connected ? Colours.green : Colours.muted
            }

        }

        TokyoIcon {
            visible: root.securityIcon().length > 0
            text: root.securityIcon()
            font.pixelSize: 14
            color: Colours.muted
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            implicitWidth: actionText.implicitWidth + 22
            implicitHeight: 30
            radius: 10
            color: root.network.connected ? Colours.surface2 : Colours.blue
            opacity: root.network.stateChanging ? 0.5 : 1

            TokyoText {
                id: actionText

                anchors.centerIn: parent
                text: root.network.connected ? "Disconnect" : root.network.stateChanging ? "Wait" : "Connect"
                font.pixelSize: 11
                color: root.network.connected ? Colours.text : Colours.surface0
            }

            HoverHandler {
                cursorShape: root.network.stateChanging ? Qt.ArrowCursor : Qt.PointingHandCursor
            }

            TapHandler {
                enabled: !root.network.stateChanging
                onTapped: {
                    if (root.network.connected) {
                        root.network.disconnect();
                        return ;
                    }
                    root.connectRequested(root.network);
                }
            }

        }

    }

    HoverHandler {
        id: hover
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

}
