import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: root

    /*
     * Injected by DashboardTab.
     */
    property string pluginId: ""

    anchors.fill: parent
    spacing: 14

    TokyoText {
        text: "Example settings"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignLeft
        Layout.alignment: Qt.AlignLeft
        Layout.fillWidth: true
    }

    TokyoText {
        text: "Configuration for the Example dashboard plugin."
        font.pixelSize: 11
        color: Colours.muted
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignLeft
        Layout.alignment: Qt.AlignLeft
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 58
        radius: 14
        color: Colours.surface1
        border.width: 1
        border.color: Colours.surface0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14

            TokyoText {
                text: "Show activity status"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth: true
            }

            TokyoSwitch {
                id: statusSwitch

                checked: root.pluginId.length > 0 && DashboardPluginSettings.value(root.pluginId, "showStatus", true)
                onToggled: (checked) => {
                    if (root.pluginId.length === 0)
                        return ;

                    DashboardPluginSettings.setValue(root.pluginId, "showStatus", checked);
                }
                Layout.alignment: Qt.AlignVCenter
            }

        }

    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        TokyoText {
            text: "Message"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignLeft
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
        }

        TokyoTextField {
            id: messageField

            Layout.fillWidth: true
            text: root.pluginId.length > 0 ? DashboardPluginSettings.value(root.pluginId, "message", "Dashboard plugins work") : ""
            placeholderText: "Enter a message"
            onEditingFinished: (text) => {
                if (root.pluginId.length === 0)
                    return ;

                DashboardPluginSettings.setValue(root.pluginId, "message", text);
            }
        }

    }

    Item {
        Layout.fillHeight: true
    }

}
