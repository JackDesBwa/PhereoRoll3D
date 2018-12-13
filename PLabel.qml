import QtQuick 2.0

Text {
    property bool small: false
    color: "white"
    font.pixelSize: small ? 10 : 13
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.WordWrap
}
