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
                      avatarurl: "http://api.phereo.com/avatar/%1/100.100".arg(photo.user.id),
                      comment: photo.body,
                      datetime: photo.created,
                      user: photo.user.name,
                      userid: photo.user.id
                    });
                }
            }
        }
        xhr.open("GET", "http://api.phereo.com/images/%1/comments?offset=0&count=100".arg(phereo.photo.imgid));
        xhr.send();
    }

    function back() {
        phereo.showList();
        return true;
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

                            Item {
                                height: childrenRect.height
                                width: parent.width
                                Row {
                                    id: righttools
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.topMargin: 5
                                    Item {
                                        width: 45
                                        height: 45
                                        Image {
                                            anchors.centerIn: parent
                                            width: 25
                                            height: 25
                                            source: "qrc:/pics/dl.png"
                                            visible: toolbox.hasWritePermissions
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: toolbox.download(phereo.photo.imgurl, phereo.photo.imgid)
                                            }
                                        }
                                    }
                                    Item {
                                        width: 45
                                        height: 45
                                        Image {
                                            anchors.centerIn: parent
                                            width: 25
                                            height: 25
                                            source: "qrc:/pics/web.png"
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: Qt.openUrlExternally("http://phereo.com/image/" + phereo.photo.imgid)
                                            }
                                        }
                                    }
                                }
                                Row {
                                    anchors.left: parent.left
                                    anchors.right: righttools.left
                                    spacing: 5
                                    AvatarImage {
                                        width: 45
                                        height: 45
                                        source: showInfos ? phereo.photo.avatarurl : ""
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                phereo.showList();
                                                phereo.loadUser(phereo.photo.userid, phereo.photo.user);
                                            }
                                            onPressAndHold: phereo.showUser()
                                        }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        Row {
                                            spacing: 5
                                            PLabel {
                                                text: phereo.photo.title
                                                font.bold: true
                                            }
                                            CLabel {
                                                text: phereo.photo.user
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadUser(phereo.photo.userid, phereo.photo.user);
                                                }
                                                onPressAndHold: phereo.showUser()
                                            }
                                        }
                                        Row {
                                            spacing: 8
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
                                                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/pics/likes.png" }
                                                PLabel { text: phereo.photo.likes; font.bold: true }
                                            }
                                            Row {
                                                spacing: 2
                                                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/pics/views.png" }
                                                PLabel { text: phereo.photo.views; font.italic: true }
                                            }
                                            Row {
                                                spacing: 2
                                                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/pics/comments.png" }
                                                PLabel { text: phereo.photo.comments; font.italic: true }
                                            }
                                        }
                                        Row {
                                            spacing: 5
                                            Row {
                                                spacing: 3
                                                visible: phereo.photo.flagPopular
                                                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/pics/label.png" }
                                                CLabel {
                                                    text: "Popular"
                                                    small: true
                                                    onClicked: {
                                                        phereo.showList();
                                                        phereo.loadCategory(0);
                                                    }
                                                }
                                            }
                                            Row {
                                                spacing: 3
                                                visible: phereo.photo.flagFeatured
                                                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/pics/label.png" }
                                                CLabel {
                                                    text: "Featured"
                                                    small: true
                                                    onClicked: {
                                                        phereo.showList();
                                                        phereo.loadCategory(2);
                                                    }
                                                }
                                            }
                                            Row {
                                                spacing: 3
                                                visible: phereo.photo.flagStaff
                                                Image { anchors.bottom: parent.bottom; width: 12; height: 12; source: "qrc:/pics/label.png" }
                                                CLabel {
                                                    text: "Staff"
                                                    small: true
                                                    onClicked: {
                                                        phereo.showList();
                                                        phereo.loadCategory(3);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            PLabel {
                                width: parent.width
                                text: toolbox.reformatText(phereo.photo.description)
                                visible: text
                                horizontalAlignment: Text.AlignLeft
                            }
                            Row {
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
                            Item {
                                width: parent.width
                                height: tagTextFlow.height
                                visible: tagslist.count > 0
                                property var tags: phereo.photo.tags
                                ListModel { id: tagslist }
                                onTagsChanged: {
                                    tagslist.clear();
                                    if (tags !== "") {
                                        var s = tags.split(",");
                                        for (var i in s)
                                            tagslist.append({ text: s[i] });
                                    }
                                }
                                PLabel { id: tagAlign; text: " " }
                                PLabel {
                                    anchors.baseline: tagAlign.baseline
                                    id: tagLabel
                                    text: "Tags:"
                                    small: true
                                }
                                Flow {
                                    id: tagTextFlow
                                    x: tagLabel.width + 5
                                    width: parent.width - tagLabel.width - 10
                                    Repeater {
                                        model: tagslist
                                        delegate: CLabel {
                                            width: implicitWidth + 5
                                            text: modelData
                                            font.italic: true
                                            onClicked: {
                                                phereo.showList();
                                                phereo.loadTag(modelData);
                                            }
                                        }
                                    }
                                }
                            }
                            Item {
                                width: parent.width
                                height: albumsTextFlow.height
                                visible: phereo.photo.albums.count > 0
                                PLabel { id: albumsAlign; text: " " }
                                PLabel {
                                    anchors.baseline: albumsAlign.baseline
                                    id: albumsLabel
                                    text: "Albums:"
                                    small: true
                                }
                                Flow {
                                    id: albumsTextFlow
                                    x: albumsLabel.width + 5
                                    width: parent.width - albumsLabel.width - 10
                                    Repeater {
                                        model: phereo.photo.albums
                                        delegate: CLabel {
                                            width: implicitWidth + 5
                                            text: model.title
                                            font.italic: true
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
                                    AvatarImage {
                                        width: 45
                                        height: 45
                                        source: model.avatarurl
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                phereo.showList();
                                                phereo.loadUser(model.userid, model.user);
                                            }
                                            onPressAndHold: {
                                                phereo.showUser();
                                                phereo.loadUser(model.userid, model.user);
                                            }
                                        }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        CLabel {
                                            text: model.user
                                            font.bold: true
                                            onClicked: {
                                                phereo.showList();
                                                phereo.loadUser(model.userid, model.user);
                                            }
                                            onPressAndHold: {
                                                phereo.showUser();
                                                phereo.loadUser(model.userid, model.user);
                                            }
                                        }
                                        PLabel {
                                            function pad(nb) { return nb < 10 ? "0"+nb : nb; }
                                            text: {
                                                var d = new Date(model.datetime * 1000);
                                                return [d.getFullYear(), pad(d.getMonth()+1), pad(d.getDate())].join('-') +' ' +
                                                        [pad(d.getHours()), pad(d.getMinutes())].join(':');
                                            }
                                            font.italic: true
                                        }
                                    }
                                }
                                PLabel {
                                    text: toolbox.reformatText(model.comment)
                                    width: parent.width
                                    horizontalAlignment: Text.AlignLeft
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
        onTopClicked: back()
        onBottomClicked: {
            if (showInfos) {
                if (phereo.photo.comments > 0 && !showComments)
                    showComments = true;
                else
                    showComments = false;
            } else {
                showInfos = true;
            }
        }
        onCenterClicked: showInfos = !showInfos

        onLeftProportionalStart: i_scale = scaleFactor
        onLeftProportionalUpdate: {
            var pos = -vv*vh/10+0.5;
            setScale((pos > 0.5 ? (pos - 0.5) * 2 * 4 + 1 : 1 / ((1 - pos * 2) * 4 + 1)) * i_scale)
        }
        onLeftDuoPressed: setScale(1)

        onRightProportionalStart: i_divergence = divergence
        onRightProportionalUpdate: setDivergence(vv * vh * -100 + i_divergence)
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
            source: phereo.photo.imgurl
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
            source: phereo.photo.imgurl
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

    MouseArea {
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        width: 40
        height: 40
        visible: !showComments
        onClicked: phereo.mode3D.modeAlt = !phereo.mode3D.modeAlt
    }
}
