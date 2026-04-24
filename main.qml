import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 360
    height: 640
    title: qsTr("🏥 HealthMate")
    color: "#1a1a2e"

    property string selectedDate: new Date().toISOString().split('T')[0]
    property int currentPage: 0

    header: ToolBar {
        contentItem: Label {
            anchors.centerIn: parent
            text: "HealthMate v0.5"
            font.bold: true
            color: "#ffffff"
        }
        background: Rectangle { color: "#16213e" }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: currentPage

        // Страница 0: Главное меню
        Page {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Label {
                    text: "Добро пожаловать!"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#00d9ff"
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Сегодня: " + window.selectedDate
                    color: "#aaaaaa"
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "📊 Калькулятор"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#2d2d44"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                    onClicked: currentPage = 1
                }

                Button {
                    text: "🍎 Дневник"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#2d2d44"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                    onClicked: currentPage = 2
                }

                Button {
                    text: "📈 Статистика"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#2d2d44"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                    onClicked: currentPage = 3
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Страница 1: Калькулятор
        Page {
            Loader {
                anchors.fill: parent
                source: "CalculatorPage.qml"
                active: currentPage === 1
                onLoaded: item.backClicked.connect(() => currentPage = 0)
            }
        }

        // Страница 2: Дневник
        Page {
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
            Loader {
                anchors.fill: parent
                source: "StatsPage.qml"
                active: currentPage === 3
                onLoaded: item.backClicked.connect(() => currentPage = 0)
            }
        }
    }

    footer: TabBar {
        currentIndex: currentPage
        background: Rectangle { color: "#16213e" }
        TabButton { text: "🏠"; onClicked: currentPage = 0 }
        TabButton { text: "📊"; onClicked: currentPage = 1 }
        TabButton { text: "🍎"; onClicked: currentPage = 2 }
        TabButton { text: "📈"; onClicked: currentPage = 3 }
    }
}