import QtQuick 2.0
import QtQuick.Window 2.2
import Qt.labs.settings 1.0 as QtLabsSettings

Window {
    id: win
    visible: true
    visibility: Qt.platform.os === "android" ? Window.FullScreen : Window.Windowed
    width: 640
    height: 336
    title: qsTr("PhereoRoll3D - unofficial phereo viewer")
    color: "black"
    property real adjScr: Math.max(width, height)/640.0

    ListModel {
        id: photosList
    }

    QtObject {
       id: phereo
       property string category
       property string category_url
       property int nbImagesMax: 0
       property int selection: 0
       property bool disableCursor: false
       property var _photo: photosList.get(selection)
       property var photo: _photo ? _photo : {
               imgid: 0,
               imgurl: "",
               thumburl: "",
               avatarurl: "",
               title: "",
               description: "",
               tags: "",
               datetime: 0,
               views: 0,
               likes: 0,
               albums: [],
               userid: 0,
               user: "",
               flagFeatured: false,
               flagStaff: false,
               flagPopular: false,
               comments: 0,
           }
       property alias photosList: photosList

       property var mode3D: QtObject {
           id: mode3D
           readonly property int leftView: 0
           readonly property int rightView: 1
           readonly property int columnsInterleaved: 2
           readonly property int columnsInterleavedInv: 3
           readonly property int rowsInterleaved: 4
           readonly property int rowsInterleavedInv: 5
           readonly property int parallelHalfView: 6
           readonly property int parallelFullView: 7
           readonly property int crossHalfView: 8
           readonly property int crossFullView: 9
           readonly property int anaglyphMonochrome: 10
           readonly property int anaglyphDubois: 11

           readonly property var list: [
               "left view",
               "right view",
               "columns interleaved",
               "columns interleaved inverted",
               "rows interleaved",
               "rows interleaved inverted",
               "parallel half view",
               "parallel full view",
               "cross half view",
               "cross full view",
               "anaglyph monochrome",
               "anaglyph Dubois"
           ]

           property bool modeAlt: false
           property int portraitMode: leftView
           property int landscapeMode: columnsInterleaved
           property int portraitModeAlt: rowsInterleaved
           property int landscapeModeAlt: anaglyphMonochrome
           property int activeMode: win.width > win.height ?
                                          (modeAlt ? landscapeModeAlt : landscapeMode) :
                                          (modeAlt ? portraitModeAlt : portraitMode)
           property string name: list[activeMode]
       }

       function loadCategory(cat) {
           var caturl;
           if (cat === 1) {
               cat = "Latest"
               caturl = "latestuploads?";
           } else if (cat === 2) {
               cat = "Featured";
               caturl = "awards?";
           } else if (cat === 3) {
               cat = "Staff";
               caturl = "staffpicks?";
           } else {
               cat = "Popular";
               caturl = "popular?";
           }
           if (cat === category && photosList.count > 0)
               return;
           photosList.clear();
           category = cat;
           category_url = caturl;
           nbImagesMax = 0;
           selection = -1;
           loadNext();
       }
       function loadUser(userid, user) {
           photosList.clear();
           category = user;
           category_url = "images/?user=%1&userId=&userApi=&".arg(userid);
           nbImagesMax = 0;
           selection = -1;
           loadNext();
       }
       function loadAlbum(albumid, album) {
           photosList.clear();
           category = album;
           category_url = "images/?albumId=%1&userId=&userApi=&".arg(albumid);
           nbImagesMax = 0;
           selection = -1;
           loadNext();
       }
       function loadTag(tagname) {
           photosList.clear();
           category = "%1 [tag]".arg(tagname);
           category_url = "search_tags/?ss=%1&userId=&userApi=&".arg(encodeURIComponent(tagname));
           nbImagesMax = 0;
           selection = -1;
           loadNext();
       }
       function loadSearch(keyword) {
           photosList.clear();
           category = "%1 [search]".arg(keyword);
           category_url = "search/?ss=%1&userId=&userApi=&".arg(encodeURIComponent(keyword));
           nbImagesMax = 0;
           selection = -1;
           loadNext();
       }
       function loadUri(uri, display) {
           var imgid;
           uri = uri.toLowerCase();
           // Check image url
           var matches = (new RegExp("https?://phereo.com/image/([0-9a-f]+)")).exec(uri);
           if (matches) {
               imgid = matches[1];
               if (imgid) {
                   if (display) showPhoto(0);
                   photosList.clear();
                   category = "URL";
                   category_url = "image/%1?userId=&userApi=&".arg(imgid);
                   nbImagesMax = 0;
                   selection = -1;
                   loadNext();
                   return;
               }
           }
           // Check popular
           if (uri.startsWith("http://phereo.com/popular") || uri.startsWith("https://phereo.com/popular")) {
               if (display) showList();
               loadCategory(0);
               return;
           }
           // Check latest
           if (uri.startsWith("http://phereo.com/latest") || uri.startsWith("https://phereo.com/latest")) {
               if (display) showList();
               loadCategory(1);
               return;
           }
           // Check featured
           if (uri.startsWith("http://phereo.com/featured") || uri.startsWith("https://phereo.com/featured")) {
               if (display) showList();
               loadCategory(2);
               return;
           }
           // Check staff
           if (uri.startsWith("http://phereo.com/staff") || uri.startsWith("https://phereo.com/staff")) {
               if (display) showList();
               loadCategory(3);
               return;
           }
           // Check searches
           matches = (new RegExp("https?://phereo.com/s/\\?(type=([^&]+)&)?ss=([^&]+)")).exec(uri);
           if (matches) {
               var t = matches[2];
               var q = matches[3];
               if (!t || t === "images") {
                   if (display) showList();
                   loadSearch(q);
                   return;
               } else if (t === "tag") {
                   if (display) showList();
                   loadTag(q);
                   return;
               }
           }
           // Check image from API server
           matches = (new RegExp("https?://api.phereo.com/imagestore2/([0-9a-f]+)")).exec(uri);
           if (matches) {
               imgid = matches[1];
               if (imgid) {
                   if (display) showPhoto(0);
                   photosList.clear();
                   category = "URL";
                   category_url = "image/%1?userId=&userApi=&".arg(imgid);
                   nbImagesMax = 0;
                   selection = -1;
                   loadNext();
                   return;
               }
           }
           // Not found
           if (display) showList();
           loadCategory(0);
       }

       function loadNext() {
           var xhr = new XMLHttpRequest();
           xhr.onreadystatechange = function() {
               if (xhr.readyState === XMLHttpRequest.DONE) {
                   var res = JSON.parse(xhr.responseText);
                   for (var i in res["assets"]) {
                       var photo = res["assets"][i];
                       photosList.append({
                         imgid: photo.id,
                         imgurl: "http://api.phereo.com/imagestore2/%1/sidebyside/m/".arg(photo.id),
                         thumburl: "http://api.phereo.com/imagestore/%1/thumb.square/280/".arg(photo.id),
                         avatarurl: "http://api.phereo.com/avatar/%1/100.100".arg(photo.user.id),
                         title: photo.title,
                         description: photo.description,
                         tags: photo.tags,
                         datetime: photo.created,
                         views: photo.views,
                         likes: photo.likes,
                         album: photo.album,
                         userid: photo.user.id,
                         user: photo.user.name,
                         flagFeatured: photo.featured,
                         flagStaff: photo.staff,
                         flagPopular: photo.popular,
                         comments: photo.comments,
                         albums: photo.albums
                       });
                   }
                   if (res["totalCount"])
                       nbImagesMax = res["totalCount"];
                   if (selection == -1)
                       selection = 0;
               }
           }

           xhr.open("GET", "http://api.phereo.com/api/open/" + category_url + "offset=" + photosList.count + "&count=100&adultFilter=2");
           xhr.setRequestHeader("Accept", "application/vnd.phereo.v3+json");
           xhr.send();
       }
       function showList() {
           loader.setSource("qrc:/qml/PhotosGrid.qml", {"phereo": phereo});
       }
       function showPhoto(sel) {
           selection = sel;
           loader.setSource("qrc:/qml/PhotosShow.qml", {"phereo": phereo});
       }
       function showUser() {
           loader.setSource("qrc:/qml/UserProfile.qml", {"phereo": phereo});
       }
       function showSettings() {
           loader.setSource("qrc:/qml/Settings.qml", {"phereo": phereo});
       }
       function showSearch() {
           loader.setSource("qrc:/qml/SearchPage.qml", {"phereo": phereo});
       }
       function showAbout() {
           loader.setSource("qrc:/qml/AboutPage.qml", {"phereo": phereo});
       }
       function next() {
           var sel = selection + 1;
           if (sel >= photosList.count)
               sel = 0;
           selection = sel;
       }
       function previous() {
           var sel = selection - 1;
           if (sel < 0)
               sel = photosList.count - 1;
           selection = sel;
       }
       function init() {
           var handleUri = function(uri) {
               loadUri(uri, true);
           }
           toolbox.uriReceived.connect(handleUri);
           if (toolbox.lastUri) {
               handleUri(toolbox.lastUri);
           } else {
               loadCategory(0);
               showList();
           }
       }
    }

    Item {
        id: parallel_surface
        width: parent.width * 2
        height: parent.height

        focus: true
        Keys.onReleased: {
            if (loader.item.handleKey) {
                loader.item.handleKey(event);
                if (event.accepted)
                    return;
            }

            if (event.key === Qt.Key_VolumeUp || event.key === Qt.Key_Left) {
                phereo.previous();
                event.accepted = true;

            } else if (event.key === Qt.Key_VolumeDown || event.key === Qt.Key_Right) {
                phereo.next();
                event.accepted = true;

            } else if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
                if (loader.item.back && loader.item.back()) {
                    event.accepted = true;
                } else {
                    Qt.quit();
                }

            } else if (event.key === Qt.Key_Return) {
                if (!loader.item.back)
                    phereo.showPhoto(phereo.selection);
                event.accepted = true;

            } else if (event.key === Qt.Key_C) {
                phereo.disableCursor = !phereo.disableCursor;
                event.accepted = true;

            } else if (event.key === Qt.Key_F || event.key === Qt.Key_F11) {
                win.visibility = (win.visibility == Window.Windowed) ? Window.FullScreen :  Window.Windowed
            }
        }

        Row {
            Image {
                width: parallel_surface.width/2
                height: parallel_surface.height
                source: "qrc:/pics/bgl.png"
                fillMode: Image.Tile
            }
            Image {
                width: parallel_surface.width/2
                height: parallel_surface.height
                source: "qrc:/pics/bgr.png"
                fillMode: Image.Tile
            }
        }

        Loader {
            id: loader
            anchors.fill: parent
        }

        MouseArea {
            id: screenMouseArea
            property bool displayCustomCursor: false
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.BlankCursor
            hoverEnabled: true
            onPositionChanged: {
                displayCustomCursor = true;
                screenMouseOutTimer.restart();
            }
            Timer {
                id: screenMouseOutTimer
                interval: 1500
                repeat: false
                onTriggered: screenMouseArea.displayCustomCursor = false
            }
            Image {
                source: "qrc:/pics/cursorl.png"
                width: implicitWidth / 10.0 * adjScr
                height: implicitHeight / 10.0 * adjScr
                visible: screenMouseArea.containsMouse && !phereo.disableCursor
                opacity: screenMouseArea.displayCustomCursor ? 1 : 0
                x: screenMouseArea.mouseX
                y: screenMouseArea.mouseY
                Behavior on opacity { NumberAnimation{ duration: screenMouseArea.displayCustomCursor ? 1500 : 0 } }
            }
            Image {
                source: "qrc:/pics/cursorr.png"
                width: implicitWidth / 10.0 * adjScr
                height: implicitHeight / 10.0 * adjScr
                visible: screenMouseArea.containsMouse && !phereo.disableCursor
                opacity: screenMouseArea.displayCustomCursor ? 1 : 0
                x: parent.width/2 + screenMouseArea.mouseX
                y: screenMouseArea.mouseY
                Behavior on opacity { NumberAnimation{ duration: screenMouseArea.displayCustomCursor ? 1500 : 0 } }
            }
        }

        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant src: parallel_surface
            property int mode: phereo.mode3D.activeMode
            property variant mask: Canvas {
                property bool _vert: phereo.mode3D.activeMode === 4 || phereo.mode3D.activeMode === 5
                width: _vert ? 1 : src.width / 2 * Screen.devicePixelRatio;
                height: _vert ? src.height * Screen.devicePixelRatio : 1;
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    if (!width || !height)
                        return;
                    var ctx = getContext("2d");
                    var img = ctx.createImageData(width, height);
                    var val = 0;
                    for (var i = 0; i < img.data.length; i += 4) {
                        val = val ? 0 : 255;
                        img.data[i+0] = val;
                        img.data[i+1] = val;
                        img.data[i+2] = val;
                        img.data[i+3] = 255;
                    }
                    ctx.drawImage(img, 0, 0);
                }
            }
            vertexShader: "
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 coord;
void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}"
            fragmentShader: "
