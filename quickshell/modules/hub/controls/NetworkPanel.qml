import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.components
import qs.theme

Item {
    id: root

    property bool active: false
    property var pendingNetwork: null
    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wifi) {
                return devices[i];
            }
        }
        return null;
    }
    readonly property var wiredDevice: {
        const devices = Networking.devices.values;
        let fallback = null;
        let linked = null;
        for (let i = 0; i < devices.length; ++i) {
            const device = devices[i];
            if (device.type !== DeviceType.Wired) {
                continue;
            }

            if (fallback === null) {
                fallback = device;
            }

            if (device.connected) {
                return device;
            }

            if (linked === null && device.hasLink) {
                linked = device;
            }
        }

        if (linked !== null) {
            return linked;
        }

        return fallback;
    }
    readonly property bool wiredConnected: root.wiredDevice !== null && (root.wiredDevice.connected || (root.wiredDevice.network !== null && root.wiredDevice.network.connected))
    readonly property var wifiNetworks: {
        if (!root.wifiDevice) {
            return [];
        }

        const source = root.wifiDevice.networks.values;
        const networks = [];
        for (let i = 0; i < source.length; ++i) {
            networks.push(source[i]);
        }

        networks.sort(function(a, b) {
            if (a.connected !== b.connected) {
                return a.connected ? -1 : 1;
            }

            if (a.known !== b.known) {
                return a.known ? -1 : 1;
            }

            return (b.signalStrength - a.signalStrength);
        });

        return networks;
    }

    function needsPassword(network) {
        if (!network) {
            return false;
        }

        if (network.known) {
            return false;
        }

        return (network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae);
    }

    function connectNetwork(network) {
        if (!network) {
            return ;
        }

        if (network.known || network.security === WifiSecurityType.Open) {
            network.connect();
            return ;
        }

        if (root.needsPassword(network)) {
            root.pendingNetwork = network;
            passwordInput.text = "";
            Qt.callLater(passwordInput.forceActiveFocus);
            return ;
        }

        network.connect();
    }

    function submitPassword() {
        if (!root.pendingNetwork || passwordInput.text.length === 0) {
            return ;
        }

        root.pendingNetwork.connectWithPsk(passwordInput.text);
        passwordInput.text = "";
        root.pendingNetwork = null;
    }

    function cancelPassword() {
        passwordInput.text = "";
        root.pendingNetwork = null;
    }

    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.active && Networking.wifiEnabled
        when: root.wifiDevice !== null
        restoreMode: Binding.RestoreBindingOrValue
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
                radius: 16
                color: Colours.surface1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    TokyoIcon {
                        text: Networking.wifiEnabled ? "󰤨" : "󰤭"
                        font.pixelSize: 25
                        color: Networking.wifiEnabled ? Colours.blue : Colours.muted
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        TokyoText {
                            text: "Wi-Fi"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                        }

                        TokyoText {
                            text: {
                                if (!Networking.wifiHardwareEnabled) {
                                    return "Hardware disabled";
                                }

                                if (!Networking.wifiEnabled) {
                                    return "Disabled";
                                }

                                if (!root.wifiDevice) {
                                    return "No adapter";
                                }

                                const networks = root.wifiNetworks;
                                for (let i = 0; i < networks.length; ++i) {
                                    if (networks[i].connected) {
                                        return networks[i].name;
                                    }
                                }

                                return "Not connected";
                            }

                            font.pixelSize: 11
                            color: Colours.muted
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 24
                        radius: height / 2
                        color: Networking.wifiEnabled ? Colours.blue : Colours.surface2
                        opacity: Networking.wifiHardwareEnabled ? 1 : 0.45

                        Rectangle {
                            width: 18
                            height: 18
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            x: Networking.wifiEnabled ? parent.width - width - 3 : 3
                            color: Colours.text

                            Behavior on x {
                                NumberAnimation {
                                    duration: Animations.fast
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        TapHandler {
                            enabled: Networking.wifiHardwareEnabled
                            onTapped: Networking.wifiEnabled = !Networking.wifiEnabled
                        }

                        HoverHandler {
                            cursorShape: Networking.wifiHardwareEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
                radius: 16
                color: Colours.surface1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    TokyoIcon {
                        text: "󰈀"
                        font.pixelSize: 24
                        color: root.wiredDevice && root.wiredDevice.connected ? Colours.green : Colours.muted
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        TokyoText {
                            text: "Ethernet"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }

                        TokyoText {
                            text: {
                                if (!root.wiredDevice) {
                                    return "No adapter";
                                }

                                if (root.wiredConnected) {
                                    if (root.wiredDevice.linkSpeed > 0) {
                                        return (root.wiredDevice.name + " · " + root.wiredDevice.linkSpeed + " Mbps");
                                    }

                                    return (root.wiredDevice.name + " · Connected");
                                }

                                if (!root.wiredDevice.hasLink) {
                                    return "Cable disconnected";
                                }

                                return "Not connected";
                            }

                            font.pixelSize: 11
                            color: Colours.muted
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            TokyoText {
                text: "Available networks"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Item {
                Layout.fillWidth: true
            }

            TokyoText {
                visible: root.wifiDevice !== null && root.wifiDevice.scannerEnabled
                text: "Scanning…"
                font.pixelSize: 11
                color: Colours.muted
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                anchors.fill: parent
                clip: true
                spacing: 4

                model: ScriptModel {
                    values: root.wifiNetworks
                }

                ScrollBar.vertical: ScrollBar {
                }

                delegate: NetworkRow {
                    required property var modelData

                    width: ListView.view.width
                    network: modelData
                    onConnectRequested: (network) => {
                        return root.connectNetwork(network);
                    }
                }

            }

            Column {
                anchors.centerIn: parent
                visible: !root.wifiDevice || !Networking.wifiEnabled
                spacing: 8

                TokyoIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: !root.wifiDevice ? "󰤮" : "󰤭"
                    font.pixelSize: 34
                    color: Colours.muted
                }

                TokyoText {
                    text: !root.wifiDevice ? "No Wi-Fi adapter" : "Wi-Fi is disabled"
                    font.pixelSize: 13
                    color: Colours.muted
                }

            }

        }

    }

    Rectangle {
        visible: root.pendingNetwork !== null
        anchors.centerIn: parent
        width: 390
        height: 154
        radius: 18
        color: Colours.surface0
        border.width: 1
        border.color: Colours.blue
        z: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            TokyoText {
                text: root.pendingNetwork ? "Connect to " + root.pendingNetwork.name : ""
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: 12
                color: Colours.surface2

                TextInput {
                    id: passwordInput

                    anchors.fill: parent
                    anchors.margins: 12
                    echoMode: TextInput.Password
                    color: Colours.text
                    font.pixelSize: 14
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    onAccepted: root.submitPassword()
                }

            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 75
                    implicitHeight: 30
                    radius: 10
                    color: Colours.surface2

                    TokyoText {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 11
                    }

                    TapHandler {
                        onTapped: root.cancelPassword()
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                }

                Rectangle {
                    implicitWidth: 75
                    implicitHeight: 30
                    radius: 10
                    color: Colours.blue

                    TokyoText {
                        anchors.centerIn: parent
                        text: "Connect"
                        font.pixelSize: 11
                        color: Colours.surface0
                    }

                    TapHandler {
                        onTapped: root.submitPassword()
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
