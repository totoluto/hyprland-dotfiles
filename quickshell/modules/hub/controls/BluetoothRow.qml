import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import qs.components
import qs.theme

Rectangle {
    id: root

    property var device: null
    readonly property string resolvedIcon: {
        if (!root.device || !root.device.icon || root.device.icon.length === 0)
            return "";

        return Quickshell.iconPath(root.device.icon, true);
    }
    readonly property bool busy: root.device !== null && (root.device.pairing || root.device.state === BluetoothDeviceState.Connecting || root.device.state === BluetoothDeviceState.Disconnecting)

    function statusText() {
        if (!root.device)
            return "";

        if (root.device.pairing)
            return "Pairing…";

        if (root.device.state === BluetoothDeviceState.Connecting)
            return "Connecting…";

        if (root.device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting…";

        if (root.device.connected) {
            if (root.device.batteryAvailable)
                return ("Connected · " + Math.round(root.device.battery * 100) + "%");

            return "Connected";
        }
        if (root.device.paired)
            return "Paired";

        return root.device.address;
    }

    function actionText() {
        if (!root.device) {
            return "";
        }

        if (root.device.pairing) {
            return "Pairing";
        }

        if (root.device.state === BluetoothDeviceState.Connecting) {
            return "Connecting";
        }

        if (root.device.state === BluetoothDeviceState.Disconnecting) {
            return "Wait";
        }

        if (root.device.connected) {
            return "Disconnect";
        }

        if (root.device.paired) {
            return "Connect";
        }

        return "Pair";
    }

    function performAction() {
        if (!root.device || root.busy) {
            return "";
        }

        if (root.device.connected) {
            root.device.disconnect();
            return ;
        }
        if (root.device.paired) {
            root.device.connect();
            return ;
        }
        root.device.pair();
    }

    visible: root.device !== null
    implicitHeight: root.device !== null ? 58 : 0
    radius: 13
    color: root.device && root.device.connected ? Colours.surface1 : hover.hovered ? Colours.surface2 : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignVCenter

            IconImage {
                anchors.fill: parent
                visible: root.resolvedIcon.length > 0
                source: root.resolvedIcon
                implicitSize: 30
            }

            TokyoIcon {
                anchors.fill: parent
                visible: root.resolvedIcon.length === 0
                text: "󰂯"
                font.pixelSize: 20
                color: root.device && root.device.connected ? Colours.blue : Colours.muted
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            TokyoText {
                text: root.device ? (root.device.name || root.device.deviceName || "Unknown device") : ""
                font.pixelSize: 14
                font.weight: root.device && root.device.connected ? Font.DemiBold : Font.Normal
                color: Colours.text
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            TokyoText {
                text: root.statusText()
                font.pixelSize: 11
                color: root.device && root.device.connected ? Colours.green : Colours.muted
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

        }

        Rectangle {
            visible: root.device && root.device.paired && !root.device.connected && !root.busy
            implicitWidth: 30
            implicitHeight: 30
            radius: 10
            color: forgetHover.hovered ? Colours.surface1 : "transparent"

            TokyoIcon {
                anchors.centerIn: parent
                text: "󰩺"
                font.pixelSize: 15
                color: Colours.muted
            }

            HoverHandler {
                id: forgetHover

                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                enabled: root.device !== null
                onTapped: root.device.forget()
            }

        }

        Rectangle {
            implicitWidth: actionLabel.implicitWidth + 22
            implicitHeight: 30
            radius: 10
            opacity: root.busy ? 0.5 : 1
            color: root.device && root.device.connected ? Colours.surface2 : Colours.blue

            TokyoText {
                id: actionLabel

                anchors.centerIn: parent
                text: root.actionText()
                font.pixelSize: 11
                color: root.device && root.device.connected ? Colours.text : Colours.surface0
            }

            HoverHandler {
                cursorShape: root.busy ? Qt.ArrowCursor : Qt.PointingHandCursor
            }

            TapHandler {
                enabled: !root.busy
                onTapped: root.performAction()
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
