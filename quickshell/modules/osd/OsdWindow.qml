import QtQuick
import Quickshell
import qs.components
import qs.theme

PanelWindow {
    id: root

    property bool shown: false
    property bool interactiveHold: false
    property bool hoverReveal: false
    property bool handleHovered: false
    property bool panelHovered: false
    property string handleIcon: "󰕾"
    property int cardWidth: Metrics.osdBodyWidthSingle + Metrics.osdShoulderWidth
    property int cardHeight: Metrics.osdCardHeight
    default property alias content: cardHost.data
    readonly property bool expanded: root.shown || root.hoverReveal || root.interactiveHold

    function hoverEntered() {
        hoverCloseTimer.stop();
        root.hoverReveal = true;
    }

    function hoverLeft() {
        if (root.handleHovered || root.panelHovered) {
            return ;
        }

        hoverCloseTimer.restart();
    }

    implicitWidth: root.cardWidth
    implicitHeight: root.cardHeight
    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    onExpandedChanged: inputRegion.changed()
    onInteractiveHoldChanged: {
        if (!root.interactiveHold && !root.handleHovered && !root.panelHovered && root.hoverReveal) {
            hoverCloseTimer.restart();
        }
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: root.screen ? Math.round((root.screen.height - root.cardHeight + Metrics.attachedBarHeight) / 2) : 0
    }

    Timer {
        id: hoverCloseTimer

        interval: Metrics.drawerHoverCloseDelay
        repeat: false
        onTriggered: {
            if (!root.handleHovered && !root.panelHovered && !root.interactiveHold) {
                root.hoverReveal = false;
            }
        }
    }

    Item {
        id: viewport
        anchors.fill: parent
        clip: true

        Item {
            id: cardHost

            width: root.cardWidth
            height: root.cardHeight
            x: root.expanded ? 0 : root.width
            opacity: root.expanded ? 1 : 0

            HoverHandler {
                id: panelHover

                onHoveredChanged: {
                    root.panelHovered = hovered;
                    if (hovered) {
                        root.hoverEntered();
                    } else {
                        root.hoverLeft();
                    }
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: Animations.normal
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.fast
                    easing.type: Easing.OutCubic
                }
            }

        }

        EdgeDrawerHandle {
            id: handle

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            edge: "right"
            icon: root.handleIcon
            drawerOpen: root.expanded
            z: 100
            onEntered: {
                root.handleHovered = true;
                root.hoverEntered();
            }
            onExited: {
                root.handleHovered = false;
                root.hoverLeft();
            }
        }

    }

    mask: Region {
        id: inputRegion

        x: root.expanded ? 0 : root.width - Metrics.drawerHandleWidth
        y: root.expanded ? 0 : Math.round((root.height - Metrics.drawerHandleHeight) / 2)
        width: root.expanded ? root.width : Metrics.drawerHandleWidth
        height: root.expanded ? root.height : Metrics.drawerHandleHeight
    }
}
