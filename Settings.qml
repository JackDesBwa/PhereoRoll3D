import QtQuick 2.0

MouseArea {
    id: page
    property var phereo: null
    property int selection: 0

    Component {
        id: infos
        Item {
            property real direction: 1
            Row {
                anchors.centerIn: parent
                width: Math.min(implicitWidth, parent.width)
                spacing: 20
                Column {
                    Repeater {
                        model: ["Landscape", "Landscape Alt.", "Portrait", "Portrait Alt."]
                        CLabel {
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.horizontalCenterOffset: page.selection == index ? direction : 0;
                            text: modelData
                            font.bold: page.selection == index
                            onClicked: page.selection = index
                        }
                    }
                }

                Column {
                    spacing: 5
                    Repeater {
                        model: phereo.mode3D.list
                        CLabel {
                            property string prop: ["landscapeMode", "landscapeModeAlt", "portraitMode", "portraitModeAlt"][page.selection]
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: index === phereo.mode3D[prop] ? direction : 0
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
        onLoaded: item.direction = 1
    }
    Loader {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.horizontalCenter
            right: parent.right
        }
        sourceComponent: infos
        onLoaded: item.direction = -1
    }
}
