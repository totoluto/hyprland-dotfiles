import QtQuick
import Quickshell.Io

Item {
    id: root

    required property string manifestPath
    readonly property string directory: root.manifestPath.substring(0, root.manifestPath.lastIndexOf("/"))
    readonly property string widgetPath: root.directory + "/Widget.qml"
    readonly property string settingsPath: root.directory + "/Settings.qml"

    // Manifest metadata
    readonly property string pluginId: manifest.id
    readonly property string name: manifest.name
    readonly property string description: manifest.description
    readonly property string icon: manifest.icon
    readonly property int version: manifest.version
    readonly property int defaultColumns: Math.max(1, Math.min(2, manifest.defaultColumns))
    readonly property int defaultRows: Math.max(1, Math.min(2, manifest.defaultRows))
    readonly property bool hasSettings: manifest.hasSettings
    
    /*
     * A valid plugin must at minimum have:
     *
     * id
     * name
     */
    readonly property bool valid: root.pluginId.length > 0 && root.name.length > 0

    /*
     * This component is only a metadata object.
     * It has no visual representation.
     */
    width: 0
    height: 0
    visible: false

    /*
     * Read plugin.json.
     *
     * FileView's default adapter property accepts
     * JsonAdapter directly.
     */
    FileView {
        id: manifestFile

        path: root.manifestPath
        blockLoading: true
        watchChanges: true
        printErrors: true
        onFileChanged: reload()

        JsonAdapter {
            id: manifest

            property string id: ""
            property string name: ""
            property string description: ""
            property string icon: ""
            property int version: 1
            property int defaultColumns: 1
            property int defaultRows: 1
            property bool hasSettings: false
        }

    }

}
