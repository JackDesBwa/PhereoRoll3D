#include "photoloader.h"

PhotoLoader::PhotoLoader(QObject *parent) : QObject(parent) {
    m_pl.add({
               {"qrc:/pics/mag.png"},
               {"qrc:/pics/gear.png"},
               {"qrc:/pics/web.png"},
           });
}