varying highp vec2 coord;
uniform int mode;
uniform sampler2D src;
uniform sampler2D mask;
uniform lowp float qt_Opacity;

void main(void) {
    highp vec2 coordM = mod(coord, vec2(0.5, 1.0));
    if (mode == 0) { // LeftView
        lowp vec4 l = texture2D(src, coordM);
        gl_FragColor = l * qt_Opacity;

    } else if (mode == 1) { // RightView
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        gl_FragColor = r * qt_Opacity;

    } else if (mode == 2) { // ColumnsInterleaved
        lowp vec4 l = texture2D(src, coordM);
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, vec2(coordM.x * 2.0, 0.0)).r;
        if (m > 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 3) { // ColumnsInterleavedInv
        lowp vec4 l = texture2D(src, coordM);
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, vec2(coordM.x * 2.0, 0.0)).r;
        if (m > 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 4) { // RowsInterleaved
        lowp vec4 l = texture2D(src, coordM);
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, vec2(0.0, coordM.y)).r;
        if (m > 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 5) { // RowsInterleavedInv
        lowp vec4 l = texture2D(src, coordM);
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, vec2(0.0, coordM.y)).r;
        if (m > 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 6) { // ParallelHalfView
        highp vec2 coord2 = vec2(coordM.x * 2.0, coordM.y);
        lowp vec4 l = texture2D(src, coord2);
        lowp vec4 r = texture2D(src, coord2);
        if (coord2.x < 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 7) { // ParallelFullView
        highp vec2 coord2 = vec2(coordM.x * 2.0, coordM.y * 2.0) - vec2(0.0, 0.5);
        lowp vec4 l = texture2D(src, coord2);
        lowp vec4 r = texture2D(src, coord2);
        if (coord2.y < 0.0 || coord.y > 0.75)
            gl_FragColor = vec4(0);
        else if (coord2.x < 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 8) { // CrossHalfView
        highp vec2 coord2 = vec2(coordM.x * 2.0, coordM.y);
        lowp vec4 l = texture2D(src, coord2 - vec2(0.5, 0.0));
        lowp vec4 r = texture2D(src, coord2 + vec2(0.5, 0.0));
        if (coord2.x < 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 9) { // CrossFullView
        highp vec2 coord2 = vec2(coordM.x * 2.0, coordM.y * 2.0) - vec2(0.0, 0.5);
        lowp vec4 l = texture2D(src, coord2 - vec2(0.5, 0.0));
        lowp vec4 r = texture2D(src, coord2 + vec2(0.5, 0.0));
        if (coord2.y < 0.0 || coord.y > 0.75)
            gl_FragColor = vec4(0);
        else if (coord2.x < 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 10) { // AnaglyphMonochrome
        lowp vec4 l = texture2D(src, coordM);
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        lowp mat4 monoL = mat4(
            +0.299, +0.000, +0.000, 0.0,
            +0.587, +0.000, +0.000, 0.0,
            +0.114, +0.000, +0.000, 0.0,
            +0.000, +0.000, +0.000, 1.0
        );
        lowp mat4 monoR = mat4(
            +0.000, +0.299, +0.299, 0.0,
            +0.000, +0.587, +0.587, 0.0,
            +0.000, +0.114, +0.114, 0.0,
            +0.000, +0.000, +0.000, 1.0
        );
        gl_FragColor = monoL * l + monoR * r;

    } else if (mode == 11) { // AnaglyphDubois
        lowp vec4 l = texture2D(src, coordM);
        lowp vec4 r = texture2D(src, coordM + vec2(0.5, 0.0));
        lowp mat4 duboisL = mat4(
            +0.456, -0.040, -0.015, 0.0,
            +0.500, -0.038, -0.021, 0.0,
            +0.176, -0.016, -0.005, 0.0,
            +0.000, +0.000, +0.000, 1.0
        );
        lowp mat4 duboisR = mat4(
            -0.043, +0.378, -0.072, 0.0,
            -0.088, +0.734, -0.113, 0.0,
            -0.002, -0.018, +1.226, 0.0,
            +0.000, +0.000, +0.000, 1.0
        );
        gl_FragColor = duboisL * l + duboisR * r;

    } else {
        gl_FragColor = vec4(0); // Not supported
    }
}"
        }
    }

    QtLabsSettings.Settings {
        property alias disableCursor: phereo.disableCursor
        property alias mode3D_portraitMode: mode3D.portraitMode
        property alias mode3D_landscapeMode: mode3D.landscapeMode
        property alias mode3D_portraitModeAlt: mode3D.portraitModeAlt
        property alias mode3D_landscapeModeAlt: mode3D.landscapeModeAlt
    }

    Component.onCompleted: phereo.init()
}
