#ifndef TOOLBOX_H
#define TOOLBOX_H

#include <QObject>
#include <QRegularExpression>
#include <QNetworkAccessManager>
#include "photoloader.h"

class Toolbox : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool hasWritePermissions READ hasWritePermissions CONSTANT)
    Q_PROPERTY(QString imgPath READ imgPath NOTIFY imgPathChanged)
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)

    Q_PROPERTY(QString lastUri READ lastUri NOTIFY uriReceived)

    Q_PROPERTY(QObject * photoLoader READ photoLoader CONSTANT)
public:
    explicit Toolbox(QNetworkAccessManager & nam, QObject *parent = nullptr);
    void setUri(QString uri);

signals:
    void uriReceived(QString uri);
    void downloadEnd(bool success, QString path="");
    void imgPathChanged();

public slots:
    bool hasWritePermissions();
    QString md5(QString txt);
    QString reformatText(QString txt);
    void download(QString imgurl, QString imgid);
    QString lastUri();
    void setDownloadId(QString n);
    QString imgPath() { return m_imgPath; }
    QString appVersion() const;
    PhotoLoader * photoLoader() { return &m_photoLoader; }

private:
    QNetworkAccessManager & m_nam;
    QRegularExpression regexpURL;
    QString m_lastUri;
    QString m_imgPath;
    PhotoLoader m_photoLoader;
};

#endif // TOOLBOX_H
