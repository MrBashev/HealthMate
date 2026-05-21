QT += \
  quick sql graphs


SOURCES += \
        DataService.cpp \
        HealthCore.cpp \
        main.cpp

resources.files = MainPage.qml
resources.prefix = /$${TARGET}
RESOURCES += qml.qrc

android {
    PACKAGE_NAME = org.qtproject.example.HealthMate
    VERSION_NAME = 0.7.7
    VERSION_CODE = 7

    # Пути к ключу (адаптируй под себя)
    ANDROID_KEYSTORE_PATH = $$PWD/C:\Users\bashe\source\HealthMate/healthmate.keystore
    ANDROID_KEYSTORE_ALIAS = healthmate
    ANDROID_KEYSTORE_PASS = MrBashev
    ANDROID_KEY_PASS = MrBashev
}

TRANSLATIONS += \
    HealthMate_ru_RU.ts
CONFIG += lrelease
CONFIG += embed_translations

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $$PWD

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Разрешения для Android
ANDROID_PERMISSIONS += \
    android.permission.WRITE_EXTERNAL_STORAGE \
    android.permission.READ_EXTERNAL_STORAGE

# Минимальная версия Android
ANDROID_MIN_SDK_VERSION = 24
ANDROID_TARGET_SDK_VERSION = 33

HEADERS += \
    DataService.h \
    HealthCore.h

DISTFILES += \
    AboutPage.qml \
    CalculatorPage.qml \
    ChartsPage.qml \
    DiaryDetailPage.qml \
    DiaryOverviewPage.qml \
    FoodPage.qml \
    MainPage.qml \
    SettingsPage.qml \
    StatsPage.qml \
    StyledButton.qml


