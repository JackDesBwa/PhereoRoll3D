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
    property int rollData: -1

    function loadAlbums() {
        roll.model = albumsList;
        roll.modelThumb = "albumthumburl";
        rollData = 1;
        if (albumsList.count > 0)
            return;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                albumsList.clear();
                for (var i in res.assets) {
                    var album = res.assets[i];
                    if (album.id && album.count) {
                        albumsList.append({
                            title: album.title,
                            count: album.count,
                            albumid: album.id,
                            albumthumburl: "http://api.phereo.com/imagestore/%1/thumb.square/280/".arg(album.cover)
                        });
                    }
                }
            }
        }
        xhr.open("GET", "http://api.phereo.com/api/open/albums/?user=%1&offset=0&count=500&adultFilter=2".arg(currentUid));
        xhr.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
        albumsList.clear();
        xhr.send();
    }
    function loadFollowees() {
        roll.model = followeesList;
        roll.modelThumb = "avatarurl";
        rollData = 2;
        if (followeesList.count > 0)
            return;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                followeesList.clear();
                for (var i in res.assets) {
                    var user = res.assets[i];
                    followeesList.append({
                        userid: user.id,
                        username: user.screenName,
                        amount: user.amount,
                        avatarurl: "http://api.phereo.com/avatar/%1/100.100".arg(user.id)
                    });
                }
            }
        }
        xhr.open("GET", "http://api.phereo.com/api/open/userfollows/?id=%1&offset=0&count=500".arg(currentUid));
        xhr.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
        followeesList.clear();
        xhr.send();
    }
    function loadFollowers() {
        roll.model = followersList;
        roll.modelThumb = "avatarurl";
        rollData = 3;
        if (followersList.count > 0)
            return;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                followersList.clear();
                for (var i in res.assets) {
                    var user = res.assets[i];
                    followersList.append({
                        userid: user.id,
                        username: user.screenName,
                        amount: user.amount,
                        avatarurl: "http://api.phereo.com/avatar/%1/100.100".arg(user.id)
                    });
                }
            }
        }
        xhr.open("GET", "http://api.phereo.com/api/open/userfollowers/?id=%1&offset=0&count=500".arg(currentUid));
        xhr.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
        followersList.clear();
        xhr.send();
    }

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
                albumsList.clear();
                followeesList.clear();
                followersList.clear();
                loadAlbums();
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
            id: infosItem
            property real direction: 1
            Rectangle {
                x: 5
                y: 5
                width: 75
                height: 75
                Image {
                    anchors.fill: parent
                    anchors.margins: 2
                    source: profileData && profileData.avatarurl || ""
                }
            }
            Column {
                x: 5
                y: 85
                width: 75
                Repeater {
                    model: 5
                    delegate: CLabel {
                        x: (index == rollData) * infosItem.direction
                        width: parent.width
                        height: 20
                        text: {
                            if (index == 0)
                                return profileData.amount + " photos";
                            else if (index == 1)
                                return profileData.albums + " albums";
                            else if (index == 2)
                                return profileData.followeesCount + " followees";
                            else if (index == 3)
                                return profileData.followersCount + " followers";
                            else if (index == 4)
                                return profileData.favoritesCount + " likes";
                        }
                        font.bold: index == rollData
                        small: true
                        onClicked: {
                            if (index == 0) {
                                phereo.showList();
                                phereo.loadUser(profileData.userid, profileData.screenName);
                            } else if (index == 1) {
                                loadAlbums();
                            } else if (index == 2) {
                                loadFollowees();
                            } else if (index == 3) {
                                loadFollowers();
                            }
                        }
                    }
                }
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
                    Item { width: 5; height: 5 }
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
    ListModel { id: albumsList }
    ListModel { id: followeesList }
    ListModel { id: followersList }
    Loader {
        anchors {
            top: parent.top
            bottom: roll.top
            left: parent.left
            right: parent.horizontalCenter
        }
        sourceComponent: infos
        onLoaded: item.direction = 1
    }
    Loader {
        anchors {
            top: parent.top
            bottom: roll.top
            left: parent.horizontalCenter
            right: parent.right
        }
        sourceComponent: infos
        onLoaded: item.direction = -1
    }
    Roll {
        id: roll
        anchors.bottom: parent.bottom
        width: parent.width
        height: 130
        size: 100

        onClicked: {
            if (rollData == 1) {
                phereo.showList();
                phereo.loadAlbum(roll.modelItem.albumid, "%1 [%2]".arg(roll.modelItem.title).arg(profileData.screenName));
            } if (rollData == 2 || rollData == 3) {
                phereo.loadUser(roll.modelItem.userid, roll.modelItem.username);
            }
        }

        both: Item {
            PLabel {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (roll.modelItem) {
                        if (rollData == 1) {
                            return roll.modelItem.title + " (" + roll.modelItem.count + ")";
                        } if (rollData == 2 || rollData == 3) {
                            return roll.modelItem.username + " (" + roll.modelItem.amount + ")";
                        }
                    }
                    return "";
                }
                font.bold: true
            }
        }
    }
}
