import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components
import qs.theme

RowLayout {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property int percentage: battery.ready ? Math.round(battery.percentage) : 0
    readonly property bool charging: battery.ready && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)

    function batteryIcon() : string {
        if (root.charging) {
            return "";
        }

        if (root.percentage <= 20) {
            return "";
        }

        if (root.percentage <= 40) {
            return "";
        }

        if (root.percentage <= 60) {
            return "";
        }

        if (root.percentage <= 80) {
            return "";
        }

        return "";
    }

    visible: battery.ready && battery.isLaptopBattery
    spacing: 5

    TokyoText {
        text: root.percentage + "%"
        color: root.percentage <= 15 ? Colours.red : Colours.text
    }

    TokyoIcon {
        text: root.batteryIcon()
        color: root.percentage <= 15 ? Colours.red : Colours.text
    }

}
