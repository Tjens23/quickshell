import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Workspaces living on this bar's monitor.
// Click a pill = go to that workspace, scroll over the island = cycle.
Island {
    id: root

    // The ShellScreen this bar is drawn on (set from shell.qml)
    property var screen: null

    readonly property HyprlandMonitor monitor: screen ? Hyprland.monitorFor(screen) : null
    readonly property bool monitorFocused: monitor !== null && Hyprland.focusedMonitor === monitor
    readonly property int activeId: monitor?.activeWorkspace?.id ?? -1

    // Normal workspaces on this monitor, sorted (special:* ones have negative ids)
    readonly property var workspaces: Hyprland.workspaces.values
        .filter(ws => ws.id > 0 && ws.monitor?.name === monitor?.name)
        .sort((a, b) => a.id - b.id)

    // Uses the Lua dispatcher syntax, same as `hyprctl dispatch 'hl.dsp.exit()'`
    // in hyprland.lua. On a hyprlang (.conf) setup this would be "workspace " + id.
    function goTo(id) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
    }

    function cycle(step) {
        const ids = workspaces.map(ws => ws.id);
        if (ids.length < 2) return;
        const i = Math.max(0, ids.indexOf(activeId));
        goTo(ids[(i + step + ids.length) % ids.length]);
    }

    visible: monitor !== null && workspaces.length > 0
    padding: 4
    spacing: 4

    Repeater {
        model: root.workspaces

        delegate: Rectangle {
            id: pill
            required property var modelData
            readonly property bool active: modelData.id === root.activeId
            readonly property bool urgent: modelData.urgent ?? false

            Layout.alignment: Qt.AlignVCenter
            implicitHeight: 20
            implicitWidth: active ? 34 : 22
            radius: 6

            // Bright pill on the focused monitor, muted pill on the other one
            color: active ? (root.monitorFocused ? Theme.accent : Theme.divider)
                 : area.containsMouse ? Theme.surfaceHover
                 : "transparent"

            Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: pill.modelData.name || pill.modelData.id
                color: pill.active ? (root.monitorFocused ? Theme.surface : Theme.text)
                     : pill.urgent ? Theme.crit
                     : area.containsMouse ? Theme.text
                     : Theme.textDim
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.weight: pill.active ? Font.Bold : Font.Medium
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.goTo(pill.modelData.id)
            }
        }
    }

    // Scroll to cycle; accumulates so touchpads don't fly through every workspace
    WheelHandler {
        property real acc: 0
        onWheel: event => {
            acc += event.angleDelta.y;
            if (Math.abs(acc) >= 120) {
                root.cycle(acc > 0 ? -1 : 1);
                acc = 0;
            }
        }
    }
}
