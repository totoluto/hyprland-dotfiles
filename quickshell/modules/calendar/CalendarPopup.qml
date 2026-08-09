import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.theme

Scope {
    id: root

    property var targetScreen: null
    property bool windowVisible: false
    property bool popupVisible: false
    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()
    readonly property date today: clock.date
    readonly property int dayCellWidth: 38
    readonly property int dayCellHeight: 34
    readonly property int weekCellWidth: 28
    readonly property int calendarSpacing: 4
    readonly property var weeks: root.buildWeeks(root.viewYear, root.viewMonth)

    function isoWeek(date) {
        const target = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        const day = target.getUTCDay() || 7;
        target.setUTCDate(target.getUTCDate() + 4 - day);
        const yearStart = new Date(Date.UTC(target.getUTCFullYear(), 0, 1));
        return Math.ceil(((target - yearStart) / 8.64e+07 + 1) / 7);
    }

    function isToday(date) {
        return (date.getFullYear() === root.today.getFullYear() && date.getMonth() === root.today.getMonth() && date.getDate() === root.today.getDate());
    }

    function buildWeeks(year, month) {
        const first = new Date(year, month, 1);
        /*
         * Convert JS Sunday-first indexing to
         * Monday-first.
         */
        const offset = (first.getDay() + 6) % 7;
        const start = new Date(year, month, 1 - offset);
        const result = [];
        for (let row = 0; row < 6; ++row) {
            const monday = new Date(start);
            monday.setDate(start.getDate() + row * 7);
            const days = [];
            for (let column = 0; column < 7; ++column) {
                const date = new Date(monday);
                date.setDate(monday.getDate() + column);
                days.push({
                    "year": date.getFullYear(),
                    "month": date.getMonth(),
                    "day": date.getDate(),
                    "inMonth": date.getFullYear() === year && date.getMonth() === month,
                    "today": root.isToday(date)
                });
            }
            result.push({
                "week": root.isoWeek(monday),
                "days": days
            });
        }
        return result;
    }

    function resetToToday() {
        root.viewYear = root.today.getFullYear();
        root.viewMonth = root.today.getMonth();
    }

    function applyMonthDelta(delta) {
        const target = new Date(root.viewYear, root.viewMonth + delta, 1);
        root.viewYear = target.getFullYear();
        root.viewMonth = target.getMonth();
    }

    function changeMonth(delta) {
        root.applyMonthDelta(delta);
        monthPage.x = delta > 0 ? 20 : -20;
        monthPage.opacity = 0;
        monthEnter.restart();
    }

    function show() {
        closeTimer.stop();
        root.resetToToday();
        root.windowVisible = true;
        Qt.callLater(function() {
            root.popupVisible = true;
        });
    }

    function hide() {
        root.popupVisible = false;
        closeTimer.restart();
    }

    function toggle() {
        if (root.windowVisible && root.popupVisible)
            root.hide();
        else
            root.show();
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Timer {
        id: closeTimer

        interval: Animations.normal
        repeat: false
        onTriggered: root.windowVisible = false
    }

    ParallelAnimation {
        id: monthEnter

        NumberAnimation {
            target: monthPage
            property: "x"
            to: 0
            duration: Animations.normal
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: monthPage
            property: "opacity"
            to: 1
            duration: Animations.fast
        }

    }

    PanelWindow {
        id: calendarWindow

        screen: root.targetScreen
        visible: root.windowVisible && root.targetScreen !== null
        implicitWidth: Metrics.calendarPopupWidth
        implicitHeight: Metrics.calendarPopupHeight
        color: "transparent"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        anchors {
            top: true
            right: true
        }

        margins {
            /*
             * Same height as notification popup.
             */
            top: Metrics.notificationToastTopOffset
            right: Metrics.calendarPopupSideMargin
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
                x: root.popupVisible ? 0 : width + 16
                opacity: root.popupVisible ? 1 : 0
                radius: Metrics.calendarPopupRadius
                color: Colours.base
                border.width: 1
                border.color: Colours.surface0

                /*
                 * HEADER
                 */
                RowLayout {
                    id: header

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 14
                    height: 46
                    spacing: 6

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        TokyoText {
                            text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                        }

                        TokyoText {
                            text: Qt.formatDate(root.today, "dddd, d MMMM") + " · Week " + root.isoWeek(root.today)
                            font.pixelSize: 9
                            color: Colours.muted
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                        }

                    }

                    CalendarButton {
                        text: "Today"
                        onClicked: {
                            root.resetToToday();
                            monthPage.x = 0;
                            monthPage.opacity = 1;
                        }
                    }

                    CalendarButton {
                        text: "‹"
                        onClicked: root.changeMonth(-1)
                    }

                    CalendarButton {
                        text: "›"
                        onClicked: root.changeMonth(1)
                    }

                }

                Rectangle {
                    id: separator

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: header.bottom
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 6
                    height: 1
                    color: Colours.surface0
                }

                /*
                 * CALENDAR
                 *
                 * No Layout.fillHeight here.
                 * Every calendar cell has explicit
                 * geometry.
                 */
                Item {
                    id: calendarArea

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: separator.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 12
                    anchors.bottomMargin: 14
                    clip: true

                    Item {
                        id: monthPage

                        width: calendarGrid.width
                        height: calendarGrid.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter

                        Column {
                            id: calendarGrid

                            spacing: root.calendarSpacing

                            /*
                             * WEEKDAY HEADER
                             */
                            Row {
                                spacing: root.calendarSpacing

                                Item {
                                    width: root.weekCellWidth
                                    height: 24

                                    TokyoText {
                                        anchors.centerIn: parent
                                        text: "W"
                                        font.pixelSize: 9
                                        font.weight: Font.Medium
                                        color: Colours.purple
                                    }

                                }

                                Repeater {
                                    model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                                    Item {
                                        required property var modelData

                                        width: root.dayCellWidth
                                        height: 24

                                        TokyoText {
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: 9
                                            font.weight: Font.Medium
                                            color: Colours.muted
                                        }

                                    }

                                }

                            }

                            /*
                             * SIX FIXED WEEK ROWS
                             */
                            Repeater {
                                model: root.weeks

                                Row {
                                    id: weekRow

                                    required property var modelData
                                    readonly property var weekData: modelData

                                    spacing: root.calendarSpacing

                                    /*
                                     * WEEK NUMBER
                                     */
                                    Item {
                                        width: root.weekCellWidth
                                        height: root.dayCellHeight

                                        TokyoText {
                                            anchors.centerIn: parent
                                            text: weekRow.weekData.week
                                            font.pixelSize: 9
                                            font.weight: Font.Medium
                                            color: Colours.purple
                                            opacity: 0.72
                                        }

                                    }

                                    /*
                                     * DAYS
                                     */
                                    Repeater {
                                        model: weekRow.weekData.days

                                        Item {
                                            id: daySlot

                                            required property var modelData

                                            width: root.dayCellWidth
                                            height: root.dayCellHeight

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 30
                                                height: 30
                                                radius: 10
                                                color: daySlot.modelData.today ? Colours.blue : "transparent"

                                                TokyoText {
                                                    anchors.centerIn: parent
                                                    text: daySlot.modelData.day
                                                    font.pixelSize: 11
                                                    font.weight: daySlot.modelData.today ? Font.DemiBold : Font.Normal
                                                    color: {
                                                        if (daySlot.modelData.today)
                                                            return Colours.base;

                                                        if (daySlot.modelData.inMonth)
                                                            return Colours.text;

                                                        return Colours.muted;
                                                    }
                                                    opacity: daySlot.modelData.inMonth || daySlot.modelData.today ? 1 : 0.42
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

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

            }

        }

    }

}
