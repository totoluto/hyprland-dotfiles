import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Item {
    id: root

    property bool active: false
    property int page: 0

    RowLayout {
        anchors.fill: parent
        spacing: 16

        ColumnLayout {
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            spacing: 5

            ControlNavButton {
                icon: "󰤨"
                label: "Network"
                active: root.page === 0
                onClicked: root.page = 0
            }

            ControlNavButton {
                icon: "󰂯"
                label: "Bluetooth"
                active: root.page === 1
                onClicked: root.page = 1
            }

            ControlNavButton {
                icon: "󰕾"
                label: "Sound"
                active: root.page === 2
                onClicked: root.page = 2
            }

            Item {
                Layout.fillHeight: true
            }

        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: Colours.surface1
        }

        Item {
            id: pageViewport

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Item {
                id: pageStrip

                width: pageViewport.width * 3
                height: pageViewport.height
                x: -root.page * pageViewport.width

                NetworkPanel {
                    x: 0
                    width: pageViewport.width
                    height: pageViewport.height
                    active: root.active && root.page === 0
                }

                BluetoothPanel {
                    id: bluetoothPanel

                    x: pageViewport.width
                    width: pageViewport.width
                    height: pageViewport.height
                    active: root.active && root.page === 1
                }

                SoundPanel {
                    id: soundPanel

                    x: pageViewport.width * 2
                    width: pageViewport.width
                    height: pageViewport.height
                    active: root.active && root.page === 2
                }

                Behavior on x {
                    NumberAnimation {
                        duration: Animations.normal
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

}
