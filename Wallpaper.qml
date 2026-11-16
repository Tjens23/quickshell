import Quickshell
import Quickshell.Wayland
import QtQuick

// Draws the wallpaper on the background layer — no hyprpaper/swww needed.
Scope {
    id: root
    property string source: Quickshell.env("HOME") + "/.config/hypr/wallpapers/graphite.png"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "quickshell-wallpaper"
            mask: Region {}            // let clicks fall through to the desktop
            color: "#141414"

            Image {
                anchors.fill: parent
                source: "file://" + root.source
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                cache: false
                sourceSize: Qt.size(parent.width * (modelData.devicePixelRatio ?? 1),
                                    parent.height * (modelData.devicePixelRatio ?? 1))
            }
        }
    }
}
