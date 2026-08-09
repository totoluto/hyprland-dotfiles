import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    default property alias content: body.data
    property int shoulderWidth: Metrics.hubShoulderWidth

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            fillColor: Colours.surface0
            startX: root.shoulderWidth
            startY: 0

            PathLine {
                x: root.width - root.shoulderWidth
                y: 0
            }

            PathCubic {
                x: root.width
                y: root.shoulderWidth
                control1X: root.width - root.shoulderWidth * 0.45
                control1Y: 0
                control2X: root.width
                control2Y: root.shoulderWidth * 0.45
            }

            PathLine {
                x: root.width
                y: root.height
            }

            PathLine {
                x: 0
                y: root.height
            }

            PathLine {
                x: 0
                y: root.shoulderWidth
            }

            PathCubic {
                x: root.shoulderWidth
                y: 0
                control1X: 0
                control1Y: root.shoulderWidth * 0.45
                control2X: root.shoulderWidth * 0.45
                control2Y: 0
            }
        }
    }

    Item {
        id: body
        x: root.shoulderWidth
        width: root.width - root.shoulderWidth * 2
        height: root.height
    }

}
