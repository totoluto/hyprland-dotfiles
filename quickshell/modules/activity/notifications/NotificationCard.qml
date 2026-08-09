import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.components
import qs.theme

Rectangle {
    id: root

    property var notification: null
    property bool popup: false
    readonly property string resolvedIcon: {
        if (!root.notification || !root.notification.appIcon || root.notification.appIcon.length === 0) {
            return "";
        }

        return Quickshell.iconPath(root.notification.appIcon, true);
    }

    signal dismissRequested()
    signal actionRequested(var action)

    implicitHeight: Math.max(82, content.implicitHeight + 24)
    radius: Metrics.notificationCardRadius
    color: Colours.surface1
    border.width: 1
    border.color: root.notification && root.notification.urgency === NotificationUrgency.Critical ? Colours.red : Colours.surface2

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30

                IconImage {
                    anchors.fill: parent
                    visible: root.resolvedIcon.length > 0
                    source: root.resolvedIcon
                    implicitSize: 30
                }

                Rectangle {
                    anchors.fill: parent
                    visible: root.resolvedIcon.length === 0
                    radius: 9
                    color: Colours.surface2

                    TokyoText {
                        anchors.fill: parent
                        text: {
                            if (root.notification && root.notification.appName.length > 0) {
                                return root.notification.appName.charAt(0).toUpperCase();
                            }

                            return "?";
                        }

                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: Colours.blue
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                TokyoText {
                    text: root.notification ? (root.notification.appName || "Notification") : ""
                    font.pixelSize: 11
                    color: Colours.muted
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }

                TokyoText {
                    text: root.notification ? (root.notification.summary || "") : ""
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            Rectangle {
                width: 28
                height: 28
                radius: 9
                color: closeHover.hovered ? Colours.surface2 : "transparent"

                TokyoIcon {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.pixelSize: 14
                    color: Colours.muted
                }

                HoverHandler {
                    id: closeHover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.dismissRequested()
                }

            }

        }

        TokyoText {
            visible: root.notification && root.notification.body.length > 0
            text: root.notification ? root.notification.body : ""
            textFormat: Text.PlainText
            font.pixelSize: 12
            color: Colours.muted
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.Wrap
            maximumLineCount: root.popup ? 3 : 6
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        RowLayout {
            visible: root.notification && root.notification.actions.length > 0
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.notification ? root.notification.actions : []

                Rectangle {
                    required property var modelData

                    implicitWidth: actionLabel.implicitWidth + 18
                    implicitHeight: 28
                    radius: 9
                    color: actionHover.hovered ? Colours.surface2 : "transparent"
                    border.width: 1
                    border.color: Colours.surface2

                    TokyoText {
                        id: actionLabel

                        anchors.centerIn: parent
                        text: modelData ? modelData.text : ""
                        font.pixelSize: 11
                    }

                    HoverHandler {
                        id: actionHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (modelData) {
                                root.actionRequested(modelData);
                            }
                        }
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

        }

    }

}
