import QtQuick
import Quickshell

pragma Singleton

Singleton {
    //
    // Attached top bar
    //
    readonly property int attachedBarHeight: 49
    readonly property int attachedContentCenterY: 30

    readonly property int barSideMargin: 24

    //
    // Width of the curved transition back into
    // the screen edge.
    //
    readonly property int sideIslandShoulder: 52
    readonly property int centerIslandShoulder: 72

    //
    // Original Waybar-derived content sizing.
    //
    readonly property int pillHeight: 32
    readonly property int pillRadius: 28

    readonly property int pillHorizontalPadding: 12
    readonly property int pillVerticalPadding: 6

    readonly property int textSize: 18
    readonly property int iconSize: 21

    readonly property int notificationIconSize: 22

    readonly property int textOpticalOffsetY: -1

    readonly property int workspaceSpacing: 4
    readonly property int workspaceWidth: 28
    readonly property int workspaceActiveWidth: 40
    readonly property int workspaceRadius: 16

    readonly property int traySpacing: 6
    readonly property int rightModuleSpacing: 12

    //
    // Shared edge drawer handles
    //
    // Used by:
    // - Activity Center on the left
    // - Volume/Brightness OSD on the right
    //
    readonly property int drawerHandleWidth: 32
    readonly property int drawerHandleHeight: 48
    readonly property int drawerHandleRadius: 11

    readonly property int drawerHandleIconSize: 17

    //
    // How far the handle retreats into the
    // physical screen border when its drawer opens.
    //
    readonly property int drawerHandleHiddenOffset: 28

    //
    // Grace period when moving between the handle
    // and the actual drawer.
    //
    readonly property int drawerHoverCloseDelay: 240

    //
    // Right-side OSD
    //
    readonly property int osdBodyWidthSingle: 58
    readonly property int osdBodyWidthDual: 112

    readonly property int osdShoulderWidth: 34
    readonly property int osdCardHeight: 215

    readonly property int osdVerticalPadding: 14

    readonly property int osdControlWidth: 42
    readonly property int osdControlSpacing: 14

    readonly property int osdIconSize: 23

    readonly property int osdBarWidth: 8
    readonly property int osdBarTouchWidth: 28

    readonly property int osdTimeout: 1500

    //
    // Shell Hub
    //
    readonly property int hubWidth: 860
    readonly property int hubHeight: 560

    readonly property int hubShoulderWidth: 68

    readonly property int hubHorizontalPadding: 24
    readonly property int hubVerticalPadding: 16

    readonly property int hubHeaderHeight: 58
    readonly property int hubFooterHeight: 62

    readonly property int hubTabHeight: 38
    readonly property int hubTabRadius: 14
    readonly property int hubTabSpacing: 8

    readonly property int hubSearchHeight: 50
    readonly property int hubSearchRadius: 15

    readonly property int hubResultHeight: 60
    readonly property int hubResultRadius: 14
    readonly property int hubResultIconSize: 36
    readonly property int hubResultSpacing: 5

    //
    // Media tab
    //
    readonly property int mediaArtSize: 190
    readonly property int mediaArtRadius: 18

    readonly property int mediaControlSize: 44
    readonly property int mediaPlaySize: 54

    readonly property int mediaProgressHeight: 7

    readonly property int mediaPlayerChipHeight: 34

    //
    // Activity Center
    //
    readonly property int activityDrawerWidth: 390
    readonly property int activityDrawerHeight: 560

    readonly property int activityRadius: 22
    readonly property int activityPadding: 16

    readonly property int activityHeaderHeight: 48
    readonly property int activityTabHeight: 34

    //
    // Notifications
    //
    readonly property int notificationToastWidth: 360
    readonly property int notificationToastTopOffset: 58
    readonly property int notificationToastDuration: 5000

    readonly property int notificationCardRadius: 15
    readonly property int notificationCardSpacing: 8

    //
    // Dashboard
    //
    readonly property int dashboardRowHeight: 135
    readonly property int dashboardSpacing: 10

    // Calendar popup
    readonly property int calendarPopupWidth: 360
    readonly property int calendarPopupHeight: 356
    readonly property int calendarPopupRadius: 18
    readonly property int calendarPopupSideMargin: 14
}