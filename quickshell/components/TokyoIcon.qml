import QtQuick
import QtQuick.Layouts
import qs.theme

Text {
    color: Colours.text
    font.family: Typography.iconFamily
    font.pixelSize: Metrics.iconSize

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    Layout.alignment: Qt.AlignVCenter

    renderType: Text.NativeRendering
}
