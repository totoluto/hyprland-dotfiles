import QtQuick
import QtQuick.Layouts
import qs.theme

Item {
    id: root

    property int activeTab: 0

    signal tabSelected(int index)

    RowLayout {
        anchors.fill: parent
        spacing: 6

        ActivityTabButton {
            label: "Notifications"
            icon: "󰂚"
            active: root.activeTab === 0
            onClicked: root.tabSelected(0)
        }

        ActivityTabButton {
            label: "Dashboard"
            icon: "󰕮"
            active: root.activeTab === 1
            onClicked: root.tabSelected(1)
        }

        Item {
            Layout.fillWidth: true
        }

    }

}
