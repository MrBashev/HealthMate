import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Это страница редактирования, которая загружается поверх Обзорной
Item {
    id: root
    property string targetDate: ""
    signal backClicked()

    //background: Rectangle { color: window.bgColor }

    // Заблокировано ли добавление (если дата в будущем)
    property bool isFuture: targetDate && isFutureDate(targetDate)

    function isFutureDate(dateStr) {
        if (!dateStr) return false
        var today = new Date()
        var todayStr = today.getFullYear() + '-' +
                       String(today.getMonth() + 1).padStart(2, '0') + '-' +
                       String(today.getDate()).padStart(2, '0')
        return dateStr > todayStr
    }

    // Фон страницы (чтобы перекрывать нижнюю)
    Rectangle {
        anchors.fill: parent
        color: window.bgColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Кнопка Назад
        Button {
            text: "← Назад к обзору"
            Layout.fillWidth: true
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
            onClicked: backClicked()
        }

        // Заголовок
        Label {
            text: "📝 Записи за " + targetDate
            color: window.accentColor
            font.bold: true
            font.pixelSize: 18
        }

        // Предупреждение о будущем
        Label {
            text: "⚠️ Нельзя добавлять записи в будущее!"
            color: "#ff6b6b"
            visible: isFuture
            font.bold: true
            wrapMode: Text.WordWrap
        }

        // === ПОИСК ===
        Label { text: "Поиск продукта:"; color: window.textColor; font.bold: true }
        TextField {
            id: searchField
            placeholderText: "🔍 Введите название..."
            Layout.fillWidth: true
            color: window.textColor
            placeholderTextColor: window.textSecondaryColor
            background: Rectangle { color: window.cardColor; radius: 4 }
            onTextChanged: foodList.model = DataService.searchFoods(searchField.text)
        }

        // Список продуктов
        ListView {
            id: foodList
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            model: DataService.getAllFoods()
            clip: true
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.cardColor : "transparent" }
                contentItem: Text { text: modelData.name; color: window.textColor }
                onClicked: {
                    selectedFoodId = modelData.id
                    selectedFoodName = modelData.name
                }
            }
        }

        // === ДОБАВЛЕНИЕ ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            // === ВЫБОР ТИПА ПРИЁМА ===
            ComboBox {
                id: mealTypeCombo
                Layout.fillWidth: true
                model: ["🌅 Завтрак", "☀️ Обед", "🌙 Ужин", "🥨 Перекус"]
                currentIndex: 1  // Обед по умолчанию
                background: Rectangle { color: window.cardColor; radius: 4; border.color: window.borderColor }
            }
            TextField {
                id: gramsField
                placeholderText: "Граммы"
                Layout.fillWidth: true
                color: window.textColor
                placeholderTextColor: window.textSecondaryColor
                background: Rectangle { color: window.cardColor; radius: 4 }
                inputMethodHints: Qt.ImhDigitsOnly
            }
            Button {
                text: "➕ Добавить"
                Layout.fillWidth: true
                enabled: !isFuture && selectedFoodId > 0
                background: Rectangle {
                    color: enabled ? window.successColor : window.textSecondaryColor
                    radius: 8
                }
                contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
                onClicked: {
                    var grams = parseFloat(gramsField.text)
                    if (grams > 0) {
                        // Маппинг индекса → техническое значение для БД
                        var mealValue = ["breakfast", "lunch", "dinner", "snack"][mealTypeCombo.currentIndex]
                        DataService.addLogEntry(selectedFoodId, grams, mealValue, targetDate)
                        gramsField.text = ""
                        refreshList()
                    }
                }
            }
        }

        Label {
            text: "Выбрано: " + (selectedFoodName || "Ничего")
            color: selectedFoodName ? window.accentColor : window.textSecondaryColor
        }

        // === СПИСОК ЗАПИСЕЙ С ГРУППИРОВКОЙ ===
        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: DataService.getDayLogs(targetDate)
            clip: true
            spacing: 4

            // 🍳 Группировка по типу приёма
            section.property: "meal"
            section.criteria: ViewSection.FullString
            section.delegate: Rectangle {
                width: parent.width
                height: 32
                color: "transparent"
                Label {
                    text: {
                        switch(section) {
                            case "breakfast": return "🌅 Завтрак"
                            case "lunch":     return "☀️ Обед"
                            case "dinner":    return "🌙 Ужин"
                            case "snack":     return "🥨 Перекус"
                            default:          return "📋 " + section
                        }
                    }
                    font.bold: true
                    color: window.accentColor
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    height: 1
                    width: parent.width
                    color: window.borderColor
                    anchors.bottom: parent.bottom
                }
            }

            // 📝 Элемент списка
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.cardColor : "transparent" }
                contentItem: RowLayout {
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name + " (" + modelData.grams + "г)"
                            color: window.textColor
                            font.bold: true
                        }
                        Text {
                            text: "К:" + Math.round(modelData.calories || 0) +
                                  " Б:" + Math.round(modelData.protein || 0) +
                                  " Ж:" + Math.round(modelData.fat || 0) +
                                  " У:" + Math.round(modelData.carbs || 0)
                            color: window.textSecondaryColor
                            font.pixelSize: 11
                        }
                    }
                    Button {
                        text: "❌"
                        background: Rectangle { color: window.errorColor; radius: 4 }
                        contentItem: Text { text: parent.text; color: "white" }
                        onClicked: {
                            // Безопасный доступ к ID (на случай logId или id)
                            var idToDelete = modelData.logId !== undefined ? modelData.logId : modelData.id
                            DataService.deleteLogEntry(idToDelete)
                            refreshList()
                        }
                    }
                }
            }
        }

        // 📭 Заглушка для пустого дня
        Label {
            visible: logList.count === 0
            text: "📭 В этот день записей нет\nДобавьте первый приём пищи"
            color: window.textSecondaryColor
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            wrapMode: Text.WordWrap
        }

        Button {
            text: "🗑️ Очистить день"
            Layout.fillWidth: true
            background: Rectangle { color: window.errorColor; radius: 8 }
            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
            onClicked: {
                DataService.clearDayLogs(targetDate)
                refreshList()
            }
        }
    }

    // Внутренние переменные
    property int selectedFoodId: 0
    property string selectedFoodName: ""

    function refreshList() {
        logList.model = DataService.getDayLogs(targetDate)
    }

    // Обновляем список при открытии
    Component.onCompleted: refreshList()
    onTargetDateChanged: refreshList()
}