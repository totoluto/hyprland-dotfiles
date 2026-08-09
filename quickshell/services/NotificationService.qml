import Quickshell
import Quickshell.Services.Notifications
pragma Singleton

Singleton {
    id: root

    readonly property var notifications: {
        const source = server.trackedNotifications.values;
        const result = [];
        for (let i = source.length - 1; i >= 0; --i) {
            const notification = source[i];
            if (notification && !notification.transient) {
                result.push(notification);
            }

        }
        return result;
    }
    
    readonly property int count: root.notifications.length

    signal received(var notification)

    function dismissAll() {
        const source = server.trackedNotifications.values;
        const copy = [];
        for (let i = 0; i < source.length; ++i) {
            copy.push(source[i]);
        }
        for (let i = 0; i < copy.length; ++i) {
            if (copy[i])
                copy[i].dismiss();

        }
    }

    NotificationServer {
        id: server

        bodySupported: true
        actionsSupported: true
        imageSupported: true
        bodyImagesSupported: true
        persistenceSupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        inlineReplySupported: false
        keepOnReload: true
        onNotification: (notification) => {
            notification.tracked = true;
            root.received(notification);
        }
    }
}
