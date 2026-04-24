QT += \
  quick sql


SOURCES += \
        DataService.cpp \
        HealthCore.cpp \
        main.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    qml.qrc

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
    CalculatorPage.qml \
    DailyLogPage.qml \
    StatsPage.qml \
    android/AndroidManifest.xml
