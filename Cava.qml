import Quickshell
import Quickshell.Io
import QtQuick

// Tiny cava visualizer. Runs cava in raw ascii mode and draws the bars.
Item {
    id: root
    property int bars: 10
    property bool active: true
    property color barColor: Theme.text
    property int barWidth: 3
    property int gap: 2
    property var values: []

    implicitWidth: bars * barWidth + (bars - 1) * gap
    implicitHeight: 16

    onActiveChanged: if (!active) values = []

    Process {
        running: root.active
        command: ["sh", "-c",
            `printf '[general]\\nbars=${root.bars}\\nframerate=30\\n` +
            `[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\n` +
            `ascii_max_range=100\\nbar_delimiter=59\\n' > /tmp/qs-cava.conf ` +
            `&& exec cava -p /tmp/qs-cava.conf`]
        stdout: SplitParser {
            onRead: data => {
                const v = data.split(";").filter(s => s !== "").map(Number);
                if (v.length) root.values = v;
            }
        }
    }

    Row {
        anchors.fill: parent
        spacing: root.gap

        Repeater {
            model: root.bars
            Rectangle {
                required property int index
                width: root.barWidth
                height: Math.max(2, root.height * (root.values[index] ?? 0) / 100)
                y: (parent.height - height) / 2   // mirrored around the center line
                radius: width / 2
                color: root.barColor
                Behavior on height { NumberAnimation { duration: 50 } }
            }
        }
    }
}
