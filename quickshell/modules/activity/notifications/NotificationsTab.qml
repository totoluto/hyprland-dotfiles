import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property bool active: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            TokyoText {
                text: NotificationService.count + (NotificationService.count === 1 ? " notification" : " notifications")
                font.pixelSize: 12
                color: Colours.muted
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                visible: NotificationService.count > 0
                implicitWidth: clearLabel.implicitWidth + 18
                implicitHeight: 28
                radius: 9
                color: clearHover.hovered ? Colours.surface2 : "transparent"

                TokyoText {
                    id: clearLabel

                    anchors.centerIn: parent
                    text: "Clear all"
                    font.pixelSize: 11
                    color: Colours.muted
                }

                HoverHandler {
                    id: clearHover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: NotificationService.dismissAll()
                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                anchors.fill: parent
                visible: NotificationService.count > 0
                clip: true
                spacing: Metrics.notificationCardSpacing

                model: ScriptModel {
                    values: NotificationService.notifications
                }

                delegate: NotificationCard {
                    required property var modelData

                    width: ListView.view.width
                    notification: modelData
                    onDismissRequested: {
                        if (notification) {
                            notification.dismiss();
                        }

                    }
                    onActionRequested: (action) => {
                        if (action) {
                            action.invoke();
                        }

                    }
                }

            }

            Column {
                anchors.centerIn: parent
                visible: NotificationService.count === 0
                spacing: 8

                TokyoIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰂛"
                    font.pixelSize: 36
                    color: Colours.muted
                }

                TokyoText {
                    text: "No notifications"
                    font.pixelSize: 13
                    color: Colours.muted
                }
            }
        }

    }

}
