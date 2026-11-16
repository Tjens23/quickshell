import QtQuick
import QtQuick.Layouts

// A rounded group of widgets sitting on the bar.
Rectangle {
    id: root
    default property alias content: row.data
    property int padding: 12
    property int spacing: 10
    property bool interactive: false

    signal clicked(var mouse)
    signal scrolled(int delta)

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Theme.islandHeight
    radius: Theme.radius - 4
    color: interactive && area.containsMouse ? Theme.surfaceHover : Theme.surface
    Behavior on color { ColorAnimation { duration: 120 } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: root.spacing
    }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }
}
