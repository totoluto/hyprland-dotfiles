import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules.activity.dashboard
import qs.services
import qs.theme

DashboardWidget {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 3

        TokyoText {
            text: DashboardPluginSettings.value(root.pluginId, "message", "Dashboard plugins work")
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
        }

        TokyoText {
            visible: DashboardPluginSettings.value(root.pluginId, "showStatus", true)
            text: root.active ? "Active" : "Inactive"
            font.pixelSize: 11
            color: root.active ? Colours.green : Colours.muted
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }

    }

}
