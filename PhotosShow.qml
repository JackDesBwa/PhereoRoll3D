import QtQuick 2.0

Item {
    id: show
    property var phereo: null

    property real scaleFactor: 1
    property real divergence: 0
    property real posX: 0
    property real posY: 0
    property real commentsY: 0
    property bool inverted: false
    property bool showInfos: false
    property bool showComments: false

    onShowInfosChanged: {
        if (!showInfos)
            showComments = false;
    }

    function updateComments() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                commentList.clear();
                for (var i in res["data"]) {
                    var photo = res["data"][i];
                    commentList.append({
                      comment: photo.body,
                      datetime: photo.created,
                      user: photo.user.name,
                      userid: photo.user.id
                    });
                }
            }
        }
        xhr.open("GET", "http://api.phereo.com/images/%1/comments?offset=0&count=100".arg(phereo.photo.imgid));
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        xhr.send();
    }
    Connections {
        target: phereo
        onSelectionChanged: {
            if (showComments)
                updateComments();
        }
    }
    onShowCommentsChanged: {
        if (showComments)
            updateComments();
    }

    ListModel {
        id: commentList
    }

    Component {
        id: infos
        Item {
            Rectangle {
                anchors.fill: commentFlick
                color: "black"
                opacity: 0.5
            }
            Flickable {
                id: commentFlick
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                flickableDirection: Flickable.VerticalFlick
                clip: true
                contentHeight: infosData.height
                height: showComments ? parent.height : Math.min(infosData.height + 10, parent.height/2)
                interactive: contentHeight > height
                onContentYChanged: commentsY = contentY
                Connections {
                    target: show
                    onCommentsYChanged: {
                        if (!commentFlick.moving)
                            commentFlick.contentY = commentsY;
                    }
                }
                Column {
                    id: infosData
                    spacing: 10
                    width: parent.width
                    MouseArea {
                        x: 5
                        y: 5
                        width: parent.width
                        height: childrenRect.height
                        onClicked: {
                            if (phereo.photo.comments > 0 && !showComments)
                                showComments = true;
                            else
                                showComments = false;
                        }
                        Column {
                            width: parent.width-10

                            Row {
                                spacing: 5
                                Image {
                                    width: 45
                                    height: 45
                                    source:"http://api.phereo.com/avatar/%1/100.100".arg(phereo.photo.userid)
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            phereo.showList();
                                            phereo.loadUser(phereo.photo.userid, phereo.photo.user);
                                        }
                                    }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    Row {
                                        spacing: 5
                                        Text {
                                            text: phereo.photo.title
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                        }
                                        Text {
                                            text: phereo.photo.user
                                            font.pixelSize: 13
                                            color: "white"
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadUser(phereo.photo.userid, phereo.photo.user);
                                                }
                                            }
                                        }
                                    }
                                    Row {
                                        spacing: 5
                                        Text {
                                            function pad(nb) { return nb < 10 ? "0"+nb : nb; }
                                            text: {
                                                var d = new Date(phereo.photo.datetime * 1000);
                                                return [d.getFullYear(), pad(d.getMonth()+1), pad(d.getDate())].join('-') +' ' +
                                                        [pad(d.getHours()), pad(d.getMinutes())].join(':');
                                            }
                                            font.pixelSize: 13
                                            color: "white"
                                        }
                                        Text { text: " ❤ " + phereo.photo.likes; color: "white"; font.pixelSize: 13; font.bold: true }
                                        Text { text: " 👁 " + phereo.photo.views; color: "white"; font.pixelSize: 13; font.italic: true }
                                        Text { text: " 💬 " + phereo.photo.comments; color: "white"; font.pixelSize: 13; font.italic: true }
                                    }
                                    Row {
                                        spacing: 5
                                        Text { text: "🏷 Popular"; visible: phereo.photo.flagPopular; color: "white"; font.pixelSize: 10
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadCategory(0);
                                                }
                                            }
                                        }
                                        Text { text: "🏷 Featured"; visible: phereo.photo.flagFeatured; color: "white"; font.pixelSize: 10
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadCategory(2);
                                                }
                                            }
                                        }
                                        Text { text: "🏷 Staff"; visible: phereo.photo.flagStaff; color: "white"; font.pixelSize: 10
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadCategory(3);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Text {
                                width: parent.width
                                text: phereo.photo.description
                                font.pixelSize: 13
                                color: "white"
                                visible: text
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                            Row {
                                spacing: 5
                                Text {
                                    text: phereo.category
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "white"
                                }
                                Text {
                                    text: (phereo.selection+1) + "/" + phereo.photosList.count + (phereo.photosList.count < phereo.nbImagesMax ? "+": "")
                                    font.pixelSize: 13
                                    color: "white"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            phereo.loadNext();
                                        }
                                    }
                                }
                            }
                            Text {
                                text: "Tags: " + phereo.photo.tags
                                font.pixelSize: 13
                                color: "white"
                                visible: phereo.photo.tags
                                font.italic: true
                            }
                            Flow {
                                spacing: 5
                                width: parent.width
                                Text {
                                    text: "Albums:"
                                    font.pixelSize: 13
                                    color: "white"
                                    visible: phereo.photo.albums.count > 0
                                    font.italic: true
                                }
                                Repeater {
                                    model: phereo.photo.albums
                                    delegate: Text {
                                        text: model.title
                                        font.pixelSize: 13
                                        color: "white"
                                        font.italic: true
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                phereo.showList();
                                                phereo.loadAlbum(model.id, "%1 [%2]".arg(model.title).arg(phereo.photo.user));
                                            }
                                        }
                                    }
                                }
                            }


                        }
                    }
                    Repeater {
                        model: showComments ? commentList : null
                        delegate: Item {
                            width: parent.width
                            height: comment.height + 10
                            Rectangle {
                                anchors.fill: parent
                                color: "white"
                                opacity: 0.2
                            }
                            Column {
                                id: comment
                                width: parent.width - 10
                                x: 5
                                y: 5
                                Row {
                                    spacing: 5
                                    Image {
                                        width: 45
                                        height: 45
                                        source:"http://api.phereo.com/avatar/%1/100.100".arg(model.userid)
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                phereo.showList();
                                                phereo.loadUser(model.userid, model.user);
                                            }
                                        }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            text: model.user
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 13
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadUser(model.userid, model.user);
                                                }
                                            }
                                        }
                                        Text {
                                            function pad(nb) { return nb < 10 ? "0"+nb : nb; }
                                            text: {
                                                var d = new Date(model.datetime * 1000);
                                                return [d.getFullYear(), pad(d.getMonth()+1), pad(d.getDate())].join('-') +' ' +
                                                        [pad(d.getHours()), pad(d.getMinutes())].join(':');
                                            }
                                            font.italic: true
                                            font.pixelSize: 13
                                            color: "white"
                                        }
                                    }
                                }
                                Text {
                                    text: model.comment
                                    color: "white"
                                    font.pixelSize: 13
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    GestureArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.horizontalCenter
        }

        property real i_scale: 1
        property real i_divergence: 1
        property real i_posX: 0
        property real i_posY: 0

        function setScale(v) {
            scaleFactor = Math.min(Math.max(v, 0.1), 10);
        }
        function setDivergence(v) {
            divergence = Math.min(Math.max(v, -100), 100);
        }
        function setXY(x, y) {
            posX = x;
            posY = y;
        }

        onCanceled: {
            scaleFactor = i_scale;
            divergence = i_divergence;
        }

        onLeftClicked: phereo.previous()
        onRightClicked: phereo.next()
        onTopClicked: phereo.showList()
        onBottomClicked: {
            if (showInfos) {
                showComments = true;
            } else {
                showInfos = true;
            }
        }
        onCenterClicked: showInfos = !showInfos

        onLeftProportionalStart: i_scale = scaleFactor
        onLeftProportionalUpdate: {
            var pos = vv*vh/10+0.5;
            setScale((pos > 0.5 ? (pos - 0.5) * 2 * 4 + 1 : 1 / ((1 - pos * 2) * 4 + 1)) * i_scale)
        }
        onLeftDuoPressed: setScale(1)

        onRightProportionalStart: i_divergence = divergence
        onRightProportionalUpdate: setDivergence(vv * vh * 100 + i_divergence)
        onRightDuoPressed: setDivergence(0)

        onTopProportionalStop: inverted = !inverted
        onTopDuoPressed: inverted = !inverted

        onBottomProportionalStop: {
            if (showInfos) {
                showComments = true;
            } else {
                showInfos = true;
            }
        }
        onBottomDuoPressed: posX = posY = 0

        onPitchStart: {
            i_posX = posX;
            i_posY = posY;
            i_scale = scaleFactor;
        }
        onPitchUpdate: {
            setXY(i_posX + dx, i_posY + dy);
            setScale(i_scale * v);
        }
    }
    Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.horizontalCenter
        }

        clip: true

        Image {
            id: imgl
            x: parent.width/2 - width/2 * scale + posX + divergence
            y: parent.height/2 - height/2 * scale + posY
            source: "http://api.phereo.com/imagestore2/%1/sidebyside/m/".arg(phereo.photo.imgid)
            fillMode: Image.PreserveAspectCrop
            width: imgr.width
            horizontalAlignment: inverted ? Image.AlignRight : Image.AlignLeft
            scale: imgr.scale
            transformOrigin: Item.TopLeft
        }
        Loading {
            anchors.fill: parent
            visible: imgl.status == Image.Loading
            value: imgl.progress
        }
        Loader {
            anchors.fill: parent
            visible: showInfos
            sourceComponent: infos
        }
    }
    Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.horizontalCenter
            right: parent.right
        }

        clip: true

        Image {
            id: imgr
            x: parent.width/2 - width/2 * scale + posX - divergence
            y: parent.height/2 - height/2 * scale + posY
            property real fitScale: Math.min(2 * parent.width / implicitWidth, parent.height/implicitHeight)
            source: "http://api.phereo.com/imagestore2/%1/sidebyside/m/".arg(phereo.photo.imgid)
            fillMode: Image.PreserveAspectCrop
            width: implicitWidth/2
            horizontalAlignment: inverted ? Image.AlignLeft : Image.AlignRight
            scale: scaleFactor * fitScale
            transformOrigin: Item.TopLeft
        }
        Loading {
            anchors.fill: parent
            visible: imgr.status == Image.Loading
            value: imgr.progress
        }
        Loader {
            anchors.fill: parent
            visible: showInfos
            sourceComponent: infos
        }
    }
}
