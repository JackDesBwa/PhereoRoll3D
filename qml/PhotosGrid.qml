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
            spacing: 2 * adjScr
            Repeater {
                model: ListModel {
                    ListElement { text: "Popular" }
                    ListElement { text: "Latest" }
                    ListElement { text: "Featured" }
                    ListElement { text: "Staff" }
                }

                delegate: Item {
                    property string category: model.text
                    width: 80 * adjScr
                    height: 20 * adjScr
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
            y: parent.height/2 - 120 * adjScr
            spacing: 5 * adjScr

            PLabel {
                text: phereo.category
                font.bold: true
            }
            CLabel {
                text: {
                    if (phereo.selection === -1)
                        return "...";
                    if (phereo.photosList.count === 0)
                        return "No result";
                    return (phereo.selection+1) + "/" + phereo.nbImagesLoaded + (phereo.nbImagesLoaded < phereo.nbImagesMax ? "+": "") + (phereo.nbImagesLoaded > phereo.photosList.count ? " ("+phereo.photosList.count+" filtered)" : "")
                }
                onClicked: phereo.loadNext()
            }
        }
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height/2 + 115 * adjScr
            PLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: direction
                visible: phereo.photosList.count > 0
                text: phereo.photo.title
                font.bold: true
                font.pixelSize: 15 * adjScr
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
                spacing: 8 * adjScr
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
                    spacing: 2 * adjScr
                    Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/likes.png" }
                    PLabel { text: phereo.photo.likes; font.bold: true }
                }
                Row {
                    spacing: 2 * adjScr
                    Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/views.png" }
                    PLabel { text: phereo.photo.views; font.italic: true }
                }
                Row {
                    spacing: 2 * adjScr
                    Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/comments.png" }
                    PLabel { text: phereo.photo.comments; font.italic: true }
                }
            }
        }
        Column {
            id: labels
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 5 * adjScr
            property int count: phereo.photosList.count
            property int totalPopular: 0
            property int totalFeatured: 0
            property int totalStaff: 0
            property int totalComments: 0
            property int totalLove: 0
            onCountChanged: labels_count.restart();

            Timer {
                id: labels_count
                interval: 5 //ms
                onTriggered: {
                    var pc = 0;
                    var fc = 0;
                    var sc = 0;
                    var cc = 0;
                    var love = 0;
                    for (var i = 0; i < phereo.photosList.count; i++) {
                        var photo = phereo.photosList.get(i);
                        if (photo) {
                            if (photo.flagPopular) pc += 1;
                            if (photo.flagFeatured) fc += 1;
                            if (photo.flagStaff) sc += 1;
                            cc += photo.comments;
                            love += photo.likes;
                        }
                    }
                    parent.totalPopular = pc;
                    parent.totalFeatured = fc;
                    parent.totalStaff = sc;
                    parent.totalComments = cc;
                    parent.totalLove = love;
                }
            }
            Row {
                spacing: 3 * adjScr
                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/likes.png" }
                PLabel { text: labels.totalLove; small: true }
            }
            Row {
                spacing: 3 * adjScr
                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/comments.png" }
                CLabel { text: labels.totalComments; small: true; onClicked: phereo.toggleCommentsFilter() }
            }
            Row {
                spacing: 3 * adjScr
                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/label.png" }
                PLabel { text: "Popular " + labels.totalPopular; small: true }
            }
            Row {
                spacing: 3 * adjScr
                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/label.png" }
                PLabel { text: "Featured " + labels.totalFeatured; small: true }
            }
            Row {
                spacing: 3 * adjScr
                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/label.png" }
                PLabel { text: "Staff " + labels.totalStaff; small: true }
            }
        }
        Column {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 5 * adjScr
            spacing: 5 * adjScr
            Row {
                spacing: 5 * adjScr
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    width: 32 * adjScr
                    height: 32 * adjScr
                    source: "qrc:/pics/about.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: phereo.showAbout()
                    }
                }
                Image {
                    width: 32 * adjScr
                    height: 32 * adjScr
                    source: "qrc:/pics/mag.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: phereo.showSearch()
                    }
                }
                Image {
                    width: 32 * adjScr
                    height: 32 * adjScr
                    source: "qrc:/pics/gear.png"
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

    MouseArea {
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        width: 40 * adjScr
        height: 40 * adjScr
        onClicked: phereo.mode3D.modeAlt = !phereo.mode3D.modeAlt
    }
}
