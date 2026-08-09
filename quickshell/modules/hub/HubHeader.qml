import QtQuick
import QtQuick.Layouts
import qs.theme

Item {
    id: root

    required property int activeTab

    signal tabSelected(int index)

    implicitHeight: Metrics.hubHeaderHeight

    RowLayout {
        anchors.centerIn: parent
        spacing: Metrics.hubTabSpacing

        HubTabButton {
            label: "Apps"
            icon: "󰀻"
            active: root.activeTab === 0
            onClicked: root.tabSelected(0)
        }

        HubTabButton {
            label: "Media"
            icon: "󰝚"
            active: root.activeTab === 1
            onClicked: root.tabSelected(1)
        }

        HubTabButton {
            label: "Performance"
            icon: "󰓅"
            active: root.activeTab === 2
            onClicked: root.tabSelected(2)
        }

        HubTabButton {
            label: "Controls"
            icon: "󰒓"
            active: root.activeTab === 3
            onClicked: root.tabSelected(3)
        }

    }

}
