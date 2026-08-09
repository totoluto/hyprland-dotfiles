import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
pragma Singleton

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var sinkAudio: sink ? sink.audio : null
    readonly property bool available: root.sink !== null && root.sinkAudio !== null
    readonly property real volume: root.available ? root.sinkAudio.volume : 0
    readonly property bool muted: root.available ? root.sinkAudio.muted : false
    readonly property int percent: Math.round(root.volume * 100)
    readonly property string icon: {
        if (root.muted || root.percent === 0) {
            return "󰝟";
        }

        if (root.percent < 34) {
            return "󰕿";
        }

        if (root.percent < 67) {
            return "󰖀";
        }

        return "󰕾";
    }

    function setVolume(value) {
        if (!root.available) {
            return ;
        }

        const clamped = Math.max(0, Math.min(1, value));
        root.sinkAudio.volume = clamped;
        
        if (root.sinkAudio.muted && clamped > 0) {
            root.sinkAudio.muted = false;
        }
    }

    PwObjectTracker {
        objects: [root.sink]
    }

}
