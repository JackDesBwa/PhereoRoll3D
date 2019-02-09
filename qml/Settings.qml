import QtQuick 2.0

MouseArea {
    id: page
    property var phereo: null
    property int selection: 0

    function back() {
        phereo.showList();
        return true;
    }

    Component {
        id: infos
        Item {
            property real direction: 1
            Row {
                anchors.centerIn: parent
                width: Math.min(implicitWidth, parent.width)
                spacing: 10 * adjScr
                Column {
                    Repeater {
                        model: ["Landscape", "Landscape Alt.", "Portrait", "Portrait Alt."]
                        CLabel {
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.horizontalCenterOffset: page.selection == index ? direction : 0;
                            width: Math.max(implicitWidth, 150 * adjScr)
                            height: 25 * adjScr
                            text: modelData
                            font.bold: page.selection == index
                            onClicked: page.selection = index
                        }
                    }
                    CLabel {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.max(implicitWidth, 150 * adjScr)
                        height: 20 * adjScr
                        text: "[Cursor " + (phereo.disableCursor ? "disabled]" : "enabled]")
                        small: true
                        onClicked: phereo.disableCursor = !phereo.disableCursor
                    }
                }

                Column {
                    Repeater {
                        model: phereo.mode3D.list
                        CLabel {
                            property string prop: ["landscapeMode", "landscapeModeAlt", "portraitMode", "portraitModeAlt"][page.selection]
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: index === phereo.mode3D[prop] ? direction : 0
                            width: Math.max(implicitWidth, 150 * adjScr)
                            height: 20 * adjScr
                            text: modelData
                            small: true
                            font.bold: index === phereo.mode3D[prop]
                            onClicked: phereo.mode3D[prop] = index
                        }
                    }
                }
            }
        }
    }

    onClicked: phereo.showList()
    Loader {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.horizontalCenter
        }
        sourceComponent: infos
        onLoaded: item.direction = adjScr
    }
    Loader {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.horizontalCenter
            right: parent.right
        }
        sourceComponent: infos
        onLoaded: item.direction = -adjScr
    }

    MouseArea {
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        width: 40 * adjScr
        height: 40 * adjScr
        onClicked: phereo.mode3D.modeAlt = !phereo.mode3D.modeAlt
    }
}
