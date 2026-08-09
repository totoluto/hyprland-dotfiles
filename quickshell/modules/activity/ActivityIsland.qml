import QtQuick
import qs.theme

Rectangle {
    id: root

    radius: Metrics.activityRadius
    color: Colours.surface0

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.radius
        color: root.color
    }

}
