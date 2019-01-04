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

    property int searching: 0
    function searchUser(keyword) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var res = JSON.parse(xhr.responseText);
                usersFound.clear();
                for (var i in res.assets) {
                    var user = res.assets[i];
                    usersFound.append({
                        userid: user.id,
                        username: user.screenName,
                        amount: user.amount,
                        avatarurl: "http://api.phereo.com/avatar/%1/100.100".arg(user.id)
                    });
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
        dy: 20

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
                anchors.verticalCenterOffset: usersFound.count == 0 && searching == 0 ? 0 : -70 - height
                spacing: 20
                Column {
                    Item {
                        width: 120
                        height: 20
                        CLabel {
                            anchors.fill: parent
                            anchors.leftMargin: (editbox.searchType == 0) * 2 * direction
                            text: "Search by keyword"
                            onClicked: search(0)
                            font.bold: anchors.leftMargin != 0
                        }
                    }
                    Item {
                        width: 120
                        height: 20
                        CLabel {
                            anchors.fill: parent
                            anchors.leftMargin: (editbox.searchType == 1) * 2 * direction
                            text: "Search user"
                            onClicked: search(1)
                            font.bold: anchors.leftMargin != 0
                        }
                    }
                    Item {
                        width: 120
                        height: 20
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
                    width: Math.max(implicitWidth, 120)
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
                anchors.verticalCenterOffset: 140
                text: usersFound.count > 0 ? (roll.modelItem ? roll.modelItem.username + " (" + roll.modelItem.amount + ")" : "") :
                                             searching == 1 ? "Searching..." :
                                             searching == 2 ? "No result" : ""
            }
        }
    }
}
