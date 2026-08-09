import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.components
import qs.config
import qs.theme

import qs.modules.hub.apps
import qs.modules.hub.media
import qs.modules.hub.performance
import qs.modules.hub.controls

Scope {
    id: root

    property bool windowVisible: false
    property bool hubVisible: false

    property int activeTab: 0
    property string pendingPowerAction: ""

    function selectMainScreen() {
        const screens = Quickshell.screens

        if (!screens || screens.length === 0)
            return null

        if (Settings.mainScreenName.length > 0) {
            for (let i = 0; i < screens.length; ++i) {
                if (screens[i].name === Settings.mainScreenName)
                    return screens[i]
            }
        }


        for (let i = 0; i < screens.length; ++i) {
            const monitor =
                Hyprland.monitorFor(screens[i])

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

    readonly property var mainScreen: selectMainScreen()

    function show() {
        if (root.windowVisible) {
            return
        }

        root.activeTab = 0
        root.pendingPowerAction = ""

        root.windowVisible = true

        Qt.callLater(function() {
            root.hubVisible = true

            Qt.callLater(appsTab.reset)
        })
    }

    function hide() {
        if (!root.windowVisible) {
            return
        }

        root.hubVisible = false
        closeTimer.restart()
    }

    function toggle() {
        if (root.windowVisible) {
            root.hide()
        } else {
            root.show()
        }
    }

    function selectTab(index) {
        root.activeTab = index

        if (index === 0) {
            Qt.callLater(appsTab.focusSearch)
        }
    }

    function requestPowerAction(action) {
        if (action === "lock") {
            root.hide()

            Quickshell.execDetached([
                "hyprlock"
            ])

            return
        }

        root.pendingPowerAction = action
    }

    function executePowerAction() {
        const action = root.pendingPowerAction

        root.pendingPowerAction = ""

        if (action === "restart") {
            Quickshell.execDetached([
                "systemctl",
                "reboot"
            ])
        } else if (action === "poweroff") {
            Quickshell.execDetached([
                "systemctl",
                "poweroff"
            ])
        } else if (action === "hibernate") {
            Quickshell.execDetached([
                "systemctl",
                "hibernate"
            ])
        }
    }

    Timer {
        id: closeTimer
        interval: Animations.normal
        repeat: false
        onTriggered: root.windowVisible = false
    }

    IpcHandler {
        target: "hub"

        function toggle(): void {
            root.toggle()
        }

        function show(): void {
            root.show()
        }

        function hide(): void {
            root.hide()
        }
    }

    PanelWindow {
        id: hubWindow

        screen: root.mainScreen

        visible: root.windowVisible && root.mainScreen !== null

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        focusable: true
        aboveWindows: true

        exclusionMode: ExclusionMode.Ignore

        Shortcut {
            sequence: "Escape"

            onActivated:
                root.hide()
        }

        Rectangle {
            anchors.fill: parent

            color: "#000000"

            opacity: root.hubVisible ? 0.28 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration:
                        Animations.normal
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: root.hide()
            }
        }

        BottomIsland {
            id: island

            width: Metrics.hubWidth
            height: Metrics.hubHeight

            anchors.horizontalCenter: parent.horizontalCenter

            y: root.hubVisible ? parent.height - height : parent.height + 24

            opacity: root.hubVisible ? 1 : 0

            Behavior on y {
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
                }
            }

            MouseArea {
                anchors.fill: parent
                z: -1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Metrics.hubHorizontalPadding
                anchors.rightMargin: Metrics.hubHorizontalPadding
                anchors.topMargin: Metrics.hubVerticalPadding
                spacing: 0

                HubHeader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Metrics.hubHeaderHeight
                    activeTab: root.activeTab
                    onTabSelected: index => root.selectTab(index)
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    color: Colours.surface1
                }

                
                Item {
                    id: tabViewport

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.topMargin: 14
                    Layout.bottomMargin: 14

                    clip: true

                    Item {
                        id: tabStrip

                        width: tabViewport.width * 4
                        height: tabViewport.height

                        x: -root.activeTab * tabViewport.width

                        Behavior on x {
                            NumberAnimation {
                                duration: Animations.normal
                                easing.type: Easing.OutCubic
                            }
                        }

                        AppsTab {
                            id: appsTab

                            x: 0
                            width: tabViewport.width
                            height: tabViewport.height
                            onRequestClose: root.hide()
                        }

                        MediaTab {
                            id: mediaTab

                            x: tabViewport.width
                            width: tabViewport.width
                            height: tabViewport.height
                            active: root.hubVisible && root.activeTab === 1
                        }

                        PerformanceTab {
                            id: performanceTab

                            x: tabViewport.width * 2
                            width: tabViewport.width
                            height: tabViewport.height
                            active: root.hubVisible && root.activeTab === 2
                        }

                        ControlsTab {
                            id: controlsTab

                            x: tabViewport.width * 3
                            width: tabViewport.width
                            height: tabViewport.height
                            active: root.hubVisible && root.activeTab === 3
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    color: Colours.surface1
                }

                HubFooter {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Metrics.hubFooterHeight
                    pendingAction: root.pendingPowerAction
                    onActionRequested: action => root.requestPowerAction(action)
                    onCancelRequested: root.pendingPowerAction = ""
                    onConfirmRequested: root.executePowerAction()
                }
            }
        }
    }
}