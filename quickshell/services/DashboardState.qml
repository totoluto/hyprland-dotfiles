import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property var layout: stateAdapter.widgets

    function normalizedEntry(entry) {
        return {
            "id": entry.id || "",
            "enabled": entry.enabled !== false,
            "columns": entry.columns || 0,
            "rows": entry.rows || 0,
            "defaultColumns": entry.defaultColumns || 0,
            "defaultRows": entry.defaultRows || 0
        };
    }

    function indexOf(id) {
        const widgets = stateAdapter.widgets || [];
        for (let i = 0; i < widgets.length; ++i) {
            if (widgets[i].id === id)
                return i;

        }
        return -1;
    }

    function entry(id) {
        const index = root.indexOf(id);
        if (index < 0)
            return null;

        return stateAdapter.widgets[index];
    }

    function orderOf(id) {
        const index = root.indexOf(id);
        return index < 0 ? 999999 : index;
    }

    function isEnabled(id) {
        const data = root.entry(id);
        return !data || data.enabled !== false;
    }

    function columns(id) {
        const data = root.entry(id);
        if (!data || !data.columns)
            return 1;

        return Math.max(1, Math.min(2, data.columns));
    }

    function rows(id) {
        const data = root.entry(id);
        if (!data || !data.rows)
            return 1;

        return Math.max(1, Math.min(2, data.rows));
    }

    function sizeLabel(id) {
        return (root.columns(id) + "×" + root.rows(id));
    }

    function ensurePlugins(ids) {
        const previous = stateAdapter.widgets || [];
        const next = [];
        for (let i = 0; i < previous.length; ++i) {
            const item = previous[i];
            if (ids.indexOf(item.id) >= 0)
                next.push(root.normalizedEntry(item));

        }
        for (let i = 0; i < ids.length; ++i) {
            const id = ids[i];
            let exists = false;
            for (let j = 0; j < next.length; ++j) {
                if (next[j].id === id) {
                    exists = true;
                    break;
                }
            }
            if (!exists)
                // Filled from DashboardWidget
                // after its first load.

                next.push({
                    "id": id,
                    "enabled": true,
                    "columns": 0,
                    "rows": 0,
                    "defaultColumns": 0,
                    "defaultRows": 0
                });

        }
        if (JSON.stringify(next) !== JSON.stringify(previous))
            stateAdapter.widgets = next;

    }

    function ensureDefaults(id, preferredColumns, preferredRows) {
        const index = root.indexOf(id);
        if (index < 0)
            return ;

        const next = (stateAdapter.widgets || []).map((item) => {
            return root.normalizedEntry(item);
        });
        const data = next[index];
        const defaultColumns = Math.max(1, Math.min(2, preferredColumns || 1));
        const defaultRows = Math.max(1, Math.min(2, preferredRows || 1));
        let changed = false;
        if (!data.defaultColumns || data.defaultColumns !== defaultColumns) {
            data.defaultColumns = defaultColumns;
            changed = true;
        }
        if (!data.defaultRows || data.defaultRows !== defaultRows) {
            data.defaultRows = defaultRows;
            changed = true;
        }
        if (!data.columns) {
            data.columns = defaultColumns;
            changed = true;
        }
        if (!data.rows) {
            data.rows = defaultRows;
            changed = true;
        }
        if (changed)
            stateAdapter.widgets = next;

    }

    function setEnabled(id, enabled) {
        const index = root.indexOf(id);
        if (index < 0)
            return ;

        const next = (stateAdapter.widgets || []).map((item) => {
            return root.normalizedEntry(item);
        });
        next[index].enabled = enabled;
        stateAdapter.widgets = next;
    }

    function toggleEnabled(id) {
        root.setEnabled(id, !root.isEnabled(id));
    }

    function move(id, delta) {
        const index = root.indexOf(id);
        if (index < 0)
            return ;

        const target = index + delta;
        const current = stateAdapter.widgets || [];
        if (target < 0 || target >= current.length)
            return ;

        const next = current.map((item) => {
            return root.normalizedEntry(item);
        });
        const temp = next[index];
        next[index] = next[target];
        next[target] = temp;
        stateAdapter.widgets = next;
    }

    function cycleSize(id) {
        const index = root.indexOf(id);
        if (index < 0)
            return ;

        const next = (stateAdapter.widgets || []).map((item) => {
            return root.normalizedEntry(item);
        });
        const data = next[index];
        const columns = data.columns || 1;
        const rows = data.rows || 1;
        if (columns === 1 && rows === 1) {
            data.columns = 2;
            data.rows = 1;
        } else if (columns === 2 && rows === 1) {
            data.columns = 2;
            data.rows = 2;
        } else {
            data.columns = 1;
            data.rows = 1;
        }
        stateAdapter.widgets = next;
    }

    function reset() {
        const current = stateAdapter.widgets || [];
        const next = [];
        for (let i = 0; i < current.length; ++i) {
            const data = root.normalizedEntry(current[i]);
            next.push({
                "id": data.id,
                "enabled": true,
                "columns": data.defaultColumns || 1,
                "rows": data.defaultRows || 1,
                "defaultColumns": data.defaultColumns || 1,
                "defaultRows": data.defaultRows || 1
            });
        }
        stateAdapter.widgets = next;
    }

    FileView {
        id: stateFile

        path: Quickshell.statePath("dashboard-layout.json")
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: stateAdapter

            property var widgets: []
        }

    }

}
