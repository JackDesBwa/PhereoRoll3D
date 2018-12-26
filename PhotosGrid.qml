import QtQuick 2.0

Row {
    id: grid
    property var phereo: null

    Component {
        id: entryDelegate
        Item {
            id: item
            anchors.verticalCenter: parent.verticalCenter
            property real dx: PathView.view.dir * PathView.itemZ
            property bool isCurrentItem: PathView.isCurrentItem

            visible: PathView.onPath
            scale: PathView.itemScale
            opacity: PathView.itemOpacity
            z: PathView.itemZ

            width: 205
            height: 205
            Rectangle {
                x: dx
                y: 5 - Math.pow((parent.z - 3), 2)
                width: 205
                height: 205
                Image {
                    id: img
                    anchors.centerIn: parent
                    width: 200
                    height: 200
                    source: model.thumburl
                    fillMode: Image.PreserveAspectFit
                }

                Loading {
                    anchors.fill: parent
                    visible: img.status == Image.Loading
                    value: img.progress
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (item.isCurrentItem) {
                            phereo.showPhoto(index);
                        } else {
                            pvl.positionViewAtIndex(index, ListView.Center);
                            pvr.positionViewAtIndex(index, ListView.Center);
                        }
                    }
                }
            }
        }
    }

    Component {
        id: infos
        Item {
            property int direction: 0
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2
                Repeater {
                    model: ListModel {
                        ListElement { text: "Popular" }
                        ListElement { text: "Latest" }
                        ListElement { text: "Featured" }
                        ListElement { text: "Staff" }
                    }

                    delegate: Item {
                        property string category: model.text
                        width: 80
                        height: 20
                        PLabel {
                            property bool hl: category === phereo.category
                            anchors.fill: parent;
                            anchors.leftMargin: hl ? direction*2 : 0
                            text: model.text
                            font.bold: hl
                            font.underline: hl
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: phereo.loadCategory(index)
                        }
                    }
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height/2 - 120
                spacing: 5

                PLabel {
                    text: phereo.category
                    font.bold: true
                }
                CLabel {
                    text: (phereo.selection+1) + "/" + phereo.photosList.count + (phereo.photosList.count < phereo.nbImagesMax ? "+": "")
                    onClicked: phereo.loadNext()
                }
            }
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height/2 + 115
                PLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: direction
                    visible: phereo.photosList.count > 0
                    text: phereo.photo.title
                    font.bold: true
                    font.pixelSize: 15
                }
                CLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: phereo.photosList.count > 0
                    text: phereo.photo.user
                    onClicked: phereo.loadUser(phereo.photo.userid, phereo.photo.user)
                    onPressAndHold: phereo.showUser()
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: phereo.photosList.count > 0
                    PLabel {
                        function pad(nb) { return nb < 10 ? "0"+nb : nb; }
                        text: {
                            var d = new Date(phereo.photo.datetime * 1000);
                            return [d.getFullYear(), pad(d.getMonth()+1), pad(d.getDate())].join('-') +' ' +
                                    [pad(d.getHours()), pad(d.getMinutes())].join(':');
                        }
                    }
                    Row {
                        spacing: 2
                        Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/likes.png" }
                        PLabel { text: phereo.photo.likes; font.bold: true }
                    }
                    Row {
                        spacing: 2
                        Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/views.png" }
                          PLabel { text: phereo.photo.views; font.italic: true }
                    }
                    Row {
                        spacing: 2
                        Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/comments.png" }
                        PLabel { text: phereo.photo.comments; font.italic: true }
                    }
                }
            }
            Column {
                id: labels
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 5
                property int count: phereo.photosList.count
                property int totalPopular: 0
                property int totalFeatured: 0
                property int totalStaff: 0
                onCountChanged: {
                    var pc = 0;
                    var fc = 0;
                    var sc = 0;
                    for (var i = 0; i < phereo.photosList.count; i++) {
                        var photo = phereo.photosList.get(i);
                        if (photo.flagPopular) pc += 1;
                        if (photo.flagFeatured) fc += 1;
                        if (photo.flagStaff) sc += 1;
                    }
                    totalPopular = pc;
                    totalFeatured = fc;
                    totalStaff = sc;
                }
                Row {
                    spacing: 3
                    Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/label.png" }
                    PLabel { text: "Popular " + labels.totalPopular; small: true }
                }
                Row {
                    spacing: 3
                    Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/label.png" }
                    PLabel { text: "Featured " + labels.totalFeatured; small: true }
                }
                Row {
                    spacing: 3
                    Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/label.png" }
                    PLabel { text: "Staff " + labels.totalStaff; small: true }
                }
            }
            Column {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 5
                CLabel {
                    width: Math.max(implicitWidth, 150)
                    height: Math.max(implicitHeight, 40)
                    text: phereo.mode3D.name
                    small: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignBottom
                    onClicked: phereo.showSettings()
                }
            }
        }
    }

    Path {
        id: commonPath
        startX: 0

        PathAttribute { name: "itemOpacity"; value: 0.1; }
        PathAttribute { name: "itemScale"; value: 0.5; }
        PathAttribute { name: "itemZ"; value: -4 }
        PathLine { x: grid.width/2*0.4; }
        PathPercent { value: 0.48; }
        PathLine { x: grid.width/2*0.5; }
        PathAttribute { name: "itemOpacity"; value: 1; }
        PathAttribute { name: "itemScale"; value: 1.0; }
        PathAttribute { name: "itemZ"; value: 3 }
        PathLine { x: grid.width/2*0.6; }
        PathPercent { value: 0.52; }
        PathLine { x: grid.width/2; }
        PathAttribute { name: "itemOpacity"; value: 0.1; }
        PathAttribute { name: "itemScale"; value: 0.5; }
        PathAttribute { name: "itemZ"; value: -4 }
    }

    PathView {
        id: pvl
        property real dir: 1

        width: parent.width/2
        height: parent.height

        model: parent.phereo.photosList
        delegate: entryDelegate

        clip: true
        path: commonPath

        currentIndex: phereo.selection
        pathItemCount: 9

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        onOffsetChanged: if(moving) pvr.offset = offset
        onCurrentIndexChanged: phereo.selection = currentIndex

        Loader { anchors.fill: parent; sourceComponent: infos; onLoaded: item.direction = parent.dir }
    }

    PathView {
        id: pvr
        property real dir: -1

        x:parent.width/2
        width: parent.width/2
        height: parent.height

        model: parent.phereo.photosList
        delegate: entryDelegate

        clip: true
        path: commonPath

        currentIndex: phereo.selection
        pathItemCount: 9

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        onOffsetChanged: if(moving) pvl.offset = offset

        Loader { anchors.fill: parent; sourceComponent: infos; onLoaded: item.direction = parent.dir }
    }
}
