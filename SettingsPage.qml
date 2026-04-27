import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    background: Rectangle { color: window.bgColor }
    signal backClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        StyledButton {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
            onClicked: backClicked()
        }

        Label {
            text: "⚙️ Настройки"
            font.pixelSize: 24
            font.bold: true
            color: window.accentColor
        }

        Label {
            text: "🌓 Тема оформления"
            font.pixelSize: 16
            color: window.textColor
        }

        RowLayout {
            spacing: 8

            StyledButton {
                text: "🌙 Тёмная"
                Layout.fillWidth: true
                background: Rectangle {
                    color: window.appTheme === "dark" ? window.accentColor : window.cardColor
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: window.appTheme === "dark" ? window.accentTextColor : window.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: window.appTheme = "dark"
            }

            StyledButton {
                text: "☀️ Светлая"
                Layout.fillWidth: true
                background: Rectangle {
                    color: window.appTheme === "light" ? window.accentColor : window.cardColor
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

        Label {
            text: "Версия: 0.6"
            color: window.textSecondaryColor
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: window.borderColor
        }

        StyledButton {
            text: "ℹ️ О приложении"
            Layout.fillWidth: true
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: window.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: {
                // Открываем AboutPage
                aboutPageLoader.active = true
                aboutPageLoader.item.open()
            }
        }

        // Загрузчик для AboutPage
        Loader {
            id: aboutPageLoader
            active: false
            sourceComponent: AboutPagePopup {
                onClosed: aboutPageLoader.active = false
            }
        }
        Item { Layout.fillHeight: true }
    }
}