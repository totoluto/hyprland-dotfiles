import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.components
import qs.config
import qs.theme

import qs.modules.activity.notifications
import qs.modules.activity.dashboard

Scope {
    id: root

    //
    // Keeps the PanelWindow wide enough while
    // the drawer's closing animation runs.
    //
    property bool windowExpanded: false

    //
    // Actual visual drawer state.
    //
    property bool drawerVisible: false

    property bool handleHovered: false
    property bool drawerHovered: false

    property int activeTab: 0

    function selectMainScreen() {
        const screens = Quickshell.screens

        if (
            !screens
            || screens.length === 0
        ) {
            return null
        }

        //
        // Explicitly configured monitor wins.
        //
        if (
            Settings.mainScreenName.length > 0
        ) {
            for (
                let i = 0;
                i < screens.length;
                ++i
            ) {
                if (
                    screens[i].name
                    === Settings.mainScreenName
                ) {
                    return screens[i]
                }
            }
        }

        //
        // Otherwise use the Hyprland monitor
        // located at logical 0,0.
        //
        for (
            let i = 0;
            i < screens.length;
            ++i
        ) {
            const monitor =
                Hyprland.monitorFor(
                    screens[i]
                )

            if (
                monitor
                && monitor.x === 0
                && monitor.y === 0
            ) {
                return screens[i]
            }
        }

        return screens[0]
    }

    readonly property var mainScreen:
        selectMainScreen()

    //
    // Open the Activity Center.
    //
    // Optional tab:
    // 0 = Notifications
    // 1 = Dashboard
    //
    function show(tab) {
        hoverCloseTimer.stop()
        closeTimer.stop()

        if (tab !== undefined)
            root.activeTab = tab

        if (root.windowExpanded) {
            root.drawerVisible = true
            return
        }

        //
        // First enlarge the PanelWindow, then slide
        // the drawer into it on the next event-loop
        // pass.
        //
        root.windowExpanded = true

        Qt.callLater(function() {
            root.drawerVisible = true
        })
    }

    function hide() {
        if (!root.windowExpanded)
            return

        hoverCloseTimer.stop()

        root.drawerVisible = false

        closeTimer.restart()
    }

    function toggle() {
        if (root.drawerVisible)
            root.hide()
        else
            root.show()
    }

    function selectTab(index) {
        root.activeTab = index
    }

    function hoverEntered() {
        hoverCloseTimer.stop()

        if (!root.drawerVisible)
            root.show()
    }

    function hoverLeft() {
        if (
            root.handleHovered
            || root.drawerHovered
        ) {
            return
        }

        if (root.drawerVisible)
            hoverCloseTimer.restart()
    }

    //
    // Grace period when moving between the
    // handle and drawer.
    //
    Timer {
        id: hoverCloseTimer

        interval:
            Metrics.drawerHoverCloseDelay

        repeat:
            false

        onTriggered: {
            if (
                !root.handleHovered
                && !root.drawerHovered
            ) {
                root.hide()
            }
        }
    }

    //
    // Wait until the slide-out animation is
    // finished before shrinking the PanelWindow
    // back down to handle width.
    //
    Timer {
        id: closeTimer

        interval:
            Animations.normal

        repeat:
            false

        onTriggered:
            root.windowExpanded = false
    }

    //
    // IPC
    //
    IpcHandler {
        target:
            "activity"

        function toggle(): void {
            root.toggle()
        }

        function notifications(): void {
            root.show(0)
        }

        function dashboard(): void {
            root.show(1)
        }

        function hide(): void {
            root.hide()
        }
    }

    //
    // Notification toast below the clock.
    //
    NotificationPopup {
        targetScreen:
            root.mainScreen

        //
        // No redundant popup while Notification
        // history is already visible.
        //
        suppressed:
            root.drawerVisible
            && root.activeTab === 0
    }

    //
    // ACTIVITY CENTER
    //
    PanelWindow {
        id: activityWindow

        screen:
            root.mainScreen

        visible:
            root.mainScreen !== null

        //
        // CLOSED:
        // only the edge card occupies space.
        //
        // OPEN:
        // the complete drawer becomes available.
        //
        implicitWidth:
            root.windowExpanded
                ? Metrics.activityDrawerWidth
                : Metrics.drawerHandleWidth

        implicitHeight:
            Metrics.activityDrawerHeight

        anchors {
            left: true
            top: true
        }

        margins.top: {
            if (!root.mainScreen)
                return 70

            return Math.max(
                70,
                Math.round(
                    (
                        root.mainScreen.height
                        - Metrics.activityDrawerHeight
                        + Metrics.attachedBarHeight
                    )
                    / 2
                )
            )
        }

        color:
            "transparent"

        aboveWindows:
            true

        focusable:
            root.windowExpanded

        exclusionMode:
            ExclusionMode.Ignore

        Shortcut {
            sequence:
                "Escape"

            enabled:
                root.windowExpanded

            onActivated:
                root.hide()
        }

        Item {
            id: viewport

            anchors.fill:
                parent

            //
            // Makes the handle genuinely disappear
            // into the left physical screen edge.
            //
            clip:
                true

            //
            // ACTUAL DRAWER
            //
            ActivityIsland {
                id: drawer

                implicitWidth:
                    Metrics.activityDrawerWidth

                implicitHeight:
                    parent.height

                //
                // Open:
                // completely flush with left edge.
                //
                // Closed:
                // completely outside the screen.
                //
                x:
                    root.drawerVisible
                        ? 0
                        : -width

                opacity:
                    root.drawerVisible
                        ? 1
                        : 0

                Behavior on x {
                    NumberAnimation {
                        duration:
                            Animations.normal

                        easing.type:
                            Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration:
                            Animations.fast

                        easing.type:
                            Easing.OutCubic
                    }
                }

                HoverHandler {
                    id: drawerHover

                    onHoveredChanged: {
                        root.drawerHovered =
                            hovered

                        if (hovered)
                            root.hoverEntered()
                        else
                            root.hoverLeft()
                    }
                }

                ColumnLayout {
                    anchors.fill:
                        parent

                    anchors.leftMargin:
                        Metrics.activityPadding

                    anchors.rightMargin:
                        Metrics.activityPadding

                    anchors.topMargin:
                        Metrics.activityPadding

                    anchors.bottomMargin:
                        Metrics.activityPadding

                    spacing:
                        0

                    //
                    // HEADER
                    //
                    ActivityHeader {
                        Layout.fillWidth:
                            true

                        Layout.preferredHeight:
                            Metrics.activityHeaderHeight

                        activeTab:
                            root.activeTab

                        onTabSelected:
                            index =>
                                root.selectTab(
                                    index
                                )
                    }

                    Rectangle {
                        Layout.fillWidth:
                            true

                        Layout.preferredHeight:
                            1

                        color:
                            Colours.surface1
                    }

                    //
                    // TAB VIEWPORT
                    //
                    Item {
                        id: pageViewport

                        Layout.fillWidth:
                            true

                        Layout.fillHeight:
                            true

                        Layout.topMargin:
                            12

                        clip:
                            true

                        Item {
                            id: pageStrip

                            implicitWidth:
                                pageViewport.width * 2

                            implicitHeight:
                                pageViewport.height

                            x:
                                -root.activeTab
                                * pageViewport.width

                            Behavior on x {
                                NumberAnimation {
                                    duration:
                                        Animations.normal

                                    easing.type:
                                        Easing.OutCubic
                                }
                            }

                            //
                            // Notifications
                            //
                            NotificationsTab {
                                x:
                                    0

                                implicitWidth:
                                    pageViewport.width

                                implicitHeight:
                                    pageViewport.height

                                active:
                                    root.drawerVisible
                                    && root.activeTab === 0
                            }

                            //
                            // Dashboard
                            //
                            DashboardTab {
                                x:
                                    pageViewport.width

                                implicitWidth:
                                    pageViewport.width

                                implicitHeight:
                                    pageViewport.height

                                active:
                                    root.drawerVisible
                                    && root.activeTab === 1
                            }
                        }
                    }
                }
            }

            //
            // SHARED LEFT EDGE CARD
            //
            EdgeDrawerHandle {
                id: handle

                anchors.left:
                    parent.left

                anchors.verticalCenter:
                    parent.verticalCenter

                edge:
                    "left"

                icon:
                    "󰂚"

                drawerOpen:
                    root.drawerVisible

                z:
                    100

                onEntered: {
                    root.handleHovered = true
                    root.hoverEntered()
                }

                onExited: {
                    root.handleHovered = false
                    root.hoverLeft()
                }
            }
        }
    }
}