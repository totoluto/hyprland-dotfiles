import QtQuick
import Quickshell
import qs.services
import qs.theme

Scope {
    id: root

    property var targetScreen: null
    property var notification: null
    property bool windowVisible: false
    property bool popupVisible: false
    property bool suppressed: false

    function timeoutFor(item) {
        if (item && item.expireTimeout > 0) {
            return Math.max(1500, Math.min(item.expireTimeout * 1000, 10000));
        }

        return Metrics.notificationToastDuration;
    }

    function showNotification(item) {
        // Clean up a previous transient toast.

        if (!item || root.suppressed) {
            return;
        }

        if (root.notification && root.notification !== item && root.notification.transient) {
            root.notification.expire();
        }

        root.notification = item;
        root.windowVisible = true;
        Qt.callLater(function() {
            root.popupVisible = true;
            hideTimer.interval = root.timeoutFor(item);
            hideTimer.restart();
        });
    }

    function hidePopup() {
        hideTimer.stop();
        root.popupVisible = false;
        closeTimer.restart();
    }

    Connections {
        function onReceived(notification) {
            root.showNotification(notification);
        }

        target: NotificationService
    }

    Timer {
        id: hideTimer

        repeat: false
        onTriggered: {
            if (root.notification && root.notification.transient){
                root.notification.expire();
            }

            root.hidePopup();
        }
    }

    Timer {
        id: closeTimer

        interval: Animations.normal
        repeat: false
        onTriggered: {
            root.windowVisible = false;
            root.notification = null;
        }
    }

    PanelWindow {
        id: popupWindow

        screen: root.targetScreen
        visible: root.windowVisible && root.targetScreen !== null
        implicitWidth: Metrics.notificationToastWidth
        implicitHeight: popupCard.implicitHeight
        color: "transparent"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore

        anchors {
            left: true
            top: true
        }

        margins {
            left: 14
            top: Metrics.notificationToastTopOffset
        }

        Item {
            anchors.fill: parent
            clip: true

            NotificationCard {
                id: popupCard

                implicitWidth: parent.width
                notification: root.notification
                popup: true
                x: root.popupVisible ? 0 : -width - 10
                opacity: root.popupVisible ? 1 : 0
                onDismissRequested: {
                    if (root.notification)
                        root.notification.dismiss();

                    root.hidePopup();
                }
                onActionRequested: (action) => {
                    if (action) {
                        action.invoke();
                    }

                    root.hidePopup();
                }

                Behavior on x {
                    NumberAnimation {
                        duration: Animations.normal
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.fast
                    }

                }

            }

        }

    }

}
