import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Item {
    id: root

    property string pendingAction: ""

    signal actionRequested(string action)
    signal confirmRequested()
    signal cancelRequested()

    implicitHeight: Metrics.hubFooterHeight

    RowLayout {
        anchors.centerIn: parent
        spacing: 12
        visible: root.pendingAction.length === 0

        HubActionButton {
            label: "Lock"
            icon: "󰌾"
            onClicked: root.actionRequested("lock")
        }

        HubActionButton {
            label: "Restart"
            icon: "󰜉"
            accent: Colours.yellow
            onClicked: root.actionRequested("restart")
        }

        HubActionButton {
            label: "Power off"
            icon: "󰐥"
            accent: Colours.red
            onClicked: root.actionRequested("poweroff")
        }

        HubActionButton {
            label: "Hibernate"
            icon: "󰒲"
            accent: Colours.purple
            onClicked: root.actionRequested("hibernate")
        }

    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 18
        visible: root.pendingAction.length > 0

        TokyoText {
            text: {
                switch (root.pendingAction) {
                case "restart":
                    return "Restart the computer?";
                case "poweroff":
                    return "Power off the computer?";
                case "hibernate":
                    return "Hibernate the computer?";
                default:
                    return "";
                }
            }
            font.pixelSize: 14
        }

        HubActionButton {
            label: "Cancel"
            icon: "󰅖"
            onClicked: root.cancelRequested()
        }

        HubActionButton {
            label: "Confirm"
            icon: "󰄬"
            accent: Colours.red
            onClicked: root.confirmRequested()
        }

    }

}
