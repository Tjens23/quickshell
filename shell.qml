import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    component Divider: Rectangle {
        implicitWidth: 1
        implicitHeight: 12
        color: Theme.divider
    }

    Launcher { id: launcher }

    // --- data ---
    SysStats { id: stats }
    SystemClock { id: clock; precision: SystemClock.Minutes }

    Poller {
        id: net
        command: "nmcli -t -f TYPE,NAME connection show --active | grep -E '^(802-3-ethernet|802-11-wireless):' | head -n1"
        interval: 10000
    }
    readonly property string netType: net.value.split(":")[0]
    readonly property string netName: net.value.split(":").slice(1).join(":")
    readonly property bool isWifi: netType === "802-11-wireless"

    function loadColor(p) {
        return p > 90 ? Theme.crit : p > 70 ? Theme.warn : Theme.text;
    }

    // --- one bar per monitor ---
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.bar

                // hairline along the bottom edge instead of a full border
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1
                    color: Theme.border
                }

                // LEFT: logo + workspaces + now playing
                RowLayout {
                    anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                    spacing: 6

                    Island {
                        padding: 10
                        interactive: true
                        onClicked: launcher.toggle()
                        BarPill { icon: Theme.iLogo; iconColor: Theme.accent; label: "CyberCube" }
                    }

                    Workspaces { screen: panel.modelData }

                    Media {}
                }

                // CENTER: date + time (anchored, so it stays centered no matter the song length)
                Island {
                    anchors.centerIn: parent
                    BarPill { label: Qt.formatDateTime(clock.date, "ddd d MMM"); labelColor: Theme.textDim }
                    BarPill { label: Qt.formatDateTime(clock.date, "HH:mm"); labelColor: Theme.accent }
                }

                // RIGHT: system stats
                Island {
                    anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }

                    BarPill {
                        icon: Theme.iCpu
                        label: Math.round(stats.cpu) + "%"
                        reserve: "100%"
                        labelColor: root.loadColor(stats.cpu)
                    }

                    Divider {}

                    BarPill {
                        icon: ""
                        label: stats.memUsedGb
                        reserve: "00.0G"
                        labelColor: root.loadColor(stats.memPercent)
                    }

                    Divider {}

                    BarPill {
                        icon: root.isWifi ? Theme.iWifi : root.netType !== "" ? "󰈁" : Theme.iOffline
                        iconColor: root.netType !== "" ? Theme.text : Theme.crit
                        label: root.isWifi ? root.netName : root.netType !== "" ? "" : "Offline"
                    }
                }
            }
        }
    }
}
