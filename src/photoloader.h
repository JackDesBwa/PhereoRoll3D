#ifndef PHOTOLOADER_H
#define PHOTOLOADER_H

#include <QObject>
#include "photolist.h"

class PhotoLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject * list READ list CONSTANT)
public:
    explicit PhotoLoader(QObject *parent = nullptr);
    QObject * list() { return &m_pl; }

private:
    PhotoList m_pl;
};

#endif // PHOTOLOADER_H
