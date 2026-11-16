import Quickshell
import Quickshell.Io
import QtQuick

// CPU + memory straight from /proc — no shell processes spawned.
Scope {
    id: root
    property int interval: 2000

    property real cpu: 0          // percent
    property real memUsedKb: 0
    property real memTotalKb: 0
    readonly property real memPercent: memTotalKb > 0 ? 100 * memUsedKb / memTotalKb : 0
    readonly property string memUsedGb: (memUsedKb / 1048576).toFixed(1) + "G"

    property real _lastTotal: 0
    property real _lastIdle: 0

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            // cpu  user nice system idle iowait irq softirq steal
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1, 9).map(Number);
            const idle = f[3] + f[4];
            const total = f.reduce((a, b) => a + b, 0);
            if (root._lastTotal > 0) {
                const dt = total - root._lastTotal;
                const di = idle - root._lastIdle;
                root.cpu = dt > 0 ? Math.max(0, Math.min(100, 100 * (1 - di / dt))) : 0;
            }
            root._lastTotal = total;
            root._lastIdle = idle;
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const total = t.match(/MemTotal:\s+(\d+)/);
            const avail = t.match(/MemAvailable:\s+(\d+)/);
            if (total && avail) {
                root.memTotalKb = Number(total[1]);
                root.memUsedKb = root.memTotalKb - Number(avail[1]);
            }
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { stat.reload(); meminfo.reload(); }
    }
}
