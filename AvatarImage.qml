import QtQuick 2.0

Image {
    property bool replaceOnError: true
    Image {
        anchors.fill: parent
        visible: replaceOnError && parent.status === Image.Error
        onVisibleChanged: {
            if (visible)
                source = "https://www.gravatar.com/avatar/%1?f=y&d=identicon".arg(toolbox.md5(parent.source))
        }
    }
}
