import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: dialog
    title: "О приложении"
    modal: true
    anchors.centerIn: parent
    padding: 20
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    // Фон под тему
    background: Rectangle {
        color: window.bgColor
        radius: 12
        border.color: window.borderColor
        border.width: 1
    }

    // Контент
    contentItem: ColumnLayout {
        spacing: 16
        Layout.preferredWidth: 300

        // Логотип/Заголовок
        Label {
            text: "🏥 HealthMate"
            font.pixelSize: 24
            font.bold: true
            color: window.accentColor
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Ваш персональный трекер питания"
            font.pixelSize: 12
            color: window.textSecondaryColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
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
            font.pixelSize: 11
        }
        Label {
            text: "0.7.5"
            font.pixelSize: 16
            font.bold: true
            color: window.textColor
        }

        // Описание
        Label {
            text: "О приложении"
            color: window.textSecondaryColor
            font.pixelSize: 11
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
            font.pixelSize: 11
            font.bold: true
        }
        Label {
            text: "• C++17\n• Qt 6.11\n• QML\n• SQLite"
            color: window.textColor
            font.family: "Consolas"
            font.pixelSize: 11
        }

        // Разработчик
        Label {
            text: "Разработчик"
            color: window.textSecondaryColor
            font.pixelSize: 11
            font.bold: true
        }
        Label {
            text: "MrBashev"
            color: window.accentColor
        }

        // Копирайт
        Label {
            text: "© 2026 HealthMate"
            color: window.textSecondaryColor
            font.pixelSize: 10
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Кнопка Закрыть
    footer: Button {
        text: "Закрыть"
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        background: Rectangle {
            color: window.accentColor
            radius: 8
        }
        contentItem: Text {
            text: parent.text
            color: window.accentTextColor
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
        }
        onClicked: dialog.close()
    }
}