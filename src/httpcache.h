#ifndef HTTPCACHE_H
#define HTTPCACHE_H

#include <QNetworkAccessManager>
#include <QQmlNetworkAccessManagerFactory>

class HttpCache_NAM : public QNetworkAccessManager {
public:
    using QNetworkAccessManager::QNetworkAccessManager;
    QNetworkReply * createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &originalReq, QIODevice *outgoingData = nullptr) override;
private:
    QByteArray userAgent();
    QByteArray m_userAgent;
};

class HttpCache_NAMF : public QQmlNetworkAccessManagerFactory {
public:
    using QQmlNetworkAccessManagerFactory::QQmlNetworkAccessManagerFactory;
    QNetworkAccessManager * create(QObject *parent) override;
};

#endif // HTTPCACHE_H
