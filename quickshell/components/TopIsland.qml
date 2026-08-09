import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property string placement: "center"
    property int horizontalPadding: Metrics.pillHorizontalPadding
    property int edgePadding: Metrics.barSideMargin
    property int shoulderWidth: placement === "center"
        ? Metrics.centerIslandShoulder
        : Metrics.sideIslandShoulder
    property int contentSpacing: 0

    default property alias content: contentRow.data

    readonly property real bodyWidth: contentRow.implicitWidth + horizontalPadding * 2
    readonly property real edgeExtra: placement === "center" ? 0 : edgePadding

    implicitWidth: bodyWidth + shoulderWidth * (placement === "center" ? 2 : 1) + edgeExtra
    implicitHeight: Metrics.attachedBarHeight

    Shape {
        anchors.fill: parent
        visible: root.placement === "left"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: Colours.surface0
            startX: 0
            startY: 0

            PathLine { x: root.width; y: 0 }
            PathCubic {
                x: root.width - root.shoulderWidth
                y: root.height
                control1X: root.width - root.shoulderWidth * 0.20
                control1Y: 0
                control2X: root.width - root.shoulderWidth * 0.55
                control2Y: root.height
            }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }
        }
    }

    Shape {
        anchors.fill: parent
        visible: root.placement === "center"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: Colours.surface0
            startX: 0
            startY: 0

            PathLine { x: root.width; y: 0 }
            PathCubic {
                x: root.width - root.shoulderWidth
                y: root.height
                control1X: root.width - root.shoulderWidth * 0.20
                control1Y: 0
                control2X: root.width - root.shoulderWidth * 0.55
                control2Y: root.height
            }
            PathLine { x: root.shoulderWidth; y: root.height }
            PathCubic {
                x: 0
                y: 0
                control1X: root.shoulderWidth * 0.55
                control1Y: root.height
                control2X: root.shoulderWidth * 0.20
                control2Y: 0
            }
        }
    }

    Shape {
        anchors.fill: parent
        visible: root.placement === "right"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: Colours.surface0
            startX: 0
            startY: 0

            PathCubic {
                x: root.shoulderWidth
                y: root.height
                control1X: root.shoulderWidth * 0.20
                control1Y: 0
                control2X: root.shoulderWidth * 0.55
                control2Y: root.height
            }
            PathLine { x: root.width; y: root.height }
            PathLine { x: root.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    RowLayout {
        id: contentRow
        spacing: root.contentSpacing

        anchors.verticalCenter: parent.verticalCenter

        x: {
            if (root.placement === "left") {
                return root.edgePadding + root.horizontalPadding
            }

            if (root.placement === "right") {
                return root.shoulderWidth + root.horizontalPadding
            }
            
            return (root.width - implicitWidth) / 2
        }
    }
}
