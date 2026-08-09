import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    readonly property string query: searchInput.text.trim().toLowerCase()
    
    readonly property var filteredApplications: {
        const query = root.query;
        const usageSnapshot = AppUsage.usage;
        const source = DesktopEntries.applications.values;
        const apps = [];
        for (let i = 0; i < source.length; ++i) apps.push(source[i])
        if (query.length === 0) {
            apps.sort((a, b) => {
                return AppUsage.compareUsage(a, b);
            });
            return apps;
        }

        const filtered = [];
        for (let i = 0; i < apps.length; ++i) {
            if (root.searchableText(apps[i]).includes(query)) {
                filtered.push(apps[i]);
            }

        }
        filtered.sort((a, b) => {
            const searchDifference = root.score(a, query) - root.score(b, query);
            if (searchDifference !== 0) {
                return searchDifference;
            }

            const usageDifference = AppUsage.compareUsage(a, b);
            if (usageDifference !== 0) {
                return usageDifference;
            }

            return a.name.localeCompare(b.name);
        });
        return filtered;
    }

    signal requestClose()

    function focusSearch() {
        searchInput.forceActiveFocus();
    }

    function reset() {
        searchInput.text = "";
        if (appList.count > 0) {
            appList.currentIndex = 0;
        } else {
            appList.currentIndex = -1;
        }

        searchInput.forceActiveFocus();
    }

    function searchableText(entry) {
        let result = (entry.name || "") + " " + (entry.genericName || "") + " " + (entry.comment || "");

        if (entry.keywords) {
            for (let i = 0; i < entry.keywords.length; ++i) {
                result += " " + entry.keywords[i];
            }
        }

        return result.toLowerCase();
    }

    function score(entry, query) {
        const name = (entry.name || "").toLowerCase();
        if (name === query) {
            return 0;
        }

        if (name.startsWith(query)) {
            return 10;
        }

        const index = name.indexOf(query);
        if (index >= 0) {
            return 20 + index;
        }

        return 100;
    }

    function launch(entry) {
        if (!entry) {
            return ;
        }

        AppUsage.recordLaunch(entry);
        root.requestClose();
        entry.execute();
    }

    ScriptModel {
        id: applicationModel

        values: root.filteredApplications
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Metrics.hubSearchHeight
            radius: Metrics.hubSearchRadius
            color: Colours.surface1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                TokyoIcon {
                    text: ""
                    font.pixelSize: 18
                    color: Colours.blue
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TokyoText {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: searchInput.text.length === 0
                        text: "Search applications..."
                        font.pixelSize: 15
                        color: Colours.muted
                    }

                    TextInput {
                        id: searchInput

                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colours.text
                        selectionColor: Colours.blue
                        selectedTextColor: Colours.surface0
                        font.family: Typography.textFamily
                        font.pixelSize: 15
                        clip: true
                        onTextChanged: {
                            if (appList.count > 0) {
                                appList.currentIndex = 0;
                            }
                        }
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Down) {
                                appList.incrementCurrentIndex();
                                event.accepted = true;
                                return ;
                            }

                            if (event.key === Qt.Key_Up) {
                                appList.decrementCurrentIndex();
                                event.accepted = true;
                                return ;
                            }

                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (appList.currentItem)
                                    root.launch(appList.currentItem.entry);

                                event.accepted = true;
                                return ;
                            }

                            if (event.key === Qt.Key_Escape) {
                                root.requestClose();
                                event.accepted = true;
                            }
                        }
                    }
                }

            }
        }

        ListView {
            id: appList

            Layout.fillWidth: true
            Layout.fillHeight: true
            model: applicationModel
            spacing: Metrics.hubResultSpacing
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            currentIndex: count > 0 ? 0 : -1

            TokyoText {
                anchors.centerIn: parent
                visible: appList.count === 0
                text: "No applications found"
                color: Colours.muted
            }

            delegate: AppResult {
                required property int index
                required property var modelData

                width: appList.width
                entry: modelData
                selected: appList.currentIndex === index
                onHovered: appList.currentIndex = index
                onActivated: root.launch(entry)
            }
        }
    }
}
