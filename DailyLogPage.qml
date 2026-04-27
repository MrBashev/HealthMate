import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    background: Rectangle { color: window.bgColor }
    signal backClicked()
    property string currentDay: new Date().toISOString().split('T')[0]

    function isFutureDate(dateStr) {
        var today = new Date()
        var todayStr = today.getFullYear() + '-' +
                       String(today.getMonth() + 1).padStart(2, '0') + '-' +
                       String(today.getDate()).padStart(2, '0')
        return dateStr > todayStr
    }

    function getWeekDates() {
        var dates = []
        var today = new Date()
        var dayOfWeek = today.getDay() || 7
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

        StyledButton {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
            onClicked: backClicked()
        }

        Label {
            text: "Выберите дату:"
            color: window.textColor
            font.bold: true
        }

        RowLayout {
            spacing: 4
            Repeater {
                model: getWeekDates()
                delegate: StyledButton {
                    text: modelData.name + "\n" + modelData.date.slice(5)
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: currentDay === modelData.date ? window.accentColor : window.cardColor
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: currentDay === modelData.date ? window.accentTextColor : window.textColor
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

        Label {
            id: warningLabel
            color: window.warningColor
            visible: false
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Поиск продукта:"
            color: window.textColor
            font.bold: true
        }

        TextField {
            id: searchField
            placeholderText: "🔍 Начните вводить название..."
            Layout.fillWidth: true
            color: window.textColor
            placeholderTextColor: window.textSecondaryColor
            background: Rectangle { color: window.cardColor; radius: 4 }
            onTextChanged: foodList.model = DataService.searchFoods(searchField.text)
        }

        ListView {
            id: foodList
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            model: DataService.getAllFoods()
            clip: true
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.cardColor : "transparent" }
                contentItem: Text {
                    text: modelData.name + " (" + modelData.calories + " ккал/100г)"
                    color: window.textColor
                }
                onClicked: {
                    selectedFoodId = modelData.id
                    selectedFoodName = modelData.name
                    foodList.currentIndex = index
                }
            }
        }

        Label {
            text: selectedFoodName ? "Выбрано: " + selectedFoodName : "Выберите продукт из списка"
            color: selectedFoodId ? window.accentColor : window.textSecondaryColor
        }

        TextField {
            id: gramsField
            placeholderText: "Грамм"
            inputMethodHints: Qt.ImhDigitsOnly
            Layout.fillWidth: true
            color: window.textColor
            placeholderTextColor: window.textSecondaryColor
            background: Rectangle { color: window.cardColor; radius: 4 }
        }

        StyledButton {
            text: "➕ Добавить запись"
            Layout.fillWidth: true
            background: Rectangle { color: selectedFoodId > 0 ? window.successColor : window.textSecondaryColor; radius: 8 }
            contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
            enabled: selectedFoodId > 0
            onClicked: {
                var grams = parseFloat(gramsField.text)
                if (!grams || grams <= 0) {
                    warningLabel.text = "⚠️ Граммы должны быть больше 0!"
                    warningLabel.color = window.warningColor
                    warningLabel.visible = true
                    timer.start()
                    return
                }
                if (isFutureDate(currentDay)) {
                    warningLabel.text = "⚠️ Нельзя добавлять в будущее!"
                    warningLabel.color = window.warningColor
                    warningLabel.visible = true
                    timer.start()
                    return
                }
                var success = DataService.addLogEntry(selectedFoodId, grams, "Обед", currentDay)
                if (success) {
                    warningLabel.text = "✅ Добавлено!"
                    warningLabel.color = window.successColor
                    warningLabel.visible = true
                    gramsField.text = ""
                    refreshList()
                }
                timer.start()
            }
        }

        Label {
            text: "Записи за " + currentDay + ":"
            color: window.textColor
            font.bold: true
        }

        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: DataService.getDayLogs(currentDay)
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.cardColor : "transparent" }
                contentItem: RowLayout {
                    Text {
                        text: modelData.name + " (" + modelData.grams + "г)"
                        color: window.textColor
                        Layout.fillWidth: true
                    }
                    StyledButton {
                        text: "❌"
                        background: Rectangle { color: window.errorColor; radius: 4 }
                        contentItem: Text { text: parent.text; color: window.textColor }
                        onClicked: {
                            DataService.deleteLogEntry(modelData.id)
                            refreshList()
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                id: totalLabel
                color: window.accentColor
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

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            StyledButton {
                text: "🔄 Обновить"
                Layout.fillWidth: true
                background: Rectangle { color: window.cardColor; radius: 8 }
                contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
                onClicked: refreshList()
            }

            StyledButton {
                text: "🗑️ Очистить день"
                Layout.fillWidth: true
                background: Rectangle { color: window.errorColor; radius: 8 }
                contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
                onClicked: {
                    DataService.clearDayLogs(currentDay)
                    refreshList()
                    warningLabel.text = "✅ День очищен!"
                    warningLabel.color = window.successColor
                    warningLabel.visible = true
                    timer.start()
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    property int selectedFoodId: 0
    property string selectedFoodName: ""

    Timer {
        id: timer
        interval: 2000
        onTriggered: {
            warningLabel.visible = false
            warningLabel.color = window.warningColor
        }
    }

    function refreshList() {
        logList.model = DataService.getDayLogs(currentDay)
        var summary = DataService.getDaySummary(currentDay)
        totalLabel.text = "🔥 Всего: " + summary.calories + " ккал"
        proteinLabel.text = "🥩 Б: " + summary.protein.toFixed(1) + "г"
        fatLabel.text = "🥑 Ж: " + summary.fat.toFixed(1) + "г"
        carbsLabel.text = "🍞 У: " + summary.carbs.toFixed(1) + "г"
    }
}