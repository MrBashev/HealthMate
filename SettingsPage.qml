import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()
    property var goals: ({})

    background: Rectangle { color: window.bgColor}

    Component.onCompleted: loadGoals()

    function loadGoals() {
        var today = new Date()
        var dateStr = today.getFullYear() + '-' +
                     String(today.getMonth() + 1).padStart(2, '0') + '-' +
                     String(today.getDate()).padStart(2, '0')
        goals = DataService.getGoals(dateStr)
    }

    function saveGoals() {
        var today = new Date()
        var dateStr = today.getFullYear() + '-' +
                     String(today.getMonth() + 1).padStart(2, '0') + '-' +
                     String(today.getDate()).padStart(2, '0')

        var calories = parseInt(caloriesField.text) || 2000
        var protein = parseFloat(proteinField.text) || 150
        var fat = parseFloat(fatField.text) || 70
        var carbs = parseFloat(carbsField.text) || 250
        var water = parseInt(waterField.text) || 2000

        DataService.saveGoals(dateStr, calories, protein, fat, carbs, water)
        saveLabel.text = "✅ Цели сохранены!"
        saveLabel.visible = true
        timer.start()
    }

    // Простой ColumnLayout без ScrollView
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Button {
            text: "← Назад"
            Layout.fillWidth: true
            Layout.preferredHeight: 40
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

        // Карточка целей
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 320  // Явная высота
            color: window.cardColor
            radius: 12
            border.color: window.borderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Label {
                    text: "🎯 Цели на день"
                    font.bold: true
                    font.pixelSize: 16
                    color: window.accentColor
                }

                // Калории
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "🔥 Калории:"; color: window.textColor; Layout.fillWidth: true }
                    TextField {
                        id: caloriesField
                        text: goals.calories || 2000
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 35
                        color: window.textColor
                        placeholderTextColor: window.textSecondaryColor
                        background: Rectangle { color: window.bgColor; radius: 4 }
                    }
                }

                // Белки
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "🥩 Белки (г):"; color: window.textColor; Layout.fillWidth: true }
                    TextField {
                        id: proteinField
                        text: goals.protein || 150
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 35
                        color: window.textColor
                        placeholderTextColor: window.textSecondaryColor
                        background: Rectangle { color: window.bgColor; radius: 4 }
                    }
                }

                // Жиры
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "🥑 Жиры (г):"; color: window.textColor; Layout.fillWidth: true }
                    TextField {
                        id: fatField
                        text: goals.fat || 70
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 35
                        color: window.textColor
                        placeholderTextColor: window.textSecondaryColor
                        background: Rectangle { color: window.bgColor; radius: 4 }
                    }
                }

                // Углеводы
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "🍞 Углеводы (г):"; color: window.textColor; Layout.fillWidth: true }
                    TextField {
                        id: carbsField
                        text: goals.carbs || 250
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 35
                        color: window.textColor
                        placeholderTextColor: window.textSecondaryColor
                        background: Rectangle { color: window.bgColor; radius: 4 }
                    }
                }
            }
        }

        // Кнопка сохранить
        Button {
            text: "💾 Сохранить цели"
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            background: Rectangle { color: window.accentColor; radius: 8 }
            contentItem: Text { text: parent.text; color: window.accentTextColor; horizontalAlignment: Text.AlignHCenter; font.bold: true }
            onClicked: saveGoals()
        }

        Label {
            id: saveLabel
            text: ""
            color: window.successColor
            font.bold: true
            visible: false
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "🌓 Тема оформления"
            font.pixelSize: 16
            color: window.textColor
        }

        RowLayout {
            spacing: 8
            Button {
                text: "🌙 Тёмная"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                background: Rectangle { color: window.appTheme === "dark" ? window.accentColor : window.cardColor; radius: 8 }
                contentItem: Text { text: parent.text; color: window.appTheme === "dark" ? window.accentTextColor : window.textColor; horizontalAlignment: Text.AlignHCenter }
                onClicked: window.appTheme = "dark"
            }
            Button {
                text: "☀️ Светлая"
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                background: Rectangle { color: window.appTheme === "light" ? window.accentColor : window.cardColor; radius: 8 }
                contentItem: Text { text: parent.text; color: window.appTheme === "light" ? window.accentTextColor : window.textColor; horizontalAlignment: Text.AlignHCenter }
                onClicked: window.appTheme = "light"
            }
        }

        // === КНОПКА "О ПРИЛОЖЕНИИ" ===
        Button {
            text: "ℹ️ О приложении"
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: window.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: {
                aboutLoader.source = "AboutPage.qml"
                // Dialog имеет метод open(), Page — нет
                if (aboutLoader.item && aboutLoader.item.open) {
                    aboutLoader.item.open()
                }
            }
        }

        Label {
            text: "Версия: 0.7.5"
            color: window.textSecondaryColor
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillHeight: true }
    }

    Loader {
        id: aboutLoader
        anchors.centerIn: parent  // ✅ Центрируем, а не fill: parent
        z: 100  // Поверх всего
    }

    Timer {
        id: timer
        interval: 2000
        onTriggered: saveLabel.visible = false
    }
}