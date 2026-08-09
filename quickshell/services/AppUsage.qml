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
     *   "firefox.desktop": {
     *     "count": 42,
     *     "lastUsed": 1786287300000
     *   }
     * }
     */
    readonly property var usage: usageAdapter.apps

    function recordLaunch(entry) {
        if (!entry || !entry.id)
            return ;

        /*
         * Don't mutate the existing JSON object directly.
         * Create a new object so QML sees the property change
         * and JsonAdapter writes it out.
         */
        const next = Object.assign({
        }, usageAdapter.apps);

        const previous = next[entry.id] || {
            "count": 0,
            "lastUsed": 0
        };

        next[entry.id] = {
            "count": (previous.count || 0) + 1,
            "lastUsed": Date.now()
        };

        usageAdapter.apps = next;
    }

    function launchCount(entry) {
        if (!entry || !entry.id) {
            return 0;
        }

        const data = usageAdapter.apps[entry.id];
        return data ? data.count || 0 : 0;
    }

    function lastUsed(entry) {
        if (!entry || !entry.id) {
            return 0;
        }

        const data = usageAdapter.apps[entry.id];
        return data ? data.lastUsed || 0 : 0;
    }

    /*
     * Frecency:
     *
     * launch count remains the dominant factor,
     * but recently-used apps get a temporary bonus.
     */
    function usageScore(entry) {
        const count = root.launchCount(entry);
        const last = root.lastUsed(entry);
        if (count === 0) {
            return 0;
        }

        if (last === 0) {
            return count;
        }

        const ageHours = Math.max(0, (Date.now() - last) / 3.6e+06);

        /*
         * Up to +5 points immediately after launch.
         * Bonus decays over roughly one week.
         */
        const recencyBonus = 5 * Math.exp(-ageHours / 168);
        return count + recencyBonus;
    }

    function compareUsage(a, b) {
        const scoreDifference = root.usageScore(b) - root.usageScore(a);
        if (Math.abs(scoreDifference) > 0.001) {
            return scoreDifference;
        }

        const recentDifference = root.lastUsed(b) - root.lastUsed(a);
        if (recentDifference !== 0) {
            return recentDifference;
        }

        return a.name.localeCompare(b.name);
    }

    FileView {
        id: usageFile

        path: Quickshell.stateDir + "/app-usage.json"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: usageAdapter

            property var apps: ({})
        }
    }
}
