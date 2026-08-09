import QtQuick
import QtQuick.Shapes

import qs.theme

Item {
    id: root

    default property alias content: contentItem.data

    property int bodyWidth: Metrics.osdBodyWidthSingle
    property int shoulderWidth: Metrics.osdShoulderWidth

    implicitWidth: bodyWidth + shoulderWidth
    implicitHeight: Metrics.osdCardHeight

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            fillColor: Colours.surface0

            startX: root.width
            startY: 0

            PathLine {
                x: root.shoulderWidth
                y: 0
            }

            PathCubic {
                x: 0
                y: root.shoulderWidth

                control1X: root.shoulderWidth * 0.45
                control1Y: 0

                control2X: 0
                control2Y: root.shoulderWidth * 0.45
            }

            PathLine {
                x: 0
                y: root.height - root.shoulderWidth
            }

            PathCubic {
                x: root.shoulderWidth
                y: root.height

                control1X: 0
                control1Y: root.height - root.shoulderWidth * 0.45

                control2X: root.shoulderWidth * 0.45
                control2Y: root.height
            }

            PathLine {
                x: root.width
                y: root.height
            }

            PathLine {
                x: root.width
                y: 0
            }
        }
    }

    Item {
        id: contentItem

        x: (root.width - root.bodyWidth) / 2
        y: 0

        width: root.bodyWidth
        height: root.height
    }
}