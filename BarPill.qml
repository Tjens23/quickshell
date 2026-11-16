import QtQuick
import QtQuick.Layouts

// Icon + label. No background of its own — put it inside an Island.
RowLayout {
    id: root
    property string icon: ""
    property string label: ""
    property color iconColor: Theme.textDim
    property color labelColor: Theme.text
    property string reserve: ""   // reserves width so changing numbers don't jitter, e.g. "100%"
    spacing: 7

    Text {
        visible: root.icon !== ""
        text: root.icon
        color: root.iconColor
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        visible: root.label !== ""
        text: root.label
        color: root.labelColor
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignRight
        Layout.minimumWidth: reserveMetrics.width
        Layout.alignment: Qt.AlignVCenter

        TextMetrics {
            id: reserveMetrics
            text: root.reserve
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
        }
    }
}
