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
    AboutPage.qml \
    AboutPage.qml \
    AboutPagePopup.qml \
    CalculatorPage.qml \
    DailyLogPage.qml \
    SettingsPage.qml \
    StatsPage.qml \
    StatsPage.qml \
    StyledButton.qml \
    android/AndroidManifest.xml \
    main.qml \
    page/SettingsPage.qml \
    page/StatsPage.qml \
    qml/main.qml \
    qml/pages/AboutPage.qml \
    qml/pages/AboutPagePopup.qml \
    qml/pages/CalculatorPage.qml \
    qml/pages/DailyLogPage.qml \
    qml/pages/FoodPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/StatsPage.qml
