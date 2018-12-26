import QtQuick 2.0

Item {
    id: page
    property var phereo: null

    property var profileData: {
        "userid": "",
        "username": "",
        "screenName":	"",
        "description": "",
        "blog": "",
        "location": "",
        "email": "",
        "facebook": "",
        "flickr": "",
        "googleplus": "",
        "phone": "",
        "stereocamera": "",
        "viewer": "",
        "twitter": "",
        "website": "",
        "firstName": "",
        "lastName": "",
        "amount": 0,
        "albums": 0,
        "followeesCount": 0,
        "followersCount": 0,
        "favoritesCount": 0
    }

    property real flickY: 0
    property string currentUid

    function updateProfile() {
        var uid = phereo.photo.userid;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                profileData = {
                    "userid": uid,
                    "avatarurl": "http://api.phereo.com/avatar/%1/100.100".arg(uid),
                    "username": res.username || "",
                    "screenName": res.screenName || "",
                    "description": res.description || "",
                    "blog": res.profile.blog || "",
                    "location": res.profile.currentCity || "",
                    "email": res.profile.email || "",
                    "facebook": res.profile.facebook || "",
                    "flickr": res.profile.flickr || "",
                    "googleplus": res.profile.googleplus || "",
                    "phone": res.profile.phone || "",
                    "stereocamera": res.profile.stereocamera || "",
                    "viewer": res.profile.system3d || "",
                    "twitter": res.profile.twitter || "",
                    "website": res.profile.website || "",
                    "firstName": res.firstName || "",
                    "lastName": res.lastName || "",
                    "amount": res.amount || 0,
                    "albums": res.albums || 0,
                    "followeesCount": res.followeesCount || 0,
                    "followersCount": res.followersCount || 0,
                    "favoritesCount": res.favoritesCount || 0
                }
                currentUid = uid;
                var xhr2 = new XMLHttpRequest();
                xhr2.onreadystatechange = function() {
                    if (xhr2.readyState === XMLHttpRequest.DONE) {
                        var res = JSON.parse(xhr2.responseText);
                        albumsList.clear();
                        albumsList.append({
                            title: "All photos",
                            count: profileData.amount,
                            albumid: "-",
                            albumthumburl: profileData.avatarurl
                        });
                        for (var i in res.assets) {
                            var album = res.assets[i];
                            if (album.id && album.count) {
                                albumsList.append({
                                    title: album.title,
                                    count: album.count,
                                    albumid: "" + album.id,
                                    albumthumburl: "http://api.phereo.com/imagestore/%1/thumb.square/280/".arg(album.cover)
                                });
                            }
                        }
                    }
                }
                xhr2.open("GET", "http://api.phereo.com/api/open/albums/?user=%1&offset=0&count=500&adultFilter=2".arg(uid));
                xhr2.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
                xhr2.send();
            }
        }
        xhr.open("GET", "http://api.phereo.com/api/open/userprofile/?id=%1".arg(uid));
        xhr.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
        if (uid && uid !== currentUid)
            xhr.send();
    }

    function back() {
        phereo.showList();
        return true;
    }

    Connections {
        target: phereo
        onPhotoChanged: updateProfile()
    }

    Component.onCompleted: updateProfile()

    Component {
        id: infos
        Item {
            property real direction: 1
            Image {
                x: 5
                y: 5
                width: 75
                height: 75
                source: profileData.avatarurl
            }
            Flickable {
                id: flickableProperties
                x: 85
                y: 5
                height: parent.height-10
                width: parent.width-90
                clip: true
                flickableDirection: Qt.Vertical
                contentHeight: columnProperties.height
                interactive: contentHeight > height

                onContentYChanged: flickY = contentY
                Connections {
                    target: page
                    onFlickYChanged: if (!flickableProperties.moving) flickableProperties.contentY = flickY
                }

                Column {
                    id: columnProperties
                    width: flickableProperties.width
                    PLabel {
                        text: profileData.screenName
                        font.bold: true
                    }
                    PLabel {
                        text: profileData.username
                        small: true
                    }
                    PLabel {
                        text: profileData.description.trim()
                        visible: text
                        font.italic: true
                        width: parent.width
                        horizontalAlignment: Text.AlignJustify
                    }
                    PLabel {
                        width: parent.width
                        height: implicitHeight + 5
                        small: true
                        text: profileData.amount + " photos, " +
                              profileData.albums + " albums, " +
                              profileData.followeesCount + " followees, " +
                              profileData.followersCount + " followers, " +
                              profileData.favoritesCount + " likes"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignTop
                        visible: profileData.username
                    }
                    Repeater {
                        model: ["firstName", "lastName", "email", "phone", "location", "stereocamera", "viewer", "blog", "website", "flickr", "twitter", "facebook", "googleplus"]
                        delegate: Item {
                            width: columnProperties.width
                            height: childrenRect.height
                            visible: lineText.text
                            PLabel {
                                id: lineLabel
                                anchors.baseline: lineText.baseline
                                text: modelData + ":"
                                small: true
                            }
                            PLabel {
                                id: lineText
                                x: lineLabel.width + 5
                                width: columnProperties.width - lineLabel.width - 10
                                text: profileData[modelData]
                                horizontalAlignment: Text.AlignLeft
                            }
                        }
                    }
                }
            }
        }
    }
    ListModel {
        id: albumsList
    }
    Loader {
        anchors {
            top: parent.top
            bottom: pvl.top
            left: parent.left
            right: parent.horizontalCenter
        }
        sourceComponent: infos
        onLoaded: item.direction = 1
    }
    Loader {
        anchors {
            top: parent.top
            bottom: pvr.top
            left: parent.horizontalCenter
            right: parent.right
        }
        sourceComponent: infos
        onLoaded: item.direction = -1
    }

    Component {
        id: entryDelegate
        Item {
            id: item
            anchors.verticalCenter: parent.verticalCenter
            property real dx: PathView.view.dir * PathView.itemZ
            property bool isCurrentItem: PathView.isCurrentItem
            property string title: model.title + " (" + model.count + ")"

            visible: PathView.onPath
            scale: PathView.itemScale
            opacity: PathView.itemOpacity
            z: PathView.itemZ

            width: 105
            height: 105
            Rectangle {
                x: dx
                y: 5 - Math.pow((parent.z - 3), 2)
                width: 105
                height: 105
                Image {
                    id: img
                    anchors.centerIn: parent
                    width: 100
                    height: 100
                    source: model.albumthumburl
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
                            if (model.albumid === "-") {
                                phereo.showList();
                                phereo.loadUser(profileData.userid, profileData.screenName);
                            } else {
                                phereo.showList();
                                phereo.loadAlbum(model.albumid, "%1 [%2]".arg(model.title).arg(profileData.screenName));
                            }
                        } else {
                            pvl.positionViewAtIndex(index, ListView.Center);
                            pvr.positionViewAtIndex(index, ListView.Center);
                        }
                    }
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
        PathLine { x: page.width/2*0.4; }
        PathPercent { value: 0.48; }
        PathLine { x: page.width/2*0.5; }
        PathAttribute { name: "itemOpacity"; value: 1; }
        PathAttribute { name: "itemScale"; value: 1.0; }
        PathAttribute { name: "itemZ"; value: 3 }
        PathLine { x: page.width/2*0.6; }
        PathPercent { value: 0.52; }
        PathLine { x: page.width/2; }
        PathAttribute { name: "itemOpacity"; value: 0.1; }
        PathAttribute { name: "itemScale"; value: 0.5; }
        PathAttribute { name: "itemZ"; value: -4 }
    }
    PathView {
        id: pvl
        property real dir: 1

        anchors.bottom: parent.bottom
        width: parent.width/2
        height: 130

        model: albumsList
        delegate: entryDelegate

        clip: true
        path: commonPath

        pathItemCount: 9

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        onOffsetChanged: if(moving) pvr.offset = offset

        PLabel {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: pvl.currentItem ? pvl.currentItem.title: ""
            font.bold: true
        }
    }
    PathView {
        id: pvr
        property real dir: -1

        anchors.bottom: parent.bottom
        x:parent.width/2
        width: parent.width/2
        height: 130

        model: albumsList
        delegate: entryDelegate

        clip: true
        path: commonPath

        pathItemCount: 9

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        onOffsetChanged: if(moving) pvl.offset = offset

        PLabel {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: pvl.currentItem ? pvl.currentItem.title: ""
            font.bold: true
        }
    }
}
