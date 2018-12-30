#ifndef TOOLBOX_H
#define TOOLBOX_H

#include <QObject>
#include <QRegularExpression>
#include <QNetworkAccessManager>

class Toolbox : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool hasWritePermissions READ hasWritePermissions CONSTANT)

public:
    explicit Toolbox(QNetworkAccessManager & nam, QObject *parent = nullptr);

public slots:
    bool hasWritePermissions();
    QString md5(QString txt);
    QString reformatText(QString txt);
    void download(QString imgurl, QString imgid);

private:
    QNetworkAccessManager & m_nam;
    QRegularExpression regexpURL;
};

#endif // TOOLBOX_H
