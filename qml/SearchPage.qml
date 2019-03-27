import QtQuick 2.0

Item {
    id: page
    property var phereo: null

    function back() {
        phereo.showList();
        return true;
    }

    function search(t) {
        editbox.searchType = t;
        editbox.selectAll();
        page.parent.focus = true;
        page.focus = true;
        editbox.focus = true;
    }

    function handleKey(event) {
        if (event.key === Qt.Key_C || event.key === Qt.Key_F
                || event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            event.accepted = true; // Prevent default behavior of these keys which interfere with search box
        }
    }

    property int searching: 0
    property bool toomanyusers: false
    function searchUser(keyword) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                usersFound.clear();
                var founds = [];
                for (var i in res.assets) {
                    var user = res.assets[i];
                    founds.push({
                        userid: user.id,
                        username: user.screenName,
                        amount: user.amount,
                        avatarurl: "http://api.phereo.com/avatar/%1/100.100".arg(user.id)
                    });
                }
                founds.sort(function(a,b){ return b.amount - a.amount; });
                toomanyusers = (founds.length >= 500);
                for (var j in founds) {
                    usersFound.append(founds[j]);
                }
                searching = 2;
            }
        }
        xhr.open("GET", "http://api.phereo.com/api/open/search_users/?ss=%1&offset=0&count=500".arg(keyword));
        xhr.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
        usersFound.clear();
        searching = 1;
        xhr.send();
    }

    focus: true

    TextInput {
        id: editbox
        property int searchType: -1
        opacity: 0
        onAccepted: {
            focus = false;
            if (searchType == 0) {
                phereo.showList();
                phereo.loadSearch(text);

            } else if (searchType == 1) {
                searchUser(text);

            } else if (searchType == 2) {
                phereo.showList();
                phereo.loadTag(text);
            }
        }
    }

    Roll {
        id: roll
        anchors.fill: parent
        dy: 20 * adjScr

        model: ListModel { id: usersFound }
        modelThumb: "avatarurl"
        replaceOnError: true

        onClicked: {
            phereo.loadUser(roll.modelItem.userid, roll.modelItem.username);
            phereo.showUser();
        }

        both: Item {
            id: container
            property real direction: 0
            Row {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: usersFound.count == 0 && searching == 0 ? 0 : -70 * adjScr - height
                spacing: 20 * adjScr
                Column {
                    Item {
                        width: 120 * adjScr
                        height: 20 * adjScr
                        CLabel {
                            anchors.fill: parent
                            anchors.leftMargin: (editbox.searchType == 0) * 2 * direction
                            text: "Search by keyword"
                            onClicked: search(0)
                            font.bold: anchors.leftMargin != 0
                        }
                    }
                    Item {
                        width: 120 * adjScr
                        height: 20 * adjScr
                        CLabel {
                            anchors.fill: parent
                            anchors.leftMargin: (editbox.searchType == 1) * 2 * direction
                            text: "Search user"
                            onClicked: search(1)
                            font.bold: anchors.leftMargin != 0
                        }
                    }
                    Item {
                        width: 120 * adjScr
                        height: 20 * adjScr
                        CLabel {
                            anchors.fill: parent
                            anchors.leftMargin: (editbox.searchType == 2) * 2 * direction
                            text: "Search by tag"
                            onClicked: search(2)
                            font.bold: anchors.leftMargin != 0
                        }
                    }
                }
                CLabel {
                    property bool empty: editbox.activeFocus && !editbox.text
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(implicitWidth, 120 * adjScr)
                    text: empty ? "<Enter your search>" :
                                  editbox.text.substring(0, editbox.selectionStart) + "<u>" +
                                  editbox.text.substring(editbox.selectionStart, editbox.selectionEnd) + "</u>" +
                                  editbox.text.substring(editbox.selectionEnd)
                    font.italic: empty
                    small: empty
                    font.bold: !empty
                    onClicked: search(editbox.searchType)
                }
            }
            PLabel {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 140 * adjScr
                text: usersFound.count > 0 ? (roll.modelItem ? roll.modelItem.username + " (" + roll.modelItem.amount + ")" : "") :
                                             searching == 1 ? "Searching..." :
                                             searching == 2 ? "No result" : ""
            }
            PLabel {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 155 * adjScr
                text: "Limited to 500 users"
                small: true
                visible: toomanyusers
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
