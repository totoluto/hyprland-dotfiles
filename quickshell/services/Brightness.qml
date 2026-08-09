import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string device: ""
    property real value: 0
    property bool available: false

    function clamp(value) {
        return Math.max(0, Math.min(1, value));
    }

    function refresh() {
        if (root.device.length === 0) {
            return ;
        }

        queryProcess.exec(["brightnessctl", "-d", root.device, "-P", "get"]);
    }

    function setBrightness(value) {
        if (!root.available) {
            return ;
        }

        const clamped = root.clamp(value);
        root.value = clamped;
        Quickshell.execDetached(["brightnessctl", "-d", root.device, "set", Math.round(clamped * 100) + "%"]);
    }

    Process {
        id: discoverProcess

        running: true
        command: ["sh", "-c", "ls -1 /sys/class/backlight 2>/dev/null | head -n1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim();
                if (result.length === 0) {
                    root.available = false;
                    console.warn("Brightness: no backlight device found");
                    return ;
                }
                root.device = result;
                console.log("Brightness device:", root.device);
                root.refresh();
            }
        }

    }

    Process {
        id: queryProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim();
                const percentage = parseFloat(result);
                if (isNaN(percentage)) {
                    root.available = false;
                    console.warn("Brightness: invalid brightnessctl output:", result);
                    return ;
                }
                root.value = root.clamp(percentage / 100);
                root.available = true;
            }
        }

    }

    Timer {
        interval: 750
        repeat: true
        running: root.device.length > 0
        onTriggered: root.refresh()
    }

}
