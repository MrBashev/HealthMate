import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()
    property string currentDay: new Date().toISOString().split('T')[0]

    function isFutureDate(dateStr) {
        var today = new Date()
        var todayStr = today.getFullYear() + '-' +
                       String(today.getMonth() + 1).padStart(2, '0') + '-' +
                       String(today.getDate()).padStart(2, '0')
        return dateStr > todayStr
    }

    // Генерация дат на неделю
    function getWeekDates() {
        var dates = []
        var today = new Date()
        var dayOfWeek = today.getDay() || 7  // 1=Пн, 7=Вс
        var monday = new Date(today)
        monday.setDate(today.getDate() - dayOfWeek + 1)

        for (var i = 0; i < 7; i++) {
            var d = new Date(monday)
            d.setDate(monday.getDate() + i)
            var dateStr = d.getFullYear() + '-' +
                         String(d.getMonth() + 1).padStart(2, '0') + '-' +
                         String(d.getDate()).padStart(2, '0')
            var dayName = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"][i]
            dates.push({date: dateStr, name: dayName})
        }
        return dates
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Кнопка Назад
        Button {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle { color: window.theme[window.appTheme].card; radius: 8 }
            contentItem: Text { text: parent.text; color: window.theme[window.appTheme].text; horizontalAlignment: Text.AlignHCenter }
            onClicked: backClicked()
        }

        // === ВЫБОР ДАТЫ (неделя) ===
        Label {
            text: "Выберите дату:"
            color: "white"
            font.bold: true
        }

        RowLayout {
            spacing: 4
            Repeater {
                model: getWeekDates()
                delegate: Button {
                    text: modelData.name + "\n" + modelData.date.slice(5)
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 60
                    background: Rectangle {
                            color: currentDay === modelData.date ?
                                   window.theme[window.appTheme].accent :
                                   window.theme[window.appTheme].card
                            radius: 8
                        }
                    contentItem: Text {
                        text: parent.text
                        color: window.theme[window.appTheme].text
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (!isFutureDate(modelData.date)) {
                            currentDay = modelData.date
                        } else {
                            warningLabel.text = "⚠️ Будущее нельзя!"
                            warningLabel.visible = true
                        }
                    }
                }
            }
        }

        // Предупреждения
        Label {
            id: warningLabel
            color: "orange"
            visible: false
            wrapMode: Text.WordWrap
        }

        // === ПОИСК ПРОДУКТОВ ===
        Label {
            text: "Поиск продукта:"
            color: window.theme[window.appTheme].text
            font.bold: true
        }

        TextField {
            id: searchField
            placeholderTextColor: window.theme[window.appTheme].textSecondary
            placeholderText: "🔍 Начните вводить название..."
            Layout.fillWidth: true
            background: Rectangle { color: window.theme[window.appTheme].card; radius: 4 }
            onTextChanged: foodList.model = DataService.searchFoods(searchField.text)
        }

        // === СПИСОК ПРОДУКТОВ ===
        ListView {
            id: foodList
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            model: DataService.getAllFoods()
            clip: true
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.theme[window.appTheme].card : "transparent" }
                contentItem: Text {
                    text: modelData.name + " (" + modelData.calories + " ккал/100г)"
                    color: window.theme[window.appTheme].text
                }
                onClicked: {
                    selectedFoodId = modelData.id
                    selectedFoodName = modelData.name
                    foodList.currentIndex = index
                }
            }
        }

        // === ДОБАВЛЕНИЕ ЗАПИСИ ===
        Label {
            text: selectedFoodName ? "Выбрано: " + selectedFoodName : "Выберите продукт из списка"
            color: selectedFoodId ? "#00d9ff" : "#aaaaaa"
        }

        TextField {
            id: gramsField
            placeholderText: "Грамм"
            inputMethodHints: Qt.ImhDigitsOnly
            Layout.fillWidth: true
            background: Rectangle { color: "#2d2d44"; radius: 4 }
        }

        Button {
            text: "➕ Добавить запись"
            Layout.fillWidth: true
            background: Rectangle { color: selectedFoodId ? "#3d8b37" : "#555555"; radius: 8 }
            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
            enabled: selectedFoodId > 0
            onClicked: {
                var grams = parseFloat(gramsField.text)
                if (!grams || grams <= 0) {
                    warningLabel.text = "⚠️ Граммы должны быть больше 0!"
                    warningLabel.color = "orange"
                    warningLabel.visible = true
                    timer.start()
                    return
                }
                if (isFutureDate(currentDay)) {
                    warningLabel.text = "⚠️ Нельзя добавлять в будущее!"
                    warningLabel.color = "orange"
                    warningLabel.visible = true
                    timer.start()
                    return
                }
                var success = DataService.addLogEntry(selectedFoodId, grams, "Обед", currentDay)
                if (success) {
                    warningLabel.text = "✅ Добавлено!"
                    warningLabel.color = "#3d8b37"
                    warningLabel.visible = true
                    gramsField.text = ""
                    refreshList()
                }
                timer.start()
            }
        }

        // === СПИСОК ЗАПИСЕЙ ЗА ДЕНЬ ===
        Label {
            text: "Записи за " + currentDay + ":"
            color: "white"
            font.bold: true
        }

        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: DataService.getDayLogs(currentDay)
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? "#3d3d5c" : "transparent" }
                contentItem: RowLayout {
                    Text {
                        text: modelData.name + " (" + modelData.grams + "г)"
                        color: "white"
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "❌"
                        background: Rectangle { color: "#8b3737"; radius: 4 }
                        contentItem: Text { text: parent.text; color: "white" }
                        onClicked: {
                            DataService.deleteLogEntry(modelData.id)
                            refreshList()
                        }
                    }
                }
            }
        }

        // Итого за день с БЖУ
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                id: totalLabel
                color: "#00d9ff"
                font.bold: true
                text: "Всего: 0 ккал"
                font.pixelSize: 16
            }

            RowLayout {
                spacing: 12
                Label {
                    id: proteinLabel
                    color: "#ff6b6b"
                    text: "🥩 Б: 0г"
                    font.pixelSize: 13
                }
                Label {
                    id: fatLabel
                    color: "#ffd93d"
                    text: "🥑 Ж: 0г"
                    font.pixelSize: 13
                }
                Label {
                    id: carbsLabel
                    color: "#6bcb77"
                    text: "🍞 У: 0г"
                    font.pixelSize: 13
                }
            }
        }

        // В функции refreshList() обнови:
        function refreshList() {
            logList.model = DataService.getDayLogs(currentDay)
            var summary = DataService.getDaySummary(currentDay)
            totalLabel.text = "🔥 Всего: " + summary.calories + " ккал"
            proteinLabel.text = "🥩 Б: " + summary.protein.toFixed(1) + "г"
            fatLabel.text = "🥑 Ж: " + summary.fat.toFixed(1) + "г"
            carbsLabel.text = "🍞 У: " + summary.carbs.toFixed(1) + "г"
        }

        // Кнопки управления
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "🔄 Обновить"
                Layout.fillWidth: true
                background: Rectangle { color: "#2d2d44"; radius: 8 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                onClicked: refreshList()
            }

            Button {
                text: "🗑️ Очистить день"
                Layout.fillWidth: true
                background: Rectangle { color: "#8b3737"; radius: 8 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                onClicked: {
                    DataService.clearDayLogs(currentDay)
                    refreshList()
                    warningLabel.text = "✅ День очищен!"
                    warningLabel.color = "#3d8b37"
                    warningLabel.visible = true
                    timer.start()
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // Переменные для выбранного продукта
    property int selectedFoodId: 0
    property string selectedFoodName: ""

    // Таймер для скрытия сообщений
    Timer {
        id: timer
        interval: 2000
        onTriggered: {
            warningLabel.visible = false
            warningLabel.color = "orange"
        }
    }

    // Обновление списка
    function refreshList() {
        logList.model = DataService.getDayLogs(currentDay)
        var summary = DataService.getDaySummary(currentDay)
        totalLabel.text = "Всего: " + summary.calories + " ккал"
    }
}