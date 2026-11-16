import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    property bool isOpen: false

    // IPC listener matching your hyprland.lua trigger: `qs ipc call keymaps toggle`
    IpcHandler {
        target: "keymaps"
        function toggle() {
            isOpen = !isOpen
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: window
            required property var modelData
            screen: modelData

            visible: isOpen
            color: "transparent"
            flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Background dim overlay
            Rectangle {
                anchors.fill: parent
                color: "#cc141414"

                MouseArea {
                    anchors.fill: parent
                    onClicked: isOpen = false
                }
            }

            // Center Card
            Rectangle {
                anchors.centerIn: parent
                width: 600
                height: 400
                color: "#1f1f1f"
                border.color: "#3d3d3d"
                border.width: 1
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Text {
                        text: "Keybindings"
                        color: "#e6e6e6"
                        font.family: "FiraCode Nerd Font"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        text: "SUPER + Q : Open Terminal\nSUPER + E : Open File Manager\nSUPER + SPACE : Launcher\nSUPER + L : Lock Session\nSUPER + K : Toggle Keymaps\nSUPER + C : Close Window"
                        color: "#8a8a8a"
                        font.family: "FiraCode Nerd Font"
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
