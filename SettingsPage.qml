import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Кнопка Назад
        Button {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle {  color: window.theme[window.appTheme].card; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: window.theme[window.appTheme].text
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: backClicked()
        }

        // Заголовок
        Label {
            text: "⚙️ Настройки"
            font.pixelSize: 24
            font.bold: true
            color: window.theme[window.appTheme].accent
        }

        // Переключатель темы
        Label {
            text: "🌓 Тема оформления"
            font.pixelSize: 16
            color: window.theme[window.appTheme].text
        }

        RowLayout {
            spacing: 8

            Button {
                text: "🌙 Тёмная"
                Layout.fillWidth: true
                background: Rectangle {
                    color: window.appTheme === "dark" ? window.theme[window.appTheme].accent : window.theme[window.appTheme].card
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: window.appTheme === "dark" ? "black" : "black"
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: window.appTheme = "dark"
            }

            Button {
                text: "☀️ Светлая"
                Layout.fillWidth: true
                background: Rectangle {
                    color: window.appTheme === "light" ? window.theme[window.appTheme].accent : window.theme[window.appTheme].card
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: window.appTheme = "light"
            }
        }

        // Версия приложения
        Label {
            text: "Версия: 0.6"
            color: window.theme[window.appTheme].textSecondary
        }

        Item { Layout.fillHeight: true }
    }
}
