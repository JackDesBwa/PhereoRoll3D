import QtQuick 2.9
import QtQuick.Window 2.2
import Qt.labs.settings 1.0 as QtLabsSettings

Window {
    id: win
    visible: true
    width: 640
    height: 336
    title: qsTr("Phereo unofficial")
    color: "black"

    ListModel {
        id: photosList
    }

    QtObject {
       id: phereo
       property string category
       property string category_url
       property int nbImagesMax: 0
       property int selection: 0
       property var _photo: photosList.get(selection)
       property var photo: _photo ? _photo : {
               imgid: 0,
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
           property int portraitModeAlt: rightView
           property int landscapeModeAlt: anaglyphDubois
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
       function loadNext() {
           var xhr = new XMLHttpRequest();
           xhr.onreadystatechange = function() {
               if (xhr.readyState === XMLHttpRequest.DONE) {
                   var res = JSON.parse(xhr.responseText);
                   for (var i in res["assets"]) {
                       var photo = res["assets"][i];
                       photosList.append({
                         imgid: photo.id,
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
           if (photosList.count == 0)
               loadCategory(0);
           loader.setSource("qrc:/PhotosGrid.qml", {"phereo": phereo});
       }
       function showPhoto(sel) {
           selection = sel;
           loader.setSource("qrc:/PhotosShow.qml", {"phereo": phereo});
       }
       function showSettings() {
           loader.setSource("qrc:/Settings.qml", {"phereo": phereo});
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
    }

    Item {
        id: parallel_surface
        width: parent.width * 2
        height: parent.height

        Row {
            Image {
                width: parallel_surface.width/2
                height: parallel_surface.height
                source: "qrc:/bgl.png"
                fillMode: Image.Tile
            }
            Image {
                width: parallel_surface.width/2
                height: parallel_surface.height
                source: "qrc:/bgr.png"
                fillMode: Image.Tile
            }
        }

        Loader {
            id: loader
            anchors.fill: parent
        }

        MouseArea {
            anchors.right: parent.horizontalCenter
            anchors.top: parent.top
            width: 40
            height: 40
            onClicked: phereo.mode3D.modeAlt = !phereo.mode3D.modeAlt
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
                    var ctx = getContext("2d");
                    var img = ctx.createImageData(width, height)
                    ctx.fillStyle = "black";
                    ctx.fillRect(0, 0, width, height);
                    ctx.fillStyle = "white";
                    if (_vert)
                        for (var i = 0; i < height; i += 2)
                            ctx.fillRect(0, i, width, 1);
                    else
                        for (var i = 0; i < width; i += 2)
                            ctx.fillRect(i, 0, 1, height);
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
    if (mode == 0) { // LeftView
        lowp vec4 l = texture2D(src, coord);
        gl_FragColor = l * qt_Opacity;

    } else if (mode == 1) { // RightView
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
        gl_FragColor = r * qt_Opacity;

    } else if (mode == 2) { // ColumnsInterleaved
        lowp vec4 l = texture2D(src, coord);
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, coord * 2.0).r;
        if (m > 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 3) { // ColumnsInterleavedInv
        lowp vec4 l = texture2D(src, coord);
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, coord * 2.0).r;
        if (m > 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 4) { // RowsInterleaved
        lowp vec4 l = texture2D(src, coord);
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, coord).r;
        if (m > 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 5) { // RowsInterleavedInv
        lowp vec4 l = texture2D(src, coord);
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
        lowp float m = texture2D(mask, coord).r;
        if (m > 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 6) { // ParallelHalfView
        lowp vec2 coord2 = vec2(coord.x * 2.0, coord.y);
        lowp vec4 l = texture2D(src, coord2);
        lowp vec4 r = texture2D(src, coord2);
        if (coord2.x < 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 7) { // ParallelFullView
        lowp vec2 coord2 = vec2(coord.x * 2.0, coord.y * 2.0) - vec2(0.0, 0.5);
        lowp vec4 l = texture2D(src, coord2);
        lowp vec4 r = texture2D(src, coord2);
        if (coord2.y < 0.0 || coord.y > 0.75)
            gl_FragColor = vec4(0);
        else if (coord2.x < 0.5)
            gl_FragColor = l * qt_Opacity;
        else
            gl_FragColor = r * qt_Opacity;

    } else if (mode == 8) { // CrossHalfView
        lowp vec2 coord2 = vec2(coord.x * 2.0, coord.y);
        lowp vec4 l = texture2D(src, coord2 - vec2(0.5, 0.0));
        lowp vec4 r = texture2D(src, coord2 + vec2(0.5, 0.0));
        if (coord2.x < 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 9) { // CrossFullView
        lowp vec2 coord2 = vec2(coord.x * 2.0, coord.y * 2.0) - vec2(0.0, 0.5);
        lowp vec4 l = texture2D(src, coord2 - vec2(0.5, 0.0));
        lowp vec4 r = texture2D(src, coord2 + vec2(0.5, 0.0));
        if (coord2.y < 0.0 || coord.y > 0.75)
            gl_FragColor = vec4(0);
        else if (coord2.x < 0.5)
            gl_FragColor = r * qt_Opacity;
        else
            gl_FragColor = l * qt_Opacity;

    } else if (mode == 10) { // AnaglyphMonochrome
        lowp vec4 l = texture2D(src, coord);
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
        lowp mat4 duboisL = mat4(
            +0.299, +0.000, +0.000, 0.0,
            +0.587, +0.000, +0.000, 0.0,
            +0.114, +0.000, +0.000, 0.0,
            +0.000, +0.000, +0.000, 1.0
        );
        lowp mat4 duboisR = mat4(
            +0.000, +0.299, +0.299, 0.0,
            +0.000, +0.587, +0.587, 0.0,
            +0.000, +0.114, +0.114, 0.0,
            +0.000, +0.000, +0.000, 1.0
        );
        gl_FragColor = duboisL * l + duboisR * r;

    } else if (mode == 11) { // AnaglyphDubois
        lowp vec4 l = texture2D(src, coord);
        lowp vec4 r = texture2D(src, coord + vec2(0.5, 0.0));
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
        property alias mode3D_portraitMode: mode3D.portraitMode
        property alias mode3D_landscapeMode: mode3D.landscapeMode
        property alias mode3D_portraitModeAlt: mode3D.portraitModeAlt
        property alias mode3D_landscapeModeAlt: mode3D.landscapeModeAlt
    }

    Component.onCompleted: phereo.showList()
}
