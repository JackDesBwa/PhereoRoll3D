import QtQuick 2.0

Roll {
    property var phereo: null

    width: parent.width
    height: parent.height

    model: phereo.photosList
    modelThumb: "thumburl"

    currentIndex: phereo.selection
    onCurrentIndexChanged: phereo.selection = currentIndex

    onClicked: phereo.showPhoto(index)

    both: Item {
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
            property int totalLove: 0
            onCountChanged: {
                var pc = 0;
                var fc = 0;
                var sc = 0;
                var love = 0;
                for (var i = 0; i < phereo.photosList.count; i++) {
                    var photo = phereo.photosList.get(i);
                    if (photo.flagPopular) pc += 1;
                    if (photo.flagFeatured) fc += 1;
                    if (photo.flagStaff) sc += 1;
                    love += photo.likes;
                }
                totalPopular = pc;
                totalFeatured = fc;
                totalStaff = sc;
                totalLove = love;
            }
            Row {
                spacing: 3
                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/likes.png" }
                PLabel { text: labels.totalLove; small: true }
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
            spacing: 5
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    width: 32
                    height: 32
                    source: "qrc:/mag.png"
                    visible: false
                }
                Image {
                    width: 32
                    height: 32
                    source: "qrc:/gear.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: phereo.showSettings()
                    }
                }
            }
            PLabel {
                anchors.right: parent.right
                text: phereo.mode3D.name
                small: true
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
            }
        }
    }
}
