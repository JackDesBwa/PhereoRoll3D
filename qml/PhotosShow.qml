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
    property bool downloading: false
    property bool longDescription: false

    function openInfosAndComments(action) {
        if (action === true || action === undefined) { // Always open
            if (showInfos) {
                if ((phereo.photo.comments > 0 || longDescription) && !showComments)
                    showComments = true;
                else if (action === undefined)
                    showComments = false;
            } else {
                showInfos = true;
            }

        } else if (action === false) { // Always close
            if (showComments)
                showComments = false;
            else if (showInfos)
                showInfos = false;
        }
    }

    function setScale(v) {
        scaleFactor = Math.min(Math.max(v, 0.1), 10);
    }
    function setDivergence(v) {
        divergence = Math.min(Math.max(v, -imgl.implicitWidth*0.25), imgl.implicitWidth*0.25);
    }
    function setXY(x, y) {
        posX = x;
        posY = y;
    }

    function handleKey(event) {
        if (event.key === Qt.Key_X) {
            inverted = !inverted;
            event.accepted = true;

        } else if (event.key === Qt.Key_Up) {
            openInfosAndComments(true);
            event.accepted = true;

        } else if (event.key === Qt.Key_Down) {
            openInfosAndComments(false);
            event.accepted = true;

        } else if (event.key === Qt.Key_Plus) {
            setScale(scaleFactor * 1.1);
            event.accepted = true;

        } else if (event.key === Qt.Key_Minus) {
            setScale(scaleFactor / 1.1);
            event.accepted = true;

        } else if (event.key === Qt.Key_Equal || event.key === Qt.Key_0) {
            setScale(1.0);
            event.accepted = true;

        } else if (event.key === Qt.Key_2) {
            setDivergence(divergence + 1);
            event.accepted = true;

        } else if (event.key === Qt.Key_8) {
            setDivergence(divergence - 1);
            event.accepted = true;

        } else if (event.key === Qt.Key_5) {
            setDivergence(0);
            event.accepted = true;
        }
    }

    onShowInfosChanged: {
        if (!showInfos)
            showComments = false;
    }

    Component.onCompleted: toolbox.setDownloadId(phereo.photo.imgid)

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
        function onSelectionChanged() {
            if (showComments)
                updateComments();
            toolbox.setDownloadId(phereo.photo.imgid);
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
                height: showComments ? parent.height : Math.min(infosData.height + 10 * adjScr, parent.height/2)
                interactive: contentHeight > height
                onContentYChanged: commentsY = contentY
                onInteractiveChanged: longDescription = interactive
                Connections {
                    target: show
                    function onCommentsYChanged() {
                        if (!commentFlick.moving)
                            commentFlick.contentY = commentsY;
                    }
                }
                Column {
                    id: infosData
                    spacing: 10 * adjScr
                    width: parent.width
                    MouseArea {
                        x: 5 * adjScr
                        y: 5 * adjScr
                        width: parent.width
                        height: childrenRect.height
                        onClicked: openInfosAndComments()
                        Column {
                            width: parent.width - 10 * adjScr

                            Item {
                                height: childrenRect.height
                                width: parent.width
                                Row {
                                    id: righttools
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.topMargin: 5 * adjScr
                                    Item {
                                        width: 45 * adjScr
                                        height: 45 * adjScr
                                        Image {
                                            id: dlimg
                                            anchors.centerIn: parent
                                            width: 25 * adjScr
                                            height: 25 * adjScr
                                            source: toolbox.hasWritePermissions ? (toolbox.imgPath !== "" ? "qrc:/pics/dl_ok.png" : "qrc:/pics/dl.png") : "qrc:/pics/dl_ko.png"
                                            visible: !downloading && imgl.status == Image.Ready
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (toolbox.imgPath !== "") {
                                                        Qt.openUrlExternally("file://" + toolbox.imgPath);
                                                    } else if (toolbox.hasWritePermissions) {
                                                        downloading = true;
                                                        var dlHandler = function() {
                                                            toolbox.downloadEnd.disconnect(dlHandler);
                                                            downloading = false;
                                                        }
                                                        toolbox.downloadEnd.connect(dlHandler);
                                                        toolbox.download(phereo.photo.imgurl, phereo.photo.imgid);
                                                    }
                                                }
                                            }
                                            SequentialAnimation {
                                                id: dlAnimation
                                                loops: 3
                                                alwaysRunToEnd: true
                                                NumberAnimation {
                                                    target: dlimg
                                                    property: "opacity"
                                                    duration: 150
                                                    easing.type: Easing.InOutQuad
                                                    to: 0
                                                }
                                                NumberAnimation {
                                                    target: dlimg
                                                    property: "opacity"
                                                    duration: 150
                                                    easing.type: Easing.InOutQuad
                                                    to: 1
                                                }
                                            }
                                            Connections {
                                                target: show
                                                function onDownloadingChanged() {
                                                    if (!downloading)
                                                        dlAnimation.start();
                                                }
                                            }
                                        }
                                    }
                                    Item {
                                        width: 45 * adjScr
                                        height: 45 * adjScr
                                        Image {
                                            anchors.centerIn: parent
                                            width: 25 * adjScr
                                            height: 25 * adjScr
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
                                    spacing: 5 * adjScr
                                    AvatarImage {
                                        width: 45 * adjScr
                                        height: 45 * adjScr
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
                                        width: parent.width - (45 + 10) * adjScr
                                        anchors.verticalCenter: parent.verticalCenter
                                        Flow {
                                            width: parent.width
                                            PLabel {
                                                width: Math.min(implicitWidth, parent.width)
                                                text: phereo.photo.title
                                                font.bold: true
                                                horizontalAlignment: Text.AlignLeft
                                            }
                                            Item { width: 5 * adjScr; height: 1; visible: parent.height < 20 * adjScr }
                                            CLabel {
                                                width: Math.min(implicitWidth, parent.width)
                                                text: phereo.photo.user
                                                onClicked: {
                                                    phereo.showList();
                                                    phereo.loadUser(phereo.photo.userid, phereo.photo.user);
                                                }
                                                horizontalAlignment: Text.AlignLeft
                                                onPressAndHold: phereo.showUser()
                                            }
                                        }
                                        Row {
                                            spacing: 8 * adjScr
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
                                        Row {
                                            spacing: 5 * adjScr
                                            Row {
                                                spacing: 3 * adjScr
                                                visible: phereo.photo.flagPopular
                                                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/label.png" }
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
                                                spacing: 3 * adjScr
                                                visible: phereo.photo.flagFeatured
                                                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/label.png" }
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
                                                spacing: 3 * adjScr
                                                visible: phereo.photo.flagStaff
                                                Image { anchors.bottom: parent.bottom; width: 12 * adjScr; height: 12 * adjScr; source: "qrc:/pics/label.png" }
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
                                spacing: 5 * adjScr
                                PLabel {
                                    text: phereo.category
                                    font.bold: true
                                }
                                CLabel {
                                    text: (phereo.selection+1) + "/" + phereo.nbImagesLoaded + (phereo.nbImagesLoaded < phereo.nbImagesMax ? "+": "") + (phereo.nbImagesLoaded > phereo.photosList.count ? " ("+phereo.photosList.count+" filtered)" : "")
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
                                    x: tagLabel.width + 5 * adjScr
                                    width: parent.width - tagLabel.width - 10 * adjScr
                                    Repeater {
                                        model: tagslist
                                        delegate: CLabel {
                                            width: implicitWidth + 5 * adjScr
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
                                    x: albumsLabel.width + 5 * adjScr
                                    width: parent.width - albumsLabel.width - 10 * adjScr
                                    Repeater {
                                        model: phereo.photo.albums
                                        delegate: CLabel {
                                            width: implicitWidth + 5 * adjScr
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
                            height: comment.height + 10 * adjScr
                            Rectangle {
                                anchors.fill: parent
                                color: "white"
                                opacity: 0.2
                            }
                            Column {
                                id: comment
                                width: parent.width - 10 * adjScr
                                x: 5 * adjScr
                                y: 5 * adjScr
                                Row {
                                    spacing: 5 * adjScr
                                    AvatarImage {
                                        width: 45 * adjScr
                                        height: 45 * adjScr
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

        onCanceled: {
            scaleFactor = i_scale;
            divergence = i_divergence;
        }

        onLeftClicked: phereo.previous()
        onRightClicked: phereo.next()
        onTopClicked: back()
        onBottomClicked: openInfosAndComments()
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

        onBottomProportionalStop: openInfosAndComments(true)
        onBottomDuoPressed: posX = posY = 0

        onSwipedLeft: phereo.next();
        onSwipedRight: phereo.previous();
        onSwipedUp:  openInfosAndComments(true);
        onSwipedDown: {
            if (showInfos)
                openInfosAndComments(false);
            else
                inverted = !inverted;
        }

        onWheel: {
            if (wheel.modifiers & Qt.ShiftModifier) {
                setDivergence(divergence + wheel.angleDelta.y / 100);
            } else {
                setScale(scaleFactor + wheel.angleDelta.y / 1000);
            }
        }

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
            x: parent.width/2 - width/2 * scale + posX + divergence * scale
            y: parent.height/2 - height/2 * scale + posY
            source: phereo.photo.imgurl
            fillMode: Image.PreserveAspectCrop
            width: imgr.width
            horizontalAlignment: inverted ? Image.AlignRight : Image.AlignLeft
            scale: imgr.scale
            transformOrigin: Item.TopLeft
            onStatusChanged: {
                const sourceStr = source.toString();
                if (status == Image.Error && sourceStr.indexOf('//api.phereo.com/') !== -1 && sourceStr.indexOf('imagestore2') !== -1) {
                    phereo.photo.imgurl = sourceStr.replace('imagestore2', 'imagestore');
                    phereo.selectionChanged();
                }
            }
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
            x: parent.width/2 - width/2 * scale + posX - divergence * scale
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
        width: 40 * adjScr
        height: 40 * adjScr
        visible: !showComments
        onClicked: phereo.mode3D.modeAlt = !phereo.mode3D.modeAlt
    }
}
