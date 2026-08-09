import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.components
import qs.theme

Item {
    id: root

    property bool active: false
    readonly property var outputNodes: {
        const source = Pipewire.nodes.values;
        const result = [];
        for (let i = 0; i < source.length; ++i) {
            const node = source[i];
            if (node.audio !== null && !node.isStream && node.isSink) {
                result.push(node);
            }

        }
        result.sort(function(a, b) {
            const aSelected = a === Pipewire.defaultAudioSink;
            const bSelected = b === Pipewire.defaultAudioSink;
            if (aSelected !== bSelected) {
                return aSelected ? -1 : 1;
            }

            return root.nodeName(a).localeCompare(root.nodeName(b));
        });

        return result;
    }
    readonly property var inputNodes: {
        const source = Pipewire.nodes.values;
        const result = [];
        for (let i = 0; i < source.length; ++i) {
            const node = source[i];
            if (node.audio !== null && !node.isStream && !node.isSink) {
                result.push(node);
            }
        }

        result.sort(function(a, b) {
            const aSelected = a === Pipewire.defaultAudioSource;
            const bSelected = b === Pipewire.defaultAudioSource;
            if (aSelected !== bSelected) {
                return aSelected ? -1 : 1;
            }

            return root.nodeName(a).localeCompare(root.nodeName(b));
        });

        return result;
    }

    readonly property var output: Pipewire.defaultAudioSink
    readonly property var input: Pipewire.defaultAudioSource

    function nodeName(node) {
        if (!node) {
            return "No device";
        }

        if (node.description && node.description.length > 0) {
            return node.description;
        }

        if (node.nickname && node.nickname.length > 0) {
            return node.nickname;
        }

        return node.name || "Audio device";
    }

    function clampVolume(value) {
        return Math.max(0, Math.min(1, value));
    }

    function outputVolume() {
        if (!root.output || !root.output.audio) {
            return 0;
        }

        return root.output.audio.volume;
    }

    function inputVolume() {
        if (!root.input || !root.input.audio) {
            return 0;
        }

        return root.input.audio.volume;
    }

    function setOutputVolume(value) {
        if (!root.output || !root.output.audio) {
            return ;
        }

        const newVolume = root.clampVolume(value);
        root.output.audio.volume = newVolume;

        if (newVolume > 0 && root.output.audio.muted) {
            root.output.audio.muted = false;
        }
    }

    function setInputVolume(value) {
        if (!root.input || !root.input.audio) {
            return ;
        }

        const newVolume = root.clampVolume(value);
        root.input.audio.volume = newVolume;
        if (newVolume > 0 && root.input.audio.muted) {
            root.input.audio.muted = false;
        }
    }

    function setOutput(node) {
        if (!node) {
            return ;
        }

        Pipewire.preferredDefaultAudioSink = node;
    }

    function setInput(node) {
        if (!node) {
            return ;
        }

        Pipewire.preferredDefaultAudioSource = node;
    }

    function setVolumeFromMouse(mouseX, width, outputDevice) {
        if (width <= 0) {
            return ;
        }

        const value = root.clampVolume(mouseX / width);
        if (outputDevice) {
            root.setOutputVolume(value);
        } else {
            root.setInputVolume(value);
        }
    }

    PwObjectTracker {
        objects: [root.output, root.input]
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 116
                radius: 16
                color: Colours.surface1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 9

                        TokyoIcon {
                            text: root.output && root.output.audio && root.output.audio.muted ? "󰖁" : "󰕾"
                            font.pixelSize: 21
                            color: root.output ? Colours.blue : Colours.muted
                            Layout.preferredWidth: 24
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            TokyoText {
                                text: "Output"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                            }

                            TokyoText {
                                text: root.nodeName(root.output)
                                font.pixelSize: 10
                                color: Colours.muted
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                        }

                        TokyoText {
                            text: Math.round(root.outputVolume() * 100) + "%"
                            font.pixelSize: 12
                            color: Colours.muted
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25

                        Rectangle {
                            id: outputBar

                            anchors.left: parent.left
                            anchors.right: outputMute.left
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            height: 7
                            radius: height / 2
                            color: Colours.surface2

                            Rectangle {
                                width: parent.width * root.outputVolume()
                                height: parent.height
                                radius: height / 2
                                color: Colours.blue

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Animations.fast
                                    }

                                }

                            }

                            MouseArea {
                                function update(mouseX) {
                                    root.setVolumeFromMouse(mouseX, width, true);
                                }

                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                cursorShape: Qt.PointingHandCursor
                                onPressed: (mouse) => {
                                    return update(mouse.x);
                                }
                                onPositionChanged: (mouse) => {
                                    if (pressed) {
                                        update(mouse.x);
                                    }
                                }
                                onWheel: (wheel) => {
                                    const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                                    root.setOutputVolume(root.outputVolume() + delta);
                                }
                            }

                        }

                        Rectangle {
                            id: outputMute

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 25
                            height: 25
                            radius: 8
                            color: outputMuteHover.hovered ? Colours.surface2 : "transparent"

                            TokyoIcon {
                                anchors.centerIn: parent
                                text: root.output && root.output.audio && root.output.audio.muted ? "󰖁" : "󰕾"
                                font.pixelSize: 15
                                color: root.output && root.output.audio && root.output.audio.muted ? Colours.red : Colours.muted
                            }

                            HoverHandler {
                                id: outputMuteHover

                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                enabled: root.output !== null && root.output.audio !== null
                                onTapped: root.output.audio.muted = !root.output.audio.muted
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 116
                radius: 16
                color: Colours.surface1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 9

                        TokyoIcon {
                            text: root.input && root.input.audio && root.input.audio.muted ? "󰍭" : "󰍬"
                            font.pixelSize: 21
                            color: root.input ? Colours.purple : Colours.muted
                            Layout.preferredWidth: 24
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            TokyoText {
                                text: "Input"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                            }

                            TokyoText {
                                text: root.nodeName(root.input)
                                font.pixelSize: 10
                                color: Colours.muted
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                        }

                        TokyoText {
                            text: Math.round(root.inputVolume() * 100) + "%"
                            font.pixelSize: 12
                            color: Colours.muted
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25

                        Rectangle {
                            id: inputBar

                            anchors.left: parent.left
                            anchors.right: inputMute.left
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            height: 7
                            radius: height / 2
                            color: Colours.surface2

                            Rectangle {
                                width: parent.width * root.inputVolume()
                                height: parent.height
                                radius: height / 2
                                color: Colours.purple

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Animations.fast
                                    }

                                }

                            }

                            MouseArea {
                                function update(mouseX) {
                                    root.setVolumeFromMouse(mouseX, width, false);
                                }

                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed: (mouse) => {
                                    return update(mouse.x);
                                }
                                onPositionChanged: (mouse) => {
                                    if (pressed) {
                                        update(mouse.x);
                                    }
                                }
                                onWheel: (wheel) => {
                                    const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                                    root.setInputVolume(root.inputVolume() + delta);
                                }
                            }
                        }

                        Rectangle {
                            id: inputMute

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 25
                            height: 25
                            radius: 8
                            color: inputMuteHover.hovered ? Colours.surface2 : "transparent"

                            TokyoIcon {
                                anchors.centerIn: parent
                                text: root.input && root.input.audio && root.input.audio.muted ? "󰍭" : "󰍬"
                                font.pixelSize: 15
                                color: root.input && root.input.audio && root.input.audio.muted ? Colours.red : Colours.muted
                            }

                            HoverHandler {
                                id: inputMuteHover

                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                enabled: root.input !== null && root.input.audio !== null
                                onTapped: root.input.audio.muted = !root.input.audio.muted
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            TokyoText {
                text: "Output devices"
                font.pixelSize: 13
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            TokyoText {
                text: "Input devices"
                font.pixelSize: 13
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4

                model: ScriptModel {
                    values: root.outputNodes
                }

                delegate: AudioDeviceRow {
                    required property var modelData

                    width: ListView.view.width
                    node: modelData
                    output: true
                    selected: modelData === Pipewire.defaultAudioSink
                    onSelectedRequested: (node) => {
                        return root.setOutput(node);
                    }
                }

            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4

                model: ScriptModel {
                    values: root.inputNodes
                }

                delegate: AudioDeviceRow {
                    required property var modelData

                    width: ListView.view.width
                    node: modelData
                    output: false
                    selected: modelData === Pipewire.defaultAudioSource
                    onSelectedRequested: (node) => {
                        return root.setInput(node);
                    }
                }
            }
        }
    }
}
