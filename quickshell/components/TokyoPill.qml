import QtQuick
import QtQuick.Layouts
import qs.theme

Rectangle {
    id: root

    default property alias content: contentRow.data

    property int horizontalPadding: Metrics.pillHorizontalPadding
    property int verticalPadding: Metrics.pillVerticalPadding
    property int contentSpacing: 0

    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: Metrics.pillHeight

    color: Colours.surface0
    radius: Metrics.pillRadius

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        spacing: root.contentSpacing
    }
}
