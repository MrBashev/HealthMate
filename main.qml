import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
        visible: true
        width: 360
        height: 640
        title: qsTr("🏥 HealthMate")

        // ← ДОБАВЬ ЭТО: Свойство темы
        property string appTheme: "dark"  // "dark", "light", "system"

        // === ЦЕНТРАЛЬНАЯ ПАЛИТРА ===
            property color bgColor: appTheme === "dark" ? "#1a1a2e" : "#f5f5f5"
            property color surfaceColor: appTheme === "dark" ? "#16213e" : "#ffffff"
            property color cardColor: appTheme === "dark" ? "#2d2d44" : "#e0e0e0"
            property color textColor: appTheme === "dark" ? "#ffffff" : "#000000"
            property color textSecondaryColor: appTheme === "dark" ? "#aaaaaa" : "#666666"
            property color accentColor: appTheme === "dark" ? "#00d9ff" : "#0066cc"
            property color accentTextColor: appTheme === "dark" ? "#000000" : "#ffffff"
            property color successColor: appTheme === "dark" ? "#3d8b37" : "#4caf50"
            property color warningColor: appTheme === "dark" ? "#ff9800" : "#ff9800"
            property color errorColor: appTheme === "dark" ? "#8b3737" : "#f44336"
            property color borderColor: appTheme === "dark" ? "#333333" : "#cccccc"

            // Фон окна
            color: bgColor

    property string selectedDate: new Date().toISOString().split('T')[0]
    property int currentPage: 0

    header: ToolBar {
        contentItem: Label {
            text: "HealthMate v0.6"
            font.bold: true
            color: window.textColor
        }
         background: Rectangle {
            color: window.surfaceColor
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: currentPage

        // Страница 0: Главное меню
        Page {
            background: Rectangle { color: window.bgColor }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Label {
                    text: "Добро пожаловать!"
                    font.pixelSize: 22
                    font.bold: true
                    color: window.accentColor
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Сегодня: " + window.selectedDate
                    color: window.accentColor
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledButton {
                    text: "📊 Калькулятор"
                    Layout.fillWidth: true
                    background: Rectangle {
                            color: window.cardColor
                            radius: 8
                        }
                    contentItem: Text {
                            text: parent.text
                            color: window.textColor
                            horizontalAlignment: Text.AlignHCenter
                        }
                    onClicked: currentPage = 1
                }

                StyledButton {
                    text: "🍎 Дневник"
                    Layout.fillWidth: true
                    background: Rectangle {
                            color: window.cardColor
                            radius: 8
                        }
                    contentItem: Text {
                            text: parent.text
                            color: window.textColor
                            horizontalAlignment: Text.AlignHCenter
                        }
                    onClicked: currentPage = 2
                }

                StyledButton {
                    text: "📈 Статистика"
                    Layout.fillWidth: true
                    background: Rectangle {
                            color: window.cardColor
                            radius: 8
                        }
                    contentItem: Text {
                            text: parent.text
                            color: window.textColor
                            horizontalAlignment: Text.AlignHCenter
                        }
                    onClicked: currentPage = 3
                }

                StyledButton {
                    text: "⚙️ Настройки"
                    Layout.fillWidth: true
                    background: Rectangle {
                            color: window.cardColor
                            radius: 8
                        }
                    contentItem: Text {
                            text: parent.text
                            color: window.textColor
                            horizontalAlignment: Text.AlignHCenter
                        }
                    onClicked: currentPage = 4  // Новая страница
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Страница 1: Калькулятор
        Page {
            background: Rectangle { color: window.bgColor }

            Loader {
                anchors.fill: parent
                source: "CalculatorPage.qml"
                active: currentPage === 1
                onLoaded: item.backClicked.connect(() => currentPage = 0)
            }
        }

        // Страница 2: Дневник
        Page {
            background: Rectangle { color: window.bgColor }

            Loader {
                anchors.fill: parent
                source: "DailyLogPage.qml"
                active: currentPage === 2
                onLoaded: {
                    item.backClicked.connect(() => currentPage = 0)
                    item.currentDay = window.selectedDate
                }
            }
        }

        // Страница 3: Статистика
        Page {
            background: Rectangle { color: window.bgColor }

            Loader {
                anchors.fill: parent
                source: "StatsPage.qml"
                active: currentPage === 3
                onLoaded: item.backClicked.connect(() => currentPage = 0)
            }
        }

        // Страница 4: Настройки
        Page {
            background: Rectangle { color: window.bgColor }

            Loader {
                anchors.fill: parent
                source: "SettingsPage.qml"
                active: currentPage === 4
                onLoaded: item.backClicked.connect(() => currentPage = 0)
            }
        }
    }

    footer: TabBar {
        currentIndex: currentPage
        background: Rectangle { color: window.surfaceColor }
        TabButton { text: "🏠"; onClicked: currentPage = 0 }
        TabButton { text: "📊"; onClicked: currentPage = 1 }
        TabButton { text: "🍎"; onClicked: currentPage = 2 }
        TabButton { text: "📈"; onClicked: currentPage = 3 }
        TabButton { text: "⚙️"; onClicked: currentPage = 4 }
    }
}