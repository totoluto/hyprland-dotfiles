import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.components
import qs.theme

Item {
    id: root

    property bool active: false
    readonly property var players: Mpris.players.values
    property int selectedIndex: 0
    readonly property var player: {
        if (!root.players || root.players.length === 0) {
            return null;
        }

        if (root.selectedIndex >= root.players.length) {
            return root.players[0];
        }

        return root.players[root.selectedIndex];
    }

    readonly property bool hasPlayer: root.player !== null
    readonly property real progress: {
        if (!root.player || !root.player.positionSupported || !root.player.lengthSupported || root.player.length <= 0) {
            return 0;
        }

        return Math.max(0, Math.min(1, root.player.position / root.player.length));
    }

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0) {
            return "0:00";
        }

        const total = Math.floor(seconds);
        const minutes = Math.floor(total / 60);
        const secs = total % 60;

        return minutes + ":" + secs.toString().padStart(2, "0");
    }

    function selectBestPlayer() {
        if (!root.players || root.players.length === 0) {
            root.selectedIndex = 0;
            return ;
        }
        
        for (let i = 0; i < root.players.length; ++i) {
            if (root.players[i].isPlaying) {
                root.selectedIndex = i;
                return ;
            }
        }
        
        if (root.selectedIndex >= root.players.length) {
            root.selectedIndex = 0;
        }
    }

    Component.onCompleted: root.selectBestPlayer()

    Timer {
        interval: 500
        repeat: true
        running: root.active && root.player !== null && root.player.isPlaying && root.player.positionSupported
        onTriggered: root.player.positionChanged()
    }

    Connections {
        function onValuesChanged() {
            root.selectBestPlayer();
        }

        target: Mpris.players
    }

    Column {
        anchors.centerIn: parent
        visible: !root.hasPlayer
        spacing: 10

        TokyoIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "󰝛"
            font.pixelSize: 42
            color: Colours.muted
        }

        TokyoText {
            text: "Nothing is playing"
            font.pixelSize: 17
            color: Colours.muted
        }

        TokyoText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Start a media player and it will appear here."
            font.pixelSize: 12
            color: Colours.muted
        }

    }

    ColumnLayout {
        anchors.fill: parent
        visible: root.hasPlayer
        spacing: 16

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - 40, 680)
                spacing: 30

                Rectangle {
                    Layout.preferredWidth: Metrics.mediaArtSize
                    Layout.preferredHeight: Metrics.mediaArtSize
                    Layout.alignment: Qt.AlignVCenter
                    radius: Metrics.mediaArtRadius
                    color: Colours.surface1
                    clip: true

                    Image {
                        anchors.fill: parent
                        visible: root.player && root.player.trackArtUrl.length > 0
                        source: root.player ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: Metrics.mediaArtSize
                        sourceSize.height: Metrics.mediaArtSize
                    }

                    Column {
                        anchors.centerIn: parent
                        visible: !root.player || root.player.trackArtUrl.length === 0
                        spacing: 7

                        TokyoIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰝚"
                            font.pixelSize: 44
                            color: Colours.blue
                        }

                        TokyoText {
                            text: root.player ? root.player.identity : ""
                            font.pixelSize: 12
                            color: Colours.muted
                        }

                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Metrics.mediaArtSize
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 5

                    TokyoText {
                        text: root.player ? (root.player.trackTitle || "Unknown Title") : ""
                        font.pixelSize: 23
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    TokyoText {
                        text: root.player ? (root.player.trackArtist || "Unknown Artist") : ""
                        font.pixelSize: 15
                        color: Colours.muted
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    TokyoText {
                        visible: root.player && root.player.trackAlbum.length > 0
                        text: root.player ? root.player.trackAlbum : ""
                        font.pixelSize: 12
                        color: Colours.muted
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.bottomMargin: 12
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28

                        Rectangle {
                            id: progressTrack

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: Metrics.mediaProgressHeight
                            radius: height / 2
                            color: Colours.surface1

                            Rectangle {
                                width: parent.width * root.progress
                                height: parent.height
                                radius: height / 2

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal

                                    GradientStop {
                                        position: 0
                                        color: Colours.blue
                                    }

                                    GradientStop {
                                        position: 1
                                        color: Colours.purple
                                    }

                                }

                                Behavior on width {
                                    enabled: !seekArea.pressed

                                    NumberAnimation {
                                        duration: Animations.fast
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: seekArea

                            function seekTo(mouseX) {
                                if (!root.player) {
                                    return ;
                                }

                                const ratio = Math.max(0, Math.min(1, mouseX / width));
                                root.player.position = ratio * root.player.length;
                            }

                            anchors.fill: parent
                            enabled: root.player !== null && root.player.canSeek && root.player.positionSupported && root.player.lengthSupported && root.player.length > 0
                            hoverEnabled: true
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onPressed: (mouse) => {
                                return seekTo(mouse.x);
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    seekTo(mouse.x);
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        TokyoText {
                            text: root.player ? root.formatTime(root.player.position) : "0:00"
                            font.pixelSize: 11
                            color: Colours.muted
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        TokyoText {
                            text: root.player ? root.formatTime(root.player.length) : "0:00"
                            font.pixelSize: 11
                            color: Colours.muted
                        }

                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        MediaButton {
                            icon: "󰒮"
                            enabled: root.player !== null && root.player.canGoPrevious
                            onClicked: root.player.previous()
                        }

                        MediaButton {
                            primary: true
                            icon: root.player && root.player.isPlaying ? "" : ""
                            enabled: root.player !== null && root.player.canTogglePlaying
                            onClicked: root.player.togglePlaying()
                        }

                        MediaButton {
                            icon: "󰒭"
                            enabled: root.player !== null && root.player.canGoNext
                            onClicked: root.player.next()
                        }

                    }

                }

            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Metrics.mediaPlayerChipHeight
            spacing: 8
            visible: root.players && root.players.length > 1

            Repeater {
                model: root.players

                PlayerChip {
                    required property int index
                    required property var modelData

                    player: modelData
                    selected: root.selectedIndex === index
                    onClicked: root.selectedIndex = index
                }
            }
        }
    }
}
