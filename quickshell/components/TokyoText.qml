import QtQuick
import QtQuick.Layouts
import qs.theme

Text {
    color: Colours.text
    font.family: Typography.textFamily
    font.pixelSize: Metrics.textSize
    font.weight: Typography.normalWeight

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    Layout.alignment: Qt.AlignVCenter

    renderType: Text.NativeRendering
}
