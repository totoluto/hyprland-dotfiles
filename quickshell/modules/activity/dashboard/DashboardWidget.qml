import QtQuick
import QtQuick.Layouts
import qs.components
import qs.theme

Rectangle {
    id: root

    property string pluginId: ""
    property string title: "Widget"
    property string icon: ""
    property bool active: false
    property int preferredColumns: 1
    property int preferredRows: 1
    default property alias content: body.data

    radius: 16
    color: Colours.surface1
    border.width: 1
    border.color: Colours.surface2

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            TokyoIcon {
                visible: root.icon.length > 0
                text: root.icon
                font.pixelSize: 16
                color: Colours.blue
            }

            TokyoText {
                text: root.title
                font.pixelSize: 13
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }

        }

        Item {
            id: body

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }

}
