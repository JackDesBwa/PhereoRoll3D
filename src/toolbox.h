#ifndef TOOLBOX_H
#define TOOLBOX_H

#include <QObject>
#include <QRegularExpression>
#include <QNetworkAccessManager>

class Toolbox : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool hasWritePermissions READ hasWritePermissions CONSTANT)
    Q_PROPERTY(QString lastUri READ lastUri NOTIFY uriReceived)

public:
    explicit Toolbox(QNetworkAccessManager & nam, QObject *parent = nullptr);
    void setUri(QString uri);

signals:
    void uriReceived(QString uri);
    void downloadEnd(bool success, QString path="");

public slots:
    bool hasWritePermissions();
    QString md5(QString txt);
    QString reformatText(QString txt);
    void download(QString imgurl, QString imgid);
    QString lastUri();

private:
    QNetworkAccessManager & m_nam;
    QRegularExpression regexpURL;
    QString m_lastUri;
};

#endif // TOOLBOX_H
