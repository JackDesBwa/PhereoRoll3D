import QtQuick 2.0

Item {
    property real value: 0
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: 10
        color: "white"

        Rectangle {
            height: parent.height
            width: value * parent.width
            color: "red"
        }
    }
}
