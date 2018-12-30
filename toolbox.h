#ifndef TOOLBOX_H
#define TOOLBOX_H

#include <QObject>

class Toolbox : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool hasWritePermissions READ hasWritePermissions CONSTANT)

public:
    explicit Toolbox(QObject *parent = nullptr);

public slots:
    bool hasWritePermissions();
    QString md5(QString txt);
};

#endif // TOOLBOX_H
