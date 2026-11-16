import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Now playing + cava. Click = play/pause, scroll = next/previous.
Island {
    id: root

    // Prefer whatever is playing, then Spotify, then any player.
    readonly property var player: {
        const ps = Mpris.players.values;
        let spotify = null;
        for (let i = 0; i < ps.length; i++) {
            if (ps[i].isPlaying) return ps[i];
            if (!spotify && (ps[i].identity ?? "").toLowerCase().includes("spotify")) spotify = ps[i];
        }
        return spotify ?? (ps.length ? ps[0] : null);
    }

    readonly property bool playing: player?.isPlaying ?? false
    readonly property bool isSpotify: (player?.identity ?? "").toLowerCase().includes("spotify")
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""

    visible: player !== null && title !== ""
    interactive: true
    spacing: 9

    onClicked: if (player?.canTogglePlaying) player.togglePlaying()
    onScrolled: delta => {
        if (!player) return;
        if (delta > 0 && player.canGoPrevious) player.previous();
        else if (delta < 0 && player.canGoNext) player.next();
    }

    Cava {
        active: root.playing && root.visible
        barColor: root.playing ? Theme.text : Theme.textDim
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: root.isSpotify ? Theme.iSpotify : Theme.iMusic
        color: root.isSpotify && root.playing ? Theme.spotify : Theme.textDim
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: root.title
        color: root.playing ? Theme.text : Theme.textDim
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        font.weight: Font.Medium
        elide: Text.ElideRight
        Layout.maximumWidth: 220
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        visible: root.artist !== ""
        text: root.artist
        color: Theme.textDim
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
        Layout.maximumWidth: 140
        Layout.alignment: Qt.AlignVCenter
    }
}
