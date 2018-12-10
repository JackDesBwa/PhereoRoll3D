import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 711
    height: 400
    title: qsTr("Phereo unofficial")

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

        layer.enabled: parallel_surface.width == 1280
        layer.effect: ShaderEffect {
            property variant src: parallel_surface
            property variant mask: Image { source: "qrc:/mask.png" }
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
uniform sampler2D src;
uniform sampler2D mask;
uniform lowp float qt_Opacity;

void main(void) {
    lowp vec4 l = texture2D(src, coord);
    lowp vec4 r = texture2D(src, coord+vec2(0.5,0));
    lowp float m = texture2D(mask, coord*2.0).r;
    if (m > 0.5)
      gl_FragColor = l * qt_Opacity;
    else
      gl_FragColor = r * qt_Opacity;
}"
        }
    }

    Component.onCompleted: phereo.showList()
}
