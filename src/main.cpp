#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "httpcache.h"
#include "toolbox.h"

int main(int argc, char *argv[]) {
    qputenv("QT_ANDROID_VOLUME_KEYS", "1");

    QGuiApplication app(argc, argv);
    app.setOrganizationName("DesBwa");
    app.setOrganizationDomain("desbwa.org");
    app.setApplicationName("PhereoRoll3D");
    app.setApplicationVersion("1.0");

    QQmlApplicationEngine engine;
    engine.setNetworkAccessManagerFactory(new HttpCache_NAMF);
    Toolbox toolbox(*engine.networkAccessManager(), nullptr);
    engine.rootContext()->setContextProperty("toolbox", &toolbox);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
