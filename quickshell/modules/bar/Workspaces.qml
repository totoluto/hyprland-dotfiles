import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.theme

RowLayout {
    id: root

    required property var screen

    spacing: Metrics.workspaceSpacing

    readonly property int activeWorkspaceId:
        Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

    Repeater {
        model: 5

        Workspace {
            required property int index

            workspaceId: index + 1
            active: workspaceId === root.activeWorkspaceId
        }
    }
}