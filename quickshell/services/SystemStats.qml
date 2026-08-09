import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    // CPU
    // Memory
    // System
    // GPU
    // CPU parser
    // Memory parser
    // /proc readers
    // Lightweight system refresh.
    // CPU temperature
    // GPU query
    // Slower hardware polling.
    // Initial /proc reads.

    id: root

    property bool enabled: false
    property real cpuUsage: 0
    property real cpuTemperature: -1
    property real previousCpuTotal: 0
    property real previousCpuIdle: 0
    property real memoryTotalKiB: 0
    property real memoryAvailableKiB: 0
    readonly property real memoryUsedKiB: Math.max(0, root.memoryTotalKiB - root.memoryAvailableKiB)
    readonly property real memoryUsage: root.memoryTotalKiB > 0 ? root.memoryUsedKiB / root.memoryTotalKiB : 0
    readonly property real memoryUsedGiB: root.memoryUsedKiB / 1024 / 1024
    readonly property real memoryTotalGiB: root.memoryTotalKiB / 1024 / 1024
    property real uptimeSeconds: 0
    property real load1: 0
    property real load5: 0
    property real load15: 0
    property bool gpuAvailable: false
    property string gpuBackend: ""
    property string gpuName: ""
    property real gpuUsage: 0
    property real gpuTemperature: -1
    property real gpuMemoryUsedMiB: -1
    property real gpuMemoryTotalMiB: -1
    readonly property string uptimeText: {
        const seconds = Math.floor(root.uptimeSeconds);
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (days > 0)
            return days + "d " + hours + "h";

        if (hours > 0)
            return hours + "h " + minutes + "m";

        return minutes + "m";
    }

    function parseCpu(text) {
        if (!text || text.length === 0)
            return ;

        const line = text.split("\n")[0];
        const fields = line.trim().split(/\s+/);
        if (fields.length < 9 || fields[0] !== "cpu")
            return ;

        const user = Number(fields[1]);
        const nice = Number(fields[2]);
        const system = Number(fields[3]);
        const idle = Number(fields[4]);
        const iowait = Number(fields[5]);
        const irq = Number(fields[6]);
        const softirq = Number(fields[7]);
        const steal = Number(fields[8]);
        const idleTotal = idle + iowait;
        const total = user + nice + system + idle + iowait + irq + softirq + steal;
        if (root.previousCpuTotal > 0) {
            const totalDelta = total - root.previousCpuTotal;
            const idleDelta = idleTotal - root.previousCpuIdle;
            if (totalDelta > 0)
                root.cpuUsage = Math.max(0, Math.min(1, 1 - idleDelta / totalDelta));

        }
        root.previousCpuTotal = total;
        root.previousCpuIdle = idleTotal;
    }

    function parseMemory(text) {
        if (!text || text.length === 0)
            return ;

        let total = 0;
        let available = 0;
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i];
            if (line.startsWith("MemTotal:"))
                total = Number(line.replace("MemTotal:", "").replace("kB", "").trim());
            else if (line.startsWith("MemAvailable:"))
                available = Number(line.replace("MemAvailable:", "").replace("kB", "").trim());
        }
        root.memoryTotalKiB = total;
        root.memoryAvailableKiB = available;
    }

    function parseUptime(text) {
        if (!text)
            return ;

        const first = text.trim().split(/\s+/)[0];
        const value = Number(first);
        if (!isNaN(value))
            root.uptimeSeconds = value;

    }

    function parseLoad(text) {
        if (!text)
            return ;

        const fields = text.trim().split(/\s+/);
        if (fields.length < 3)
            return ;

        root.load1 = Number(fields[0]);
        root.load5 = Number(fields[1]);
        root.load15 = Number(fields[2]);
    }

    onEnabledChanged: {
        if (!root.enabled)
            return ;

        cpuFile.reload();
        memoryFile.reload();
        uptimeFile.reload();
        loadFile.reload();
    }
    
    Component.onCompleted: {
        cpuFile.reload();
        memoryFile.reload();
        uptimeFile.reload();
        loadFile.reload();
    }

    FileView {
        id: cpuFile

        path: "/proc/stat"
        printErrors: false
        onTextChanged: root.parseCpu(text())
    }

    FileView {
        id: memoryFile

        path: "/proc/meminfo"
        printErrors: false
        onTextChanged: root.parseMemory(text())
    }

    FileView {
        id: uptimeFile

        path: "/proc/uptime"
        printErrors: false
        onTextChanged: root.parseUptime(text())
    }

    FileView {
        id: loadFile

        path: "/proc/loadavg"
        printErrors: false
        onTextChanged: root.parseLoad(text())
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.enabled
        onTriggered: {
            cpuFile.reload();
            memoryFile.reload();
            uptimeFile.reload();
            loadFile.reload();
        }
    }

    Process {
        id: cpuTemperatureProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim();
                const value = Number(result);
                if (!isNaN(value))
                    root.cpuTemperature = value;
                else
                    root.cpuTemperature = -1;
            }
        }

    }

    Process {
        id: gpuProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim();
                if (result.length === 0 || result === "none") {
                    root.gpuAvailable = false;
                    root.gpuBackend = "";
                    root.gpuName = "";
                    root.gpuUsage = 0;
                    root.gpuTemperature = -1;
                    return ;
                }
                const fields = result.split("|");
                if (fields.length < 4) {
                    root.gpuAvailable = false;
                    return ;
                }
                root.gpuBackend = fields[0];
                root.gpuName = fields[1];
                root.gpuUsage = Math.max(0, Math.min(1, Number(fields[2]) / 100));
                root.gpuTemperature = Number(fields[3]);
                if (fields.length >= 6 && fields[4].length > 0 && fields[5].length > 0) {
                    root.gpuMemoryUsedMiB = Number(fields[4]);
                    root.gpuMemoryTotalMiB = Number(fields[5]);
                } else {
                    root.gpuMemoryUsedMiB = -1;
                    root.gpuMemoryTotalMiB = -1;
                }
                root.gpuAvailable = true;
            }
        }

    }

    Timer {
        interval: 2000
        repeat: true
        running: root.enabled
        triggeredOnStart: true
        onTriggered: {
            /*
             * CPU temperature.
             *
             * Prefer common CPU hwmon labels.
             * Fall back to the hottest thermal zone.
             */
            cpuTemperatureProcess.exec(["sh", "-c", `
                value=""

                for label in /sys/class/hwmon/hwmon*/temp*_label; do
                    [ -r "$label" ] || continue

                    name="$(cat "$label" 2>/dev/null)"

                    case "$name" in
                        *Package*|*Tctl*|*Tdie*|*CPU*)
                            input="\${label%_label}_input"

                            if [ -r "$input" ]; then
                                value="$(cat "$input")"
                                break
                            fi
                            ;;
                    esac
                done

                if [ -z "$value" ]; then
                    value="$(
                        cat /sys/class/thermal/thermal_zone*/temp \
                            2>/dev/null \
                        | sort -nr \
                        | head -n1
                    )"
                fi

                if [ -n "$value" ]; then
                    awk "BEGIN { printf \\"%.0f\\", $value / 1000 }"
                fi
                `]);
            /*
             * GPU backend detection.
             *
             * NVIDIA:
             *     nvidia-smi
             *
             * AMD / Intel:
             *     DRM sysfs gpu_busy_percent where exposed.
             */
            gpuProcess.exec(["sh", "-c", `
                if command -v nvidia-smi >/dev/null 2>&1; then
                    nvidia-smi \
                        --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total \
                        --format=csv,noheader,nounits \
                    | head -n1 \
                    | awk -F ', ' '{
                        printf "nvidia|%s|%s|%s|%s|%s",
                            $1, $2, $3, $4, $5
                    }'

                    exit 0
                fi

                busy=""

                for file in /sys/class/drm/card*/device/gpu_busy_percent; do
                    [ -r "$file" ] || continue
                    busy="$file"
                    break
                done

                if [ -n "$busy" ]; then
                    device="\${busy%/gpu_busy_percent}"

                    vendor="$(
                        cat "$device/vendor" \
                            2>/dev/null
                    )"

                    case "$vendor" in
                        0x1002)
                            backend="amd"
                            name="AMD GPU"
                            ;;
                        0x8086)
                            backend="intel"
                            name="Intel GPU"
                            ;;
                        *)
                            backend="drm"
                            name="GPU"
                            ;;
                    esac

                    usage="$(
                        cat "$busy" \
                            2>/dev/null
                    )"

                    temp=""

                    for t in "$device"/hwmon/hwmon*/temp1_input; do
                        [ -r "$t" ] || continue

                        raw="$(cat "$t")"

                        temp="$(
                            awk "BEGIN {
                                printf \\"%.0f\\",
                                    $raw / 1000
                            }"
                        )"

                        break
                    done

                    printf "%s|%s|%s|%s" \
                        "$backend" \
                        "$name" \
                        "\${usage:-0}" \
                        "\${temp:--1}"

                    exit 0
                fi

                printf "none"
                `]);
        }
    }

}
