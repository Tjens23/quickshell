pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property real barOpacity: 0
    readonly property color bar:          Qt.rgba(0.12, 0.12, 0.12, barOpacity)
    readonly property color border:       Qt.rgba(1, 1, 1, 0.06)
    readonly property color surface:      "#2c2c2c"
    readonly property color surfaceHover: "#363636"
    readonly property color divider:      "#3d3d3d"
    readonly property color text:         "#e6e6e6"
    readonly property color textDim:      "#8a8a8a"
    readonly property color accent:       "#ffffff"
    readonly property color warn:         "#e5c07b"
    readonly property color crit:         "#e06c75"
    readonly property color spotify:      "#1db954"

    readonly property string font: "FiraCode Nerd Font"
    readonly property int fontSize: 12
    readonly property int iconSize: 14
    readonly property int barHeight: 38
    readonly property int islandHeight: 28
    readonly property int radius: 12

    readonly property string iLogo:    String.fromCodePoint(0xf303)
    readonly property string iCpu:     String.fromCodePoint(0xf2db)
    readonly property string iMem:     String.fromCodePoint(0xf035b)
    readonly property string iEth:     String.fromCodePoint(0xf0200)
    readonly property string iWifi:    String.fromCodePoint(0xf05a9)
    readonly property string iOffline: String.fromCodePoint(0xf0318)
    readonly property string iSpotify: String.fromCodePoint(0xf1bc)
    readonly property string iMusic:   String.fromCodePoint(0xf001)
}
