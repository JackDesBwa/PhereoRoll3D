import QtQuick 2.0

Item {
    id: roll
    property var model
    readonly property var modelItem: pvl.currentItem ? pvl.currentItem.modelItem : null
    property int size: 200
    property string modelThumb
    property Component both
    property alias currentIndex: pvl.currentIndex
    signal clicked(var index)

    Component {
        id: entryDelegate
        Item {
            id: item
            anchors.verticalCenter: parent.verticalCenter
            property real dx: PathView.view.dir * PathView.itemZ
            property bool isCurrentItem: PathView.isCurrentItem
            property var modelItem: model

            visible: PathView.onPath
            scale: PathView.itemScale
            opacity: PathView.itemOpacity
            z: PathView.itemZ

            width: size + 5
            height: size + 5
            Rectangle {
                x: dx
                y: 5 - Math.pow((parent.z - 3), 2)
                width: size + 5
                height: size + 5
                Image {
                    id: img
                    anchors.centerIn: parent
                    width: size
                    height: size
                    source: model[modelThumb]
                    fillMode: Image.PreserveAspectFit
                }

                Loading {
                    anchors.fill: parent
                    visible: img.status == Image.Loading
                    value: img.progress
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (item.isCurrentItem) {
                            roll.clicked(index)
                        } else {
                            pvl.positionViewAtIndex(index, ListView.Center);
                            pvr.positionViewAtIndex(index, ListView.Center);
                        }
                    }
                }
            }
        }
    }
    Path {
        id: commonPath
        startX: 0

        PathAttribute { name: "itemOpacity"; value: 0.1; }
        PathAttribute { name: "itemScale"; value: 0.5; }
        PathAttribute { name: "itemZ"; value: -4 }
        PathLine { x: roll.width/2*0.4; }
        PathPercent { value: 0.48; }
        PathLine { x: roll.width/2*0.5; }
        PathAttribute { name: "itemOpacity"; value: 1; }
        PathAttribute { name: "itemScale"; value: 1.0; }
        PathAttribute { name: "itemZ"; value: 3 }
        PathLine { x: roll.width/2*0.6; }
        PathPercent { value: 0.52; }
        PathLine { x: roll.width/2; }
        PathAttribute { name: "itemOpacity"; value: 0.1; }
        PathAttribute { name: "itemScale"; value: 0.5; }
        PathAttribute { name: "itemZ"; value: -4 }
    }
    PathView {
        id: pvl
        property real dir: 1

        width: parent.width/2
        height: parent.height

        model: parent.model
        delegate: entryDelegate

        clip: true
        path: commonPath

        pathItemCount: 9

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        onOffsetChanged: if(moving) pvr.offset = offset

        Loader {
            anchors.fill: parent
            sourceComponent: roll.both
            onLoaded: {
                if (item.direction)
                    item.direction = parent.dir;
            }
        }
    }
    PathView {
        id: pvr
        property real dir: -1

        x:parent.width/2
        width: parent.width/2
        height: parent.height

        model: parent.model
        delegate: entryDelegate

        clip: true
        path: commonPath

        currentIndex: pvl.currentIndex
        pathItemCount: 9

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        onOffsetChanged: if(moving) pvl.offset = offset

        Loader {
            anchors.fill: parent
            sourceComponent: roll.both
            onLoaded: {
                if (item.direction)
                    item.direction = parent.dir;
            }
        }
    }
}
