import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property bool active: false
    property bool editMode: false

    /*
     * Paths discovered on disk:
     *
     * plugins/example/plugin.json
     * plugins/homelab/plugin.json
     * ...
     */
    property var manifestSources: []

    /*
     * Internal manifest registry.
     */
    property var manifestRegistry: ({})
    property var processedManifestPaths: ({})

    /*
     * Fully parsed plugin metadata.
     */
    property var plugins: []

    /*
     * Settings page state.
     */
    property string settingsPluginId: ""
    property string settingsPluginName: ""
    property string settingsSource: ""
    readonly property bool showingSettings: root.settingsPluginId.length > 0
    readonly property string pluginDirectory: Quickshell.shellDir + "/modules/activity/dashboard/plugins"

    /*
     * Re-evaluate ordering whenever DashboardState
     * changes.
     */
    readonly property var orderedPlugins: {
        const stateSnapshot = DashboardState.layout;
        const result = root.plugins.slice();
        result.sort(function(a, b) {
            return (DashboardState.orderOf(a.id) - DashboardState.orderOf(b.id));
        });
        return result;
    }

    /*
     * Normal:
     *   only enabled widgets.
     *
     * Edit:
     *   all installed widgets, including hidden ones.
     */
    readonly property var displayedPlugins: {
        const stateSnapshot = DashboardState.layout;
        if (root.editMode)
            return root.orderedPlugins;

        const result = [];
        for (let i = 0; i < root.orderedPlugins.length; ++i) {
            const plugin = root.orderedPlugins[i];
            if (DashboardState.isEnabled(plugin.id)) {
                result.push(plugin);
            }

        }
        return result;
    }

    /*
     * Find manifests, not Widget.qml files.
     *
     * plugin.json is now what makes a directory
     * a dashboard plugin.
     */
    function discoverPlugins() {
        discovery.exec(["find", root.pluginDirectory, "-mindepth", "2", "-maxdepth", "2", "-type", "f", "-name", "plugin.json", "-print"]);
    }

    /*
     * Called by each DashboardPluginManifest once
     * its plugin.json has been parsed.
     */
    function registerManifest(path, manifest) {
        const registry = Object.assign({}, root.manifestRegistry);
        const processed = Object.assign({}, root.processedManifestPaths);
        processed[path] = true;
        if (manifest.valid) {
            registry[path] = {
                "id": manifest.pluginId,
                "name": manifest.name,
                "description": manifest.description,
                "icon": manifest.icon,
                "version": manifest.version,
                "defaultColumns": manifest.defaultColumns,
                "defaultRows": manifest.defaultRows,
                "hasSettings": manifest.hasSettings,
                "widgetPath": manifest.widgetPath,
                "settingsPath": manifest.settingsPath,
                "manifestPath": path
            };
        } else {
            delete registry[path];
        }
        
        root.manifestRegistry = registry;
        root.processedManifestPaths = processed;

        /*
         * Don't synchronize DashboardState until
         * every discovered manifest has been parsed.
         *
         * Otherwise processing plugin A before
         * plugin B could temporarily remove B's
         * persisted state.
         */
        if (Object.keys(processed).length >= root.manifestSources.length) {
            root.finalizeManifests();
        }
    }

    function finalizeManifests() {
        const paths = Object.keys(root.manifestRegistry);
        paths.sort();
        const result = [];
        const ids = [];
        const seenIds = ({});
        for (let i = 0; i < paths.length; ++i) {
            const plugin = root.manifestRegistry[paths[i]];
            if (!plugin || !plugin.id || plugin.id.length === 0) {
                continue;
            }

            /*
             * Plugin IDs must be globally unique.
             */
            if (seenIds[plugin.id]) {
                console.warn("Duplicate dashboard plugin id:", plugin.id, "in", plugin.manifestPath);
                continue;
            }

            seenIds[plugin.id] = true;
            result.push(plugin);
            ids.push(plugin.id);
        }

        /*
         * Synchronize installed plugins with
         * persisted dashboard state.
         */
        DashboardState.ensurePlugins(ids);

        /*
         * plugin.json owns the default dimensions.
         */
        for (let i = 0; i < result.length; ++i) {
            DashboardState.ensureDefaults(result[i].id, result[i].defaultColumns, result[i].defaultRows);
        }

        root.plugins = result;
    }

    function openSettings(plugin) {
        if (!plugin.hasSettings) {
            return;
        }

        root.settingsPluginId = plugin.id;
        root.settingsPluginName = plugin.name;
        root.settingsSource = "file://" + plugin.settingsPath;
    }

    function closeSettings() {
        root.settingsPluginId = "";
        root.settingsPluginName = "";
        root.settingsSource = "";
    }

    function finishEditing() {
        root.editMode = false;
        root.closeSettings();
    }

    Component.onCompleted: root.discoverPlugins()

    /*
     * Don't keep plugins polling while the
     * Dashboard isn't visible.
     */
    onActiveChanged: {
        if (!root.active) {
            root.editMode = false;
            root.closeSettings();
        }
    }

    /*
     * Manifest discovery.
     */
    Process {
        id: discovery

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map((value) => {
                    return value.trim();
                }).filter((value) => {
                    return value.length > 0;
                });

                lines.sort();

                /*
                * Reset the registry before the
                * new manifest delegates appear.
                */
                root.manifestRegistry = ({});
                root.processedManifestPaths = ({});

                root.plugins = [];
                root.manifestSources = lines;
                if (lines.length === 0) {
                    DashboardState.ensurePlugins([]);
                }

            }
        }

    }

    /*
     * Invisible manifest loaders.
     *
     * These parse plugin.json and create the
     * metadata objects used by the actual grid.
     */
    Item {
        id: manifestHost

        visible: false
        width: 0
        height: 0

        Repeater {
            Item {
                id: manifestSlot

                required property var modelData

                function syncManifest() {
                    root.registerManifest(manifestSlot.modelData, pluginManifest);
                }

                width: 0
                height: 0
                Component.onCompleted: manifestSlot.syncManifest()

                DashboardPluginManifest {
                    id: pluginManifest

                    manifestPath: manifestSlot.modelData
                    onPluginIdChanged: manifestSlot.syncManifest()
                    onNameChanged: manifestSlot.syncManifest()
                    onDescriptionChanged: manifestSlot.syncManifest()
                    onIconChanged: manifestSlot.syncManifest()
                    onVersionChanged: manifestSlot.syncManifest()
                    onDefaultColumnsChanged: manifestSlot.syncManifest()
                    onDefaultRowsChanged: manifestSlot.syncManifest()
                    onHasSettingsChanged: manifestSlot.syncManifest()
                }

            }

            model: ScriptModel {
                values: root.manifestSources
            }

        }

    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        /*
         * HEADER
         */
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            /*
             * Back button while Settings.qml
             * is being displayed.
             */
            DashboardEditButton {
                visible: root.showingSettings
                text: "‹"
                onClicked: root.closeSettings()
            }

            TokyoText {
                text: {
                    if (root.showingSettings)
                        return root.settingsPluginName;

                    if (root.editMode)
                        return "Edit dashboard";

                    return "Dashboard";
                }
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Item {
                Layout.fillWidth: true
            }

            TokyoText {
                visible: !root.editMode && !root.showingSettings
                text: root.displayedPlugins.length + (root.displayedPlugins.length === 1 ? " widget" : " widgets")
                font.pixelSize: 11
                color: Colours.muted
            }

            DashboardEditButton {
                visible: root.editMode && !root.showingSettings
                text: "Reset"
                onClicked: DashboardState.reset()
            }

            DashboardEditButton {
                visible: !root.showingSettings
                text: root.editMode ? "Done" : "Edit"
                accent: root.editMode
                onClicked: {
                    if (root.editMode)
                        root.finishEditing();
                    else
                        root.editMode = true;
                }
            }

        }

        /*
         * MAIN VIEWPORT
         */
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            /*
             * DASHBOARD PAGE
             */
            Flickable {
                id: dashboardFlickable

                anchors.fill: parent
                visible: !root.showingSettings
                clip: true
                contentWidth: width
                contentHeight: dashboardGrid.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                GridLayout {
                    id: dashboardGrid

                    width: dashboardFlickable.width
                    columns: 2
                    columnSpacing: Metrics.dashboardSpacing
                    rowSpacing: Metrics.dashboardSpacing

                    Repeater {
                        Item {
                            id: widgetSlot

                            required property var modelData
                            /*
                             * Explicit dependency on
                             * DashboardState.
                             */
                            readonly property var stateSnapshot: DashboardState.layout
                            readonly property bool widgetEnabled: DashboardState.isEnabled(widgetSlot.modelData.id)
                            readonly property int widgetColumns: DashboardState.columns(widgetSlot.modelData.id)
                            readonly property int widgetRows: DashboardState.rows(widgetSlot.modelData.id)

                            Layout.fillWidth: true
                            Layout.columnSpan: Math.max(1, Math.min(2, widgetSlot.widgetColumns))
                            Layout.preferredHeight: Metrics.dashboardRowHeight * widgetSlot.widgetRows + (Metrics.dashboardSpacing * (widgetSlot.widgetRows - 1))

                            /*
                             * PLUGIN WIDGET
                             */
                            Loader {
                                id: widgetLoader

                                anchors.fill: parent
                                source: "file://" + widgetSlot.modelData.widgetPath

                                /*
                                 * Normal:
                                 * only enabled widgets.
                                 *
                                 * Edit:
                                 * load hidden widgets too,
                                 * so they can be managed.
                                 */
                                active: root.active && (root.editMode || widgetSlot.widgetEnabled)
                                asynchronous: true
                                opacity: widgetSlot.widgetEnabled ? 1 : 0.32

                                /*
                                 * plugin.json is authoritative.
                                 *
                                 * Widget.qml contains no
                                 * hardcoded plugin identity.
                                 */
                                onLoaded: {
                                    if (!item) {
                                        return ;
                                    }

                                    item.pluginId = widgetSlot.modelData.id;
                                    item.title = widgetSlot.modelData.name;
                                    item.icon = widgetSlot.modelData.icon;
                                    item.preferredColumns = widgetSlot.modelData.defaultColumns;
                                    item.preferredRows = widgetSlot.modelData.defaultRows;
                                }

                                onStatusChanged: {
                                    if (status === Loader.Error) {
                                        console.warn("Dashboard widget failed:", widgetSlot.modelData.widgetPath);
                                    }

                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Animations.fast
                                    }

                                }

                            }

                            /*
                             * Plugin lifecycle.
                             *
                             * Editing intentionally disables
                             * plugin activity so widgets such
                             * as Homelab don't poll while being
                             * rearranged.
                             */
                            Binding {
                                target: widgetLoader.item
                                property: "active"
                                value: root.active && !root.editMode && widgetSlot.widgetEnabled
                                when: widgetLoader.item !== null
                            }

                            /*
                             * EDIT OVERLAY
                             */
                            Rectangle {
                                anchors.fill: parent
                                visible: root.editMode
                                radius: 16
                                color: "transparent"
                                border.width: 1
                                border.color: widgetSlot.widgetEnabled ? Colours.blue : Colours.muted
                                z: 50

                                /*
                                 * Prevent the actual widget from
                                 * receiving input while editing.
                                 */
                                MouseArea {
                                    anchors.fill: parent
                                    z: 0
                                }

                                /*
                                 * Hidden marker.
                                 */
                                Rectangle {
                                    visible: !widgetSlot.widgetEnabled
                                    anchors.centerIn: parent
                                    implicitWidth: hiddenLabel.implicitWidth + 18
                                    implicitHeight: 28
                                    radius: 9
                                    color: Colours.surface0
                                    z: 2

                                    TokyoText {
                                        id: hiddenLabel

                                        anchors.centerIn: parent
                                        text: "Hidden"
                                        font.pixelSize: 11
                                        color: Colours.muted
                                    }

                                }

                                /*
                                 * EDIT CONTROLS
                                 */
                                Row {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 8
                                    spacing: 5
                                    z: 3

                                    /*
                                     * Plugin Settings.qml
                                     */
                                    DashboardEditButton {
                                        visible: widgetSlot.modelData.hasSettings
                                        text: "󰒓"
                                        onClicked: root.openSettings(widgetSlot.modelData)
                                    }

                                    /*
                                     * Move up/backward.
                                     */
                                    DashboardEditButton {
                                        text: "↑"
                                        enabled: DashboardState.orderOf(widgetSlot.modelData.id) > 0
                                        onClicked: DashboardState.move(widgetSlot.modelData.id, -1)
                                    }

                                    /*
                                     * Move down/forward.
                                     */
                                    DashboardEditButton {
                                        text: "↓"
                                        enabled: DashboardState.orderOf(widgetSlot.modelData.id) < root.orderedPlugins.length - 1
                                        onClicked: DashboardState.move(widgetSlot.modelData.id, 1)
                                    }

                                    /*
                                     * 1×1 -> 2×1 -> 2×2.
                                     */
                                    DashboardEditButton {
                                        text: DashboardState.sizeLabel(widgetSlot.modelData.id)
                                        onClicked: DashboardState.cycleSize(widgetSlot.modelData.id)
                                    }

                                    /*
                                     * Hide/show.
                                     */
                                    DashboardEditButton {
                                        text: widgetSlot.widgetEnabled ? "Hide" : "Show"
                                        accent: !widgetSlot.widgetEnabled
                                        onClicked: DashboardState.toggleEnabled(widgetSlot.modelData.id)
                                    }

                                }

                                /*
                                 * Manifest information.
                                 */
                                Column {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 10
                                    spacing: 2
                                    z: 3

                                    TokyoText {
                                        text: widgetSlot.modelData.name
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                    }

                                    TokyoText {
                                        visible: widgetSlot.modelData.description.length > 0
                                        text: widgetSlot.modelData.description
                                        font.pixelSize: 9
                                        color: Colours.muted
                                    }

                                }

                            }

                        }

                        model: ScriptModel {
                            values: root.displayedPlugins
                        }

                    }

                }

                /*
                 * EMPTY DASHBOARD
                 */
                Column {
                    anchors.centerIn: parent
                    visible: root.displayedPlugins.length === 0
                    spacing: 8

                    TokyoIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰕮"
                        font.pixelSize: 34
                        color: Colours.muted
                    }

                    TokyoText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            if (root.plugins.length === 0) {
                                return "No dashboard plugins";
                            }
                            

                            return "No dashboard widgets";
                        }
                        font.pixelSize: 13
                        color: Colours.muted
                    }

                    TokyoText {
                        visible: root.plugins.length === 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Add a plugin.json to the plugins folder"
                        font.pixelSize: 10
                        color: Colours.muted
                    }

                    TokyoText {
                        visible: !root.editMode && root.plugins.length > 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Open Edit to enable widgets"
                        font.pixelSize: 10
                        color: Colours.muted
                    }

                }

            }

            /*
             * SETTINGS PAGE
             */
            Loader {
                id: settingsLoader

                anchors.fill: parent
                visible: root.showingSettings
                active: root.showingSettings
                source: root.settingsSource
                asynchronous: false

                /*
                 * Settings.qml also gets its
                 * identity exclusively from
                 * plugin.json.
                 *
                 * Every Settings.qml therefore
                 * exposes:
                 *
                 * property string pluginId: ""
                 */
                onLoaded: {
                    if (!item) {
                        return ;
                    }

                    item.pluginId = root.settingsPluginId;
                }
                onStatusChanged: {
                    if (status === Loader.Error) {
                        console.warn("Dashboard settings failed:", root.settingsSource);
                    }
                }
            }

        }

    }

}
