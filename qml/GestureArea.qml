import QtQuick 2.0

Item {
    id: component

    property real borderWidth: 50 * adjScr
    property real borderHeight: 50 * adjScr
    property real gestureThreshold: 5 * adjScr

    signal canceled();

    signal leftClicked();
    signal leftDuoPressed();
    signal leftProportionalStart();
    signal leftProportionalUpdate(real vv, real vh);
    signal leftProportionalStop(real vv, real vh, bool out);

    signal topClicked();
    signal topDuoPressed();
    signal topProportionalStart();
    signal topProportionalUpdate(real vv, real vh);
    signal topProportionalStop(real vv, real vh, bool out);

    signal rightClicked();
    signal rightDuoPressed();
    signal rightProportionalStart();
    signal rightProportionalUpdate(real vv, real vh);
    signal rightProportionalStop(real vv, real vh, bool out);

    signal bottomClicked();
    signal bottomDuoPressed();
    signal bottomProportionalStart();
    signal bottomProportionalUpdate(real vv, real vh);
    signal bottomProportionalStop(real vv, real vh, bool out);

    signal swipedUp(real sqDist, real angle);
    signal swipedDown(real sqDist, real angle);
    signal swipedLeft(real sqDist, real angle);
    signal swipedRight(real sqDist, real angle);

    signal centerClicked();
    signal centerDuoPressed();

    signal pitchStart();
    signal pitchUpdate(real v, real dx, real dy);
    signal pitchStop();

    MultiPointTouchArea {
        anchors.fill: parent

        property bool lMove: false
        property bool tMove: false
        property bool rMove: false
        property bool bMove: false
        property bool lDuo: false
        property bool tDuo: false
        property bool rDuo: false
        property bool bDuo: false
        property bool cDuo: false
        property bool pitchMove: false

        maximumTouchPoints: 2

        touchPoints: [
            TouchPoint { id: point1 },
            TouchPoint { id: point2 }
        ]

        onCanceled: {
            lMove = false;
            tMove = false;
            rMove = false;
            bMove = false;
            lDuo = false;
            tDuo = false;
            rDuo = false;
            bDuo = false;
            cDuo = false;
            pitchMove = false;
            component.canceled();
        }

        onTouchUpdated: {
            var moved;
            if (touchPoints.length === 2) {
                if (lMove || rMove || tMove || bMove)
                    component.canceled();
                lMove = false;
                tMove = false;
                rMove = false;
                bMove = false;

                moved = (Math.pow(touchPoints[0].x - touchPoints[0].startX, 2) + Math.pow(touchPoints[0].y - touchPoints[0].startY, 2) > Math.pow(gestureThreshold, 2)) ||
                        (Math.pow(touchPoints[1].x - touchPoints[1].startX, 2) + Math.pow(touchPoints[1].y - touchPoints[1].startY, 2) > Math.pow(gestureThreshold, 2));
                if (!pitchMove && moved && !lDuo && !rDuo && !tDuo && !bDuo) {
                    pitchMove = true;
                    component.pitchStart();
                }
                if (pitchMove) {
                    var startDist = Math.sqrt(Math.pow(touchPoints[0].startX - touchPoints[1].startX, 2) + Math.pow(touchPoints[0].startY - touchPoints[1].startY, 2));
                    var dist = Math.sqrt(Math.pow(touchPoints[0].x - touchPoints[1].x, 2) + Math.pow(touchPoints[0].y - touchPoints[1].y, 2));
                    var dx = (touchPoints[0].x + touchPoints[1].x - touchPoints[0].startX - touchPoints[1].startX)/2
                    var dy = (touchPoints[0].y + touchPoints[1].y - touchPoints[0].startY - touchPoints[1].startY)/2
                    component.pitchUpdate(dist/startDist, dx, dy);
                } else {
                    if (touchPoints[0].startX < component.borderWidth && touchPoints[1].startX < component.borderWidth) {
                        if (!lDuo) {
                            lDuo = true;
                            component.leftDuoPressed();
                        }
                    } else if (touchPoints[0].startX > width - component.borderWidth && touchPoints[1].startX > width - component.borderWidth) {
                        if (!rDuo) {
                            rDuo = true;
                            component.rightDuoPressed();
                        }
                    } else if (touchPoints[0].startY < component.borderHeight && touchPoints[1].startY < component.borderHeight) {
                        if (!tDuo) {
                            tDuo = true;
                            component.topDuoPressed();
                        }
                    } else if (touchPoints[0].startY > height - component.borderHeight && touchPoints[1].startY > height - component.borderHeight) {
                        if (!bDuo) {
                            bDuo = true;
                            component.bottomDuoPressed();
                        }
                    }
                }

            } else for (var i in touchPoints) {
                var x = touchPoints[i].x;
                var y = touchPoints[i].y;
                var sx = touchPoints[i].startX;
                var sy = touchPoints[i].startY;
                var vv, vh;
                if (sx !== 0 && sy !== 0) {
                    moved = (Math.pow(x - sx, 2) + Math.pow(y - sy, 2) > Math.pow(gestureThreshold, 2));
                    if (sx < component.borderWidth) {
                        // Touch started left
                        if (!lMove && moved) {
                            lMove = true;
                            component.leftProportionalStart();
                        }
                        if (lMove) {
                            if (y > sy)
                                vv = (y - sy) / (height - sy);
                            else
                                vv = (y - sy) / sy;
                            vh = (width - x) / width;
                            component.leftProportionalUpdate(vv, vh);
                        }
                    } else if (sx > width - component.borderWidth) {
                        // Touch started right
                        if (!rMove && moved) {
                            rMove = true;
                            component.rightProportionalStart();
                        }
                        if (rMove) {
                            if (y > sy)
                                vv = (y - sy) / (height - sy);
                            else
                                vv = (y - sy) / sy;
                            vh = x / width;
                            component.rightProportionalUpdate(vv, vh);
                        }
                    } else if (sy < component.borderHeight) {
                        // Touch started top
                        if (!tMove && moved) {
                            tMove = true;
                            component.topProportionalStart();
                        }
                        if (tMove) {
                            vv = (height - y) / height;
                            if (x > sx)
                                vh = (x - sx) / (width - sx);
                            else
                                vh = (x - sx) / sx;
                            component.topProportionalUpdate(vv, vh);
                        }
                    } else if (sy > height - component.borderHeight) {
                        // Touch started bottom
                        if (!bMove && moved) {
                            bMove = true;
                            component.bottomProportionalStart();
                        }
                        if (bMove) {
                            vv = y / height;
                            if (x > sx)
                                vh = (x - sx) / (width - sx);
                            else
                                vh = (x - sx) / sx;
                            component.bottomProportionalUpdate(vv, vh);
                        }
                    }
                }
            }
        }
        onReleased: {
            for (var i in touchPoints) {
                var x = touchPoints[i].x;
                var y = touchPoints[i].y;
                var sx = touchPoints[i].startX;
                var sy = touchPoints[i].startY;
                var sqDist = Math.pow(x - sx, 2) + Math.pow(y - sy, 2);
                var moved = (sqDist > Math.pow(gestureThreshold, 2));
                var vv, vh;
                if (sx === 0 || sy === 0) {
                    sx = x;
                    sy = y;
                    moved = false;
                }
                if (sx < component.borderWidth) {
                    // Touch started left
                    if (lMove) {
                        lMove = false;
                        if (y > sy)
                            vv = (y - sy) / (height - sy);
                        else
                            vv = (y - sy) / sy;
                        vh = (width - x) / width;
                        component.leftProportionalStop(vv, vh, x > component.borderWidth);
                    }
                    if (!moved && !lDuo)
                        component.leftClicked();
                } else if (sx > width - component.borderWidth) {
                    // Touch started right
                    if (rMove) {
                        rMove = false;
                        if (y > sy)
                            vv = (y - sy) / (height - sy);
                        else
                            vv = (y - sy) / sy;
                        vh = x / width;
                        component.rightProportionalStop(vv, vh, x < width - component.borderWidth);
                    }
                    if (!moved && !rDuo)
                        component.rightClicked();
                } else if (sy < component.borderHeight) {
                    // Touch started top
                    if (tMove) {
                        tMove = false;
                        vv = (height - y) / height;
                        if (x > sx)
                            vh = (x - sx) / (width - sx);
                        else
                            vh = (x - sx) / sx;
                        component.topProportionalStop(vv, vh, y > component.borderHeight);
                    }
                    if (!moved && !tDuo)
                        component.topClicked();
                } else if (sy > height - component.borderHeight) {
                    // Touch started bottom
                    if (bMove) {
                        bMove = false;
                        vv = y / height;
                        if (x > sx)
                            vh = (x - sx) / (width - sx);
                        else
                            vh = (x - sx) / sx;
                        component.bottomProportionalStop(vv, vh, y < height - component.borderHeight);
                    }
                    if (!moved && !bDuo)
                        component.bottomClicked();
                } else {
                    if (!moved && !cDuo)
                        component.centerClicked();
                    if (moved && !pitchMove) {
                        var angle = Math.atan2(y-sy, x-sx) * 180 / Math.PI;
                        if (angle < -135 || angle > 135)
                            swipedLeft(sqDist, angle);
                        else if (angle > -135 && angle < -45)
                            swipedUp(sqDist, angle);
                        else if (angle < 135 && angle > 45)
                            swipedDown(sqDist, angle);
                        else
                            swipedRight(sqDist, angle);
                    }
                }
            }

            var touched = point1.pressed || point2.pressed;
            if (lDuo && !touched) lDuo = false;
            if (rDuo && !touched) rDuo = false;
            if (tDuo && !touched) tDuo = false;
            if (bDuo && !touched) bDuo = false;
            if (cDuo && !touched) cDuo = false;
            if (pitchMove && !touched) {
                pitchMove = false;
                component.pitchStop();
            }
        }
    }
}
