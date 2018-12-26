import QtQuick 2.0

Item {
    id: page
    property var phereo: null

    property var profileData: {
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
