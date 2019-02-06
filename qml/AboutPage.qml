import QtQuick 2.1

MouseArea {
    id: page
    property var phereo: null
    property int selection: 0

    function back() {
        phereo.showList();
        return true;
    }

    function gotoAuthor() {
        phereo.loadUser("585576c4888428d211000000", "JackDesBwa");
        phereo.showUser();
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
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                gotoAuthor();
                                Qt.openUrlExternally("https://github.com/JackDesBwa/PhereoRoll3D");
                            }
                        }
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
                            text: "Author"
                            small: true
                        }
                        CLabel {
                            text: "<u>JackDesBwa</u>"
                            onClicked: gotoAuthor()
                        }
                        Item {
                            width: 1
                            height: 10 * adjScr
                        }
                        PLabel {
                            width: 300 * adjScr
                            text: "This software is created on my spare time for my own usage, but I share it as a free software (MIT licence, see project page).<br><br>" +
                                  "If you really want to thank me for this sharing, you can find my email in my profile.<br><br>" +
                                  "Source code is available, so if it lacks something for you, feel free to contribute yourself and share your changes back." +
                                  " I do not accept to be paid to add a feature, but some freelancers might do."
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

    MouseArea {
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        width: 40
        height: 40
        onClicked: phereo.mode3D.modeAlt = !phereo.mode3D.modeAlt
    }
}
