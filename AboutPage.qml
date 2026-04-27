import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        // Кнопка Назад
        StyledButton {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: window.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: backClicked()
        }

        // Логотип / Заголовок
        Label {
            text: "🏥 HealthMate"
            font.pixelSize: 32
            font.bold: true
            color: window.accentColor
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Ваш персональный трекер питания"
            font.pixelSize: 14
            color: window.textSecondaryColor
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: window.borderColor
        }

        // Версия
        Label {
            text: "Версия"
            color: window.textSecondaryColor
        }
        Label {
            text: "0.6.0"
            font.pixelSize: 18
            font.bold: true
            color: window.textColor
        }

        // Описание
        Label {
            text: "О приложении"
            color: window.textSecondaryColor
            font.bold: true
        }
        Label {
            text: "HealthMate помогает отслеживать калории, белки, жиры и углеводы.
Основано на научной формуле Миффлина-Сан Жеора.

Кроссплатформенное приложение на Qt 6 (C++ + QML)."
            color: window.textColor
            wrapMode: Text.WordWrap
        }

        // Технологии
        Label {
            text: "Технологии"
            color: window.textSecondaryColor
            font.bold: true
        }
        Label {
            text: "• C++17\n• Qt 6.11\n• QML\n• SQLite"
            color: window.textColor
            font.family: "Consolas"
        }

        // Автор
        Label {
            text: "Разработчик"
            color: window.textSecondaryColor
            font.bold: true
        }
        Label {
            text: "MrBashev"
            color: window.accentColor
        }

        // GitHub
        Label {
            text: "GitHub"
            color: window.textSecondaryColor
            font.bold: true
        }
        Label {
            text: "github.com/ТВОЙ_НИК/HealthMate"
            color: window.accentColor
            font.pixelSize: 12
        }

        // Лицензия
        Label {
            text: "Лицензия"
            color: window.textSecondaryColor
            font.bold: true
        }
        Label {
            text: "MIT License"
            color: window.textColor
        }

        Item { Layout.fillHeight: true }

        // Копирайт
        Label {
            text: "© 2025 HealthMate"
            color: window.textSecondaryColor
            font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
        }
    }
}