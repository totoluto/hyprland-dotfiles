import QtQuick
import QtQuick.Layouts
import qs.services
import qs.theme

Item {
    id: root

    property bool active: false

    function temperatureText(value) {
        if (value < 0) {
            return "";
        }

        return Math.round(value) + "°C";
    }

    function gpuDetails() {
        if (!SystemStats.gpuAvailable) {
            return "No supported GPU telemetry";
        }

        let parts = [];
        if (SystemStats.gpuName.length > 0) {
            parts.push(SystemStats.gpuName);
        }

        if (SystemStats.gpuTemperature >= 0) {
            parts.push(root.temperatureText(SystemStats.gpuTemperature));
        }

        if (SystemStats.gpuMemoryUsedMiB >= 0 && SystemStats.gpuMemoryTotalMiB > 0) {
            parts.push((SystemStats.gpuMemoryUsedMiB / 1024).toFixed(1) + " / " + (SystemStats.gpuMemoryTotalMiB / 1024).toFixed(1) + " GiB VRAM");
        }

        return parts.join(" · ");
    }

    Binding {
        target: SystemStats
        property: "enabled"
        value: root.active
    }

    GridLayout {
        anchors.fill: parent
        columns: 2
        rows: 2
        columnSpacing: 14
        rowSpacing: 14

        StatCard {
            title: "CPU"
            icon: "󰍛"
            valueText: Math.round(SystemStats.cpuUsage * 100) + "%"
            detailText: SystemStats.cpuTemperature >= 0 ? root.temperatureText(SystemStats.cpuTemperature) : "Temperature unavailable"
            percentage: SystemStats.cpuUsage
            accent: Colours.blue
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatCard {
            title: "GPU"
            icon: "󰢮"
            valueText: SystemStats.gpuAvailable ? Math.round(SystemStats.gpuUsage * 100) + "%" : "—"
            detailText: root.gpuDetails()
            percentage: SystemStats.gpuAvailable ? SystemStats.gpuUsage : -1
            accent: Colours.purple
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatCard {
            title: "MEMORY"
            icon: "󰘚"
            valueText: Math.round(SystemStats.memoryUsage * 100) + "%"
            detailText: SystemStats.memoryUsedGiB.toFixed(1) + " / " + SystemStats.memoryTotalGiB.toFixed(1) + " GiB"
            percentage: SystemStats.memoryUsage
            accent: Colours.cyan
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatCard {
            title: "SYSTEM"
            icon: "󰔟"
            valueText: SystemStats.uptimeText
            detailText: "Load " + SystemStats.load1.toFixed(2) + " / " + SystemStats.load5.toFixed(2) + " / " + SystemStats.load15.toFixed(2)
            percentage: -1
            accent: Colours.green
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }

}
