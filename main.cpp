#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QGuiApplication>
#include "HealthCore.h"
#include "DataService.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // 👇 Регистрируем QML типы
    qmlRegisterType(QUrl("qrc:/CalculatorPage.qml"), "HealthMate", 1, 0, "CalculatorPage");
    qmlRegisterType(QUrl("qrc:/DailyLogPage.qml"), "HealthMate", 1, 0, "DailyLogPage");
    qmlRegisterType(QUrl("qrc:/StatsPage.qml"), "HealthMate", 1, 0, "StatsPage");

    QQmlApplicationEngine engine;

    HealthCore healthCore;
    DataService dataService;

    // ← Важно! Инициализируем БД
    if (!dataService.initDatabase()) {
        qWarning() << "Failed to initialize database";
    }

    engine.rootContext()->setContextProperty("HealthCore", &healthCore);
    engine.rootContext()->setContextProperty("DataService", &dataService);

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
        );

    engine.load(url);

    return app.exec();
}