import QtQuick
import Quickshell
import Quickshell.Io
import qs.components
import qs.theme

Item {
    id: root

    property var targetScreen: null
    property var packages: []
    property var repoPackages: []
    property var aurPackages: []

    property bool updating: false
    property bool checking: false
    property bool repoCheckDone: false
    property bool aurCheckDone: false

    property int repoExitCode: -1
    property int aurExitCode: -1
    property string checkError: ""

    implicitWidth: Metrics.iconSize
    implicitHeight: Metrics.iconSize

    function parseUpdates(output) {
        return output.split("\n")
            .map(line => line.trim())
            .filter(line => line.length > 0)
    }

    function refresh() {
        if (root.checking || root.updating)
            return

        root.checking = true
        root.checkError = ""
        root.repoCheckDone = false
        root.aurCheckDone = false
        root.repoExitCode = -1
        root.aurExitCode = -1

        repoProc.running = true
        aurProc.running = true
    }

    function finishRefresh() {
        if (!root.repoCheckDone || !root.aurCheckDone)
            return

        root.checking = false

        const repoOk = root.repoExitCode === 0
            || root.repoExitCode === 2
        const aurOk = root.aurExitCode === 0

        if (!repoOk || !aurOk) {
            if (!repoOk && !aurOk)
                root.checkError = "Repository and AUR checks failed"
            else if (!repoOk)
                root.checkError = "Repository update check failed"
            else
                root.checkError = "AUR update check failed"

            console.warn(root.checkError,
                "repository exit:", root.repoExitCode,
                "AUR exit:", root.aurExitCode)
            return
        }

        root.packages = [
            ...root.repoPackages,
            ...root.aurPackages
        ]

        root.checkError = ""
        console.log("Update check finished:", root.packages.length, "updates")
    }

    function startUpdate() {
        if (root.updating || root.checking)
            return

        root.updating = true
        updateProc.running = true
    }

    Process {
        id: repoProc
        command: ["checkupdates", "--nocolor"]

        stdout: StdioCollector {
            id: repoOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.repoPackages = root.parseUpdates(repoOutput.text)
            root.repoExitCode = exitCode
            root.repoCheckDone = true
            root.finishRefresh()
        }
    }

    Process {
        id: aurProc
        command: ["paru", "-Qua", "--color", "never"]

        stdout: StdioCollector {
            id: aurOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.aurPackages = root.parseUpdates(aurOutput.text)
            root.aurExitCode = exitCode
            root.aurCheckDone = true
            root.finishRefresh()
        }
    }

    Process {
        id: updateProc

        command: [
            "kitty", "-e", "bash", "-lc",
            "paru -Syu; echo; read -rp 'Press Enter to close...'"
        ]

        onExited: {
            root.updating = false
            refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 30000
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    UpdatePopup {
        id: popup

        targetScreen: root.targetScreen
        packages: root.packages
        checking: root.checking
        updating: root.updating
        checkError: root.checkError

        onRefreshRequested: root.refresh()
        onUpdateRequested: root.startUpdate()
    }

    Item {
        anchors.fill: parent

        TokyoIcon {
            anchors.centerIn: parent

            text: "󰏖"
            font.pixelSize: 17

            color: root.checkError.length > 0
                ? Colours.red
                : root.packages.length > 0
                    ? Colours.blue
                    : iconHover.hovered
                        ? Colours.blue
                        : Colours.text

            Behavior on color {
                ColorAnimation {
                    duration: Animations.fast
                }
            }
        }

        Rectangle {
            visible: root.packages.length > 0

            anchors {
                top: parent.top
                right: parent.right
                topMargin: -1
                rightMargin: -3
            }

            width: root.packages.length > 99
                ? 23
                : root.packages.length > 9
                    ? 19
                    : 14
            height: 13
            radius: 7

            color: Colours.red

            TokyoText {
                anchors.centerIn: parent

                text: root.packages.length > 99
                    ? "99+"
                    : String(root.packages.length)

                font.pixelSize: 8
                font.weight: Font.DemiBold
                color: Colours.base
            }
        }

        HoverHandler {
            id: iconHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: popup.toggle()
        }
    }

    Component.onCompleted: root.refresh()
}
