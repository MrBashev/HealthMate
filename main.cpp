#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QGuiApplication>
#include "HealthCore.h"
#include "DataService.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    HealthCore healthCore;
    DataService dataService;

    // Инициализация БД
    if (!dataService.initDatabase()) {
        qWarning() << "Failed to initialize database";
    }

    // 🔥 Запусти cleanTrash() ОДИН РАЗ, потом закомментируй!
    // dataService.cleanTrash();

    // Регистрация C++ объектов для QML
    engine.rootContext()->setContextProperty("HealthCore", &healthCore);
    engine.rootContext()->setContextProperty("DataService", &dataService);

    // Загрузка главного QML-файла (путь должен точно совпадать с .qrc!)
    const QUrl url(QStringLiteral("qrc:/MainPage.qml"));

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