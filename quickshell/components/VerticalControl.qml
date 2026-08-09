import QtQuick
import QtQuick.Layouts
import qs.theme

Item {
    id: root

    required property real value
    required property string icon
    property string label: Math.round(root.value * 100) + "%"
    property bool controlEnabled: true
    readonly property bool pressed: dragArea.pressed

    signal valueEdited(real value)

    function clamp(value) {
        return Math.max(0, Math.min(1, value));
    }

    implicitWidth: Metrics.osdControlWidth
    implicitHeight: Metrics.osdCardHeight - Metrics.osdVerticalPadding * 2

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        TokyoIcon {
            text: root.icon
            font.pixelSize: Metrics.osdIconSize
            opacity: root.controlEnabled ? 1 : 0.35
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            id: sliderArea

            Layout.preferredWidth: Metrics.osdBarTouchWidth
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                width: Metrics.osdBarWidth
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                radius: width / 2
                color: Colours.surface1
            }

            Rectangle {
                width: Metrics.osdBarWidth
                height: parent.height * root.clamp(root.value)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                radius: width / 2

                gradient: Gradient {
                    orientation: Gradient.Vertical

                    GradientStop {
                        position: 0
                        color: Colours.purple
                    }

                    GradientStop {
                        position: 1
                        color: Colours.blue
                    }

                }

                Behavior on height {
                    enabled: !dragArea.pressed

                    NumberAnimation {
                        duration: Animations.fast
                        easing.type: Easing.OutCubic
                    }

                }

            }

            MouseArea {
                id: dragArea

                function updateValue(mouseY) {
                    const value = 1 - mouseY / height;
                    root.valueEdited(root.clamp(value));
                }

                anchors.fill: parent
                enabled: root.controlEnabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                onPressed: (mouse) => {
                    updateValue(mouse.y);
                }
                onPositionChanged: (mouse) => {
                    if (pressed)
                        updateValue(mouse.y);

                }
                onWheel: (wheel) => {
                    const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.valueEdited(root.clamp(root.value + step));
                    wheel.accepted = true;
                }
            }

        }

        TokyoText {
            text: root.label
            font.pixelSize: 14
            opacity: root.controlEnabled ? 1 : 0.35
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
