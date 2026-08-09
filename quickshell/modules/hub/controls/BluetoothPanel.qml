import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components
import qs.theme

Item {
    id: root

    property bool active: false
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: {
        if (!root.adapter) {
            return [];
        }

        const source = root.adapter.devices.values;
        const result = [];
        for (let i = 0; i < source.length; ++i) {
            const device = source[i];
            if (root.shouldShowDevice(device)) {
                result.push(device);
            }
        }
        result.sort(function(a, b) {
            if (a.connected !== b.connected) {
                return a.connected ? -1 : 1;
            }

            if (a.paired !== b.paired) {
                return a.paired ? -1 : 1;
            }

            return root.deviceName(a).toLowerCase().localeCompare(root.deviceName(b).toLowerCase());
        });

        return result;
    }

    function deviceName(device) {
        if (!device) {
            return "";
        }

        return (device.name || device.deviceName || "").trim();
    }

    function isMacLikeName(name, address) {
        if (!name || name.length === 0) {
            return true;
        }

        const normalizedName = name.trim().toUpperCase();
        const normalizedAddress = (address || "").trim().toUpperCase();
        if (normalizedAddress.length > 0 && normalizedName === normalizedAddress) {
            return true;
        }

        if (/^[0-9A-F]{2}(:[0-9A-F]{2}){5}$/.test(normalizedName)) {
            return true;
        }

        if (/^[0-9A-F]{2}(-[0-9A-F]{2}){5}$/.test(normalizedName)) {
            return true;
        }

        if (/^DEVICE\s+[0-9A-F]{2}(:[0-9A-F]{2}){5}$/.test(normalizedName)) {
            return true;
        }

        return false;
    }

    function shouldShowDevice(device) {
        if (!device) {
            return false;
        }

        if (device.connected || device.paired) {
            return true;
        }

        const name = root.deviceName(device);
        if (root.isMacLikeName(name, device.address)) {
            return false;
        }

        return true;
    }

    Binding {
        when: root.adapter !== null
        target: root.adapter
        property: "discovering"
        value: root.active && root.adapter !== null && root.adapter.enabled
        restoreMode: Binding.RestoreBindingOrValue
    }

    ColumnLayout {
        anchors.fill: parent
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
                    text: root.adapter && root.adapter.enabled ? "󰂯" : "󰂲"
                    font.pixelSize: 25
                    color: root.adapter && root.adapter.enabled ? Colours.blue : Colours.muted
                    Layout.preferredWidth: 28
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    TokyoText {
                        text: "Bluetooth"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                    }

                    TokyoText {
                        text: {
                            if (!root.adapter) {
                                return "No adapter";
                            }

                            if (!root.adapter.enabled) {
                                return "Disabled";
                            }

                            let connected = 0;
                            for (let i = 0; i < root.devices.length; ++i) {
                                if (root.devices[i].connected) {
                                    ++connected;
                                }
                            }
                            if (connected === 1) {
                                return "1 device connected";
                            }

                            if (connected > 1) {
                                return (connected + " devices connected");
                            }

                            return root.adapter.name || root.adapter.adapterId;
                        }

                        font.pixelSize: 11
                        color: Colours.muted
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    visible: root.adapter !== null
                    width: 42
                    height: 24
                    radius: height / 2
                    color: root.adapter && root.adapter.enabled ? Colours.blue : Colours.surface2

                    Rectangle {
                        width: 18
                        height: 18
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.adapter && root.adapter.enabled ? parent.width - width - 3 : 3
                        color: Colours.text

                        Behavior on x {
                            NumberAnimation {
                                duration: Animations.fast
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (!root.adapter) {
                                return ;
                            }

                            root.adapter.enabled = !root.adapter.enabled;
                        }
                    }

                }

            }

        }

        RowLayout {
            Layout.fillWidth: true

            TokyoText {
                text: "Devices"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                visible: root.adapter && root.adapter.enabled && root.adapter.discovering
                spacing: 5

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: Colours.blue

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 0.35
                            to: 1
                            duration: 650
                        }

                        NumberAnimation {
                            from: 1
                            to: 0.35
                            duration: 650
                        }

                    }

                }

                TokyoText {
                    text: "Searching…"
                    font.pixelSize: 11
                    color: Colours.muted
                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                anchors.fill: parent
                visible: root.adapter && root.adapter.enabled && root.devices.length > 0
                clip: true
                spacing: 4

                model: ScriptModel {
                    values: root.devices
                }

                delegate: BluetoothRow {
                    required property var modelData

                    width: ListView.view.width
                    device: modelData
                }

            }

            Column {
                anchors.centerIn: parent
                visible: !root.adapter || !root.adapter.enabled || root.devices.length === 0
                spacing: 8

                TokyoIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (!root.adapter) {
                            return "󰂲";
                        }

                        if (!root.adapter.enabled) {
                            return "󰂲";
                        }

                        return "󰂯";
                    }
                    font.pixelSize: 34
                    color: Colours.muted
                }

                TokyoText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (!root.adapter) {
                            return "No Bluetooth adapter";
                        }

                        if (!root.adapter.enabled) {
                            return "Bluetooth is disabled";
                        }

                        return "Searching for devices…";
                    }
                    font.pixelSize: 13
                    color: Colours.muted
                }
            }
        }
    }
}
