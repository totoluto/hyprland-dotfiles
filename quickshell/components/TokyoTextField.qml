import QtQuick
import qs.theme

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property bool enabled: true

    signal editingFinished(string text)

    implicitHeight: 38
    radius: 11
    opacity: root.enabled ? 1 : 0.5
    color: input.activeFocus ? Colours.surface0 : (hover.hovered ? Colours.surface0 : Colours.surface1)
    border.width: 1
    border.color: input.activeFocus ? Colours.blue : Colours.surface0

    HoverHandler {
        id: hover

        enabled: root.enabled
        cursorShape: root.enabled ? Qt.IBeamCursor : Qt.ArrowCursor
    }

    TapHandler {
        enabled: root.enabled
        onTapped: input.forceActiveFocus()
    }

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        enabled: root.enabled
        clip: true
        color: Colours.text
        selectionColor: Colours.blue
        selectedTextColor: Colours.base
        font.family: Typography.textFamily
        font.pixelSize: 13
        font.weight: Typography.normalWeight
        verticalAlignment: TextInput.AlignVCenter
        onAccepted: root.editingFinished(text)
        onActiveFocusChanged: {
            if (!activeFocus) {
                root.editingFinished(text);
            }
        }
    }

    Text {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        visible: input.text.length === 0 && !input.activeFocus && root.placeholderText.length > 0
        text: root.placeholderText
        color: Colours.muted
        font.family: Typography.textFamily
        font.pixelSize: 13
        font.weight: Typography.normalWeight
        verticalAlignment: Text.AlignVCenter
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: Animations.fast
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
        }

    }

}
