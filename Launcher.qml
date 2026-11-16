import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

// App + system command launcher.
// Open with:  qs ipc call launcher toggle   (or click the logo in the bar)
Scope {
    id: root
    property bool open: false
    property string query: ""
    property string armed: ""      // name of a dangerous command waiting for a second Enter
    readonly property int rowHeight: 46
    readonly property int maxRows: 8

    function toggle() { open = !open }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle() }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }

    // --- system commands ---
    readonly property var commands: [
        { kind: "cmd", name: "Shutdown",  sub: "Power off the computer",            glyph: 0xf011, cmd: "systemctl poweroff", confirm: true,  keywords: ["poweroff", "power off", "turn off", "shut down"] },
        { kind: "cmd", name: "Reboot",    sub: "Restart the computer",              glyph: 0xf021, cmd: "systemctl reboot",   confirm: true,  keywords: ["restart"] },
        { kind: "cmd", name: "Suspend",   sub: "Sleep, keep the session in memory", glyph: 0xf186, cmd: "systemctl suspend",  confirm: false, keywords: ["sleep"] },
        { kind: "cmd", name: "Hibernate", sub: "Save the session to disk and power off", glyph: 0xf2dc, cmd: "systemctl hibernate", confirm: true, keywords: [] },
        { kind: "cmd", name: "Lock",      sub: "Lock the screen",                   glyph: 0xf023, cmd: "loginctl lock-session", confirm: false, keywords: ["lock screen"] },
        { kind: "cmd", name: "Log out",   sub: "End this session",                  glyph: 0xf08b, cmd: "loginctl terminate-user $USER", confirm: true, keywords: ["logout", "sign out", "exit"] },
        { kind: "cmd", name: "Reboot to firmware", sub: "Restart into UEFI / BIOS setup", glyph: 0xf013, cmd: "systemctl reboot --firmware-setup", confirm: true, keywords: ["bios", "uefi"] }
    ]

    // --- installed apps (.desktop files) ---
    readonly property var apps: {
        const list = DesktopEntries.applications.values;
        const out = [];
        for (let i = 0; i < list.length; i++) {
            const e = list[i];
            if (e.noDisplay) continue;
            const kw = [];
            const ek = e.keywords ?? [];
            for (let j = 0; j < ek.length; j++) kw.push(String(ek[j]).toLowerCase());
            out.push({ kind: "app", name: e.name, sub: e.genericName || e.comment || "", icon: e.icon, keywords: kw, entry: e });
        }
        out.sort((a, b) => a.name.localeCompare(b.name));
        return out;
    }

    function score(q, item) {
        const n = item.name.toLowerCase();
        if (n === q) return 100;
        if (n.startsWith(q)) return 80;
        if (n.split(/\s+/).some(w => w.startsWith(q))) return 60;
        if (n.includes(q)) return 40;
        if (item.keywords.some(k => k.startsWith(q) || k.includes(q))) return 30;
        if (item.sub.toLowerCase().includes(q)) return 10;
        return 0;
    }

    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "") return apps;   // commands only show up when you type
        const scored = [];
        for (const c of commands) { const s = score(q, c); if (s > 0) scored.push({ item: c, s: s + 5 }); }
        for (const a of apps)     { const s = score(q, a); if (s > 0) scored.push({ item: a, s: s }); }
        scored.sort((x, y) => y.s - x.s || x.item.name.localeCompare(y.item.name));
        return scored.map(x => x.item);
    }

    onQueryChanged: armed = ""
    onResultsChanged: list.currentIndex = 0

    Process { id: runner }

    function activate(item) {
        if (!item) return;
        if (item.kind === "cmd") {
            if (item.confirm && armed !== item.name) { armed = item.name; return; }
            runner.command = ["sh", "-c", item.cmd];
            runner.startDetached();
        } else {
            item.entry.execute();
        }
        open = false;
    }

    PanelWindow {
        id: win
        visible: root.open
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-launcher"

        onVisibleChanged: if (visible) {
            input.text = "";
            root.armed = "";
            list.currentIndex = 0;
            input.forceActiveFocus();
        }

        // dim the screen; click anywhere outside to close
        Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.35) }
        MouseArea { anchors.fill: parent; onClicked: root.open = false }

        Rectangle {
            id: box
            width: Math.min(600, parent.width - 40)
            height: content.implicitHeight + 16
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.22        // fixed top edge, so it doesn't jump while you type
            radius: Theme.radius + 2
            color: Qt.rgba(0.12, 0.12, 0.12, 0.95)
            border.color: Theme.border
            border.width: 1

            MouseArea { anchors.fill: parent }   // swallow clicks so they don't close the launcher

            ColumnLayout {
                id: content
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                spacing: 6

                // search field
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 12

                    Text {
                        text: String.fromCodePoint(0xf002)
                        color: Theme.textDim
                        font.family: Theme.font
                        font.pixelSize: 15
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextInput {
                            id: input
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.text
                            selectionColor: Theme.surfaceHover
                            font.family: Theme.font
                            font.pixelSize: 15
                            focus: true
                            clip: true
                            onTextChanged: root.query = text

                            Keys.onEscapePressed: root.open = false
                            Keys.onUpPressed: list.decrementCurrentIndex()
                            Keys.onDownPressed: list.incrementCurrentIndex()
                            Keys.onTabPressed: list.incrementCurrentIndex()
                            Keys.onReturnPressed: root.activate(root.results[list.currentIndex])
                            Keys.onEnterPressed: root.activate(root.results[list.currentIndex])
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: "Search apps, or type shutdown, reboot, lock…"
                            color: Theme.textDim
                            font.family: Theme.font
                            font.pixelSize: 15
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.border
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(count, root.maxRows) * root.rowHeight
                    visible: count > 0
                    model: root.results
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 0

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool current: ListView.isCurrentItem
                        readonly property bool isArmed: root.armed !== "" && root.armed === modelData.name

                        width: ListView.view.width
                        height: root.rowHeight
                        radius: 8
                        color: current ? Theme.surface : "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: list.currentIndex = row.index
                            onClicked: root.activate(row.modelData)
                        }

                        RowLayout {
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            spacing: 12

                            Item {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28

                                IconImage {
                                    // Fixed size (never 0) so the SVG is rendered at 28px
                                    // instead of its native size -> no "buffer too big" spam.
                                    anchors.centerIn: parent
                                    implicitSize: 28
                                    width: 28
                                    height: 28
                                    visible: row.modelData.kind === "app"
                                    asynchronous: true
                                    source: row.modelData.kind === "app"
                                        ? Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                                        : ""
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: row.modelData.kind === "cmd"
                                    text: row.modelData.kind === "cmd" ? String.fromCodePoint(row.modelData.glyph) : ""
                                    color: row.isArmed ? Theme.crit : Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 17
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.name
                                    color: row.isArmed ? Theme.crit : Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: row.isArmed ? "Press Enter again to " + row.modelData.name.toLowerCase() : row.modelData.sub
                                    color: row.isArmed ? Theme.crit : Theme.textDim
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                visible: row.modelData.kind === "cmd"
                                text: "System"
                                color: Theme.textDim
                                font.family: Theme.font
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                Text {
                    visible: root.results.length === 0
                    Layout.margins: 12
                    text: "Nothing matches \u201c" + root.query.trim() + "\u201d"
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: 13
                }
            }
        }
    }
}
