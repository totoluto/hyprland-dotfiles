import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.theme

Scope {
    id: root

    property var targetScreen: null
    property var packages: []

    property bool checking: false
    property bool updating: false
    property string checkError: ""

    property bool windowVisible: false
    property bool popupVisible: false

    signal refreshRequested()
    signal updateRequested()

    function show() {
        closeTimer.stop()
        root.windowVisible = true

        Qt.callLater(() => root.popupVisible = true)
    }

    function hide() {
        root.popupVisible = false
        closeTimer.restart()
    }

    function toggle() {
        if (root.windowVisible && root.popupVisible)
            root.hide()
        else
            root.show()
    }

    Timer {
        id: closeTimer
        interval: Animations.normal
        repeat: false

        onTriggered: root.windowVisible = false
    }

    PanelWindow {
        id: popupWindow

        screen: root.targetScreen
        visible: root.windowVisible && root.targetScreen !== null

        implicitWidth: 390
        implicitHeight: 470

        color: "transparent"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        anchors {
            top: true
            left: true
        }

        margins {
            top: Metrics.notificationToastTopOffset
            left: Metrics.calendarPopupSideMargin
        }

        Shortcut {
            sequence: "Escape"
            onActivated: root.hide()
        }

        Item {
            anchors.fill: parent
            clip: true

            Rectangle {
                id: card

                width: parent.width
                height: parent.height

                x: root.popupVisible ? 0 : -width - 16
                opacity: root.popupVisible ? 1 : 0

                radius: Metrics.calendarPopupRadius
                color: Colours.base

                border.width: 1
                border.color: Colours.surface0

                Behavior on x {
                    NumberAnimation {
                        duration: Animations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.fast
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Header
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42

                        Column {
                            anchors {
                                left: parent.left
                                right: closeButton.left
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }

                            spacing: 3

                            TokyoText {
                                width: parent.width

                                text: "System updates"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignLeft
                                color: Colours.text
                            }

                            TokyoText {
                                width: parent.width

                                text: root.checking
                                    ? "Checking packages..."
                                    : root.packages.length + " packages available"

                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignLeft
                                color: Colours.muted
                            }
                        }

                        Rectangle {
                            id: closeButton

                            anchors {
                                top: parent.top
                                right: parent.right
                            }

                            width: 30
                            height: 30
                            radius: 9

                            color: closeHover.hovered
                                ? Colours.surface0
                                : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.fast
                                }
                            }

                            TokyoText {
                                anchors.centerIn: parent

                                text: "×"
                                font.pixelSize: 20
                                color: Colours.text
                            }

                            HoverHandler {
                                id: closeHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: root.hide()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Colours.surface0
                    }

                    // Package list and status
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: packageList

                            anchors.fill: parent
                            clip: true
                            spacing: 7
                            boundsBehavior: Flickable.StopAtBounds

                            model: root.packages

                            visible: !root.checking
                                && root.checkError.length === 0
                                && root.packages.length > 0

                            delegate: Rectangle {
                                id: packageRow

                                required property string modelData

                                readonly property var parts:
                                    modelData.trim().split(/\s+/)

                                readonly property string packageName:
                                    parts.length > 0 ? parts[0] : modelData

                                readonly property string versionText:
                                    parts.length >= 4
                                        ? parts[1] + "  →  " + parts[3]
                                        : modelData.substring(packageName.length).trim()

                                readonly property bool ignored:
                                    modelData.indexOf("[ignored]") !== -1

                                width: packageList.width
                                height: 62
                                radius: 10

                                color: rowHover.hovered
                                    ? Colours.surface0
                                    : Colours.surface1

                                border.width: 1
                                border.color: Colours.surface0

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Animations.fast
                                    }
                                }

                                HoverHandler {
                                    id: rowHover
                                    cursorShape: Qt.PointingHandCursor
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    // Consistent icon column
                                    Rectangle {
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        radius: 9
                                        color: Colours.base

                                        TokyoIcon {
                                            anchors.centerIn: parent

                                            text: "󰏖"
                                            font.pixelSize: 16
                                            color: Colours.blue
                                        }
                                    }

                                    // Name and version always share the same left edge
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        TokyoText {
                                            Layout.fillWidth: true

                                            text: packageRow.packageName
                                            font.pixelSize: 12
                                            font.weight: Font.Medium

                                            horizontalAlignment: Text.AlignLeft
                                            elide: Text.ElideRight
                                            color: Colours.text
                                        }

                                        TokyoText {
                                            Layout.fillWidth: true

                                            text: packageRow.versionText
                                            font.pixelSize: 10

                                            horizontalAlignment: Text.AlignLeft
                                            elide: Text.ElideRight
                                            color: Colours.muted
                                        }
                                    }

                                    // Only present for ignored packages
                                    Rectangle {
                                        visible: packageRow.ignored

                                        Layout.preferredWidth: visible ? 50 : 0
                                        Layout.preferredHeight: 20

                                        radius: 6
                                        color: Colours.surface0

                                        TokyoText {
                                            anchors.centerIn: parent

                                            text: "IGNORED"
                                            font.pixelSize: 8
                                            font.weight: Font.Medium
                                            color: Colours.orange
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent

                            width: parent.width
                            spacing: 8

                            visible: root.checking
                                || root.checkError.length > 0
                                || root.packages.length === 0

                            TokyoIcon {
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: root.checkError.length > 0
                                    ? "󰅚"
                                    : root.checking
                                        ? "󰑐"
                                        : "󰄬"

                                font.pixelSize: 24

                                color: root.checkError.length > 0
                                    ? Colours.red
                                    : root.checking
                                        ? Colours.blue
                                        : Colours.green
                            }

                            TokyoText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width

                                text: root.checkError.length > 0
                                    ? root.checkError
                                    : root.checking
                                        ? "Checking for updates..."
                                        : "System is up to date"

                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                color: root.checkError.length > 0
                                    ? Colours.red
                                    : Colours.muted

                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    // Footer actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        UpdateButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38

                            text: "Refresh"
                            icon: "󰑐"
                            accent: Colours.blue

                            enabled: !root.checking && !root.updating
                            opacity: enabled ? 1 : 0.6

                            onClicked: root.refreshRequested()
                        }

                        UpdateButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38

                            text: root.updating
                                ? "Updating..."
                                : "Update all"

                            icon: "󰏖"
                            accent: Colours.green
                            primary: true

                            enabled: !root.checking && !root.updating
                            opacity: enabled ? 1 : 0.6

                            onClicked: root.updateRequested()
                        }
                    }
                }
            }
        }
    }
}
