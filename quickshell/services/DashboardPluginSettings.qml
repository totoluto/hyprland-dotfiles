import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    /*
     * Stored as:
     *
     * {
     *     "example": {
     *         "showStatus": true,
     *         "message": "Hello"
     *     },
     *
     *     "homelab": {
     *         "refreshInterval": 10
     *     }
     * }
     */
    readonly property var settings: settingsAdapter.plugins

    function pluginSettings(pluginId) {
        if (!pluginId) {
            return ({});
        }

        return (settingsAdapter.plugins[pluginId] || {});
    }

    function value(pluginId, key, fallback) {
        const plugin = root.pluginSettings(pluginId);
        if (Object.prototype.hasOwnProperty.call(plugin, key)) {
            return plugin[key];
        }

        return fallback;
    }

    function setValue(pluginId, key, value) {
        if (!pluginId || !key) {
            return ;
        }

        /*
         * Clone everything instead of modifying a
         * nested JSON object directly.
         *
         * This guarantees JsonAdapter notices the
         * property change.
         */
        const plugins = Object.assign({
        }, settingsAdapter.plugins);

        const plugin = Object.assign({
        }, plugins[pluginId] || {
        });

        plugin[key] = value;
        plugins[pluginId] = plugin;
        settingsAdapter.plugins = plugins;
    }

    function reset(pluginId) {
        if (!pluginId) {
            return ;
        }

        const plugins = Object.assign({
        }, settingsAdapter.plugins);

        delete plugins[pluginId];
        settingsAdapter.plugins = plugins;
    }

    FileView {
        id: settingsFile

        path: Quickshell.stateDir + "/dashboard-plugin-settings.json"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: settingsAdapter
            property var plugins: ({})
        }
    }
}
