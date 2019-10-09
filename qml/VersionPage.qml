import QtQuick 2.1

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
            Grid {
                anchors.centerIn: parent
                spacing: 30 * adjScr
                horizontalItemAlignment: Grid.AlignHCenter
                verticalItemAlignment: Grid.AlignVCenter
                columns: page.width > 2 * page.height ? 0 : 1
                rows: page.width > 2 * page.height ? 1 : 0
                Item {
                    width: 256 * adjScr
                    height: 256 * adjScr
                    Image {
                        id: icon
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 1.5 * direction
                        source: "qrc:/pics/icon.png"
                        width: implicitWidth * adjScr
                        height: implicitHeight * adjScr
                    }
                }
                MouseArea {
                    width: childrenRect.width
                    height: childrenRect.height
                    Column {
                        spacing: 5 * adjScr
                        PLabel {
                            text: "Project page, code & manual"
                            small: true
                        }
                        PLabel {
                            text: toolbox.reformatText("https://github.com/JackDesBwa/PhereoRoll3D")
                        }
                        Item {
                            width: 1
                            height: 10 * adjScr
                        }
                        PLabel {
                            text: "Last version: v" + phereo.jsonVersion.currentVersion
                        }
                        PLabel {
                            text: "Your version: v" + phereo.version
                        }
                        Item {
                            width: 1
                            height: 10 * adjScr
                        }
                        PLabel {
                            width: 300 * adjScr
                            text: toolbox.reformatText((phereo.version < phereo.jsonVersion.currentVersion) ? phereo.jsonVersion.oldmsg : phereo.jsonVersion.newmsg);
                            small: true
                            horizontalAlignment: Text.AlignJustify
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
