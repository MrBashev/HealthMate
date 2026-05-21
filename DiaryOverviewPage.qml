import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import QtQuick.Dialogs

Page {
    signal backClicked()
    property string selectedDate: new Date().toISOString().split('T')[0]

    background: Rectangle { color: window.bgColor }

    property var goals: ({
            "calories": 2000,
            "protein": 150,
            "fat": 70,
            "carbs": 250,
        })

    property var daySummary: {
            "calories": 0, "protein": 0, "fat": 0, "carbs": 0
        }
    property int waterGoal: 2500
    property int waterToday: 0

    // ✅ Локальная дата YYYY-MM-DD (без UTC-сдвигов)
        function getTodayStr() {
            var d = new Date()
            return d.getFullYear() + '-' +
                   String(d.getMonth() + 1).padStart(2, '0') + '-' +
                   String(d.getDate()).padStart(2, '0')
        }
        // ✅ Проверка будущего: строковое сравнение идеально работает для YYYY-MM-DD
           function isFuture(dateStr) {
               return dateStr > getTodayStr()
           }


    function updateWater() {
        waterToday = Number(DataService.getWaterSum(selectedDate))
    }

    function addWaterEntry(ml) {
        DataService.addWater(selectedDate, ml)
        updateWater()
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
    // ✅ Загружаем цели при смене даты
        onSelectedDateChanged: {
            // 1. Загружаем цели
            goals = DataService.getGoals(selectedDate)

            // 2. Загружаем статистику
            var summary = DataService.getDaySummary(selectedDate)
            daySummary = {
                "calories": summary.calories,
                "protein": summary.protein,
                "fat": summary.fat,
                "carbs": summary.carbs
            }

            // 3. Обновляем воду
            updateWater()
        }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Button {
            text: "← Назад"
            Layout.fillWidth: true
            onClicked: backClicked()
        }

        // === КНОПКА ПЕРЕХОДА НА ЛЮБУЮ ДАТУ ===
        Button {
            text: "📅 Перейти к другой дате..."
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            background: Rectangle {
                color: window.cardColor
                radius: 10
                border.color: window.borderColor
                border.width: 1
            }
            contentItem: Text {
                text: parent.text
                color: window.accentColor
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            onClicked: dateJumpDialog.open()
        }

        // === DIALOG ВЫБОРА ДАТЫ (СО СПИСКАМИ) ===
        Dialog {
            id: dateJumpDialog
            title: "Выберите дату"
            modal: true
            anchors.centerIn: parent
            padding: 20
            standardButtons: Dialog.Ok | Dialog.Cancel
            background: Rectangle {
                color: window.bgColor
                radius: 16
                border.color: window.borderColor
                border.width: 1
            }
            dim: true

            contentItem: ColumnLayout {
                spacing: 16
                implicitWidth: 280

                Label {
                    text: "Дата:"
                    font.bold: true
                    color: window.textColor
                    Layout.fillWidth: true
                }

                // 🗓️ ДЕНЬ (список 1-31)
                RowLayout {
                    spacing: 8
                    Label { text: "День:"; color: window.textColor; Layout.preferredWidth: 60 }
                    ComboBox {
                        id: dayCombo
                        Layout.fillWidth: true
                        model: 31
                        textRole: "modelData"
                        delegate: ItemDelegate {
                            width: parent.width
                            contentItem: Text {
                                text: modelData
                                color: window.textColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: ComboBox.highlightedIndex === index
                            background: Rectangle { color: highlighted ? window.accentColor : "transparent" }
                        }
                        background: Rectangle { color: window.cardColor; radius: 6; border.color: window.borderColor }
                        indicator: Text { text: "▼"; color: window.textColor; anchors.right: parent.right; anchors.rightMargin: 8 }
                    }
                }

                // 🗓️ МЕСЯЦ (список с русскими названиями)
                RowLayout {
                    spacing: 8
                    Label { text: "Месяц:"; color: window.textColor; Layout.preferredWidth: 60 }
                    ComboBox {
                        id: monthCombo
                        Layout.fillWidth: true
                        model: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
                                "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
                        currentIndex: 0
                        delegate: ItemDelegate {
                            width: parent.width
                            contentItem: Text {
                                text: modelData
                                color: window.textColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: ComboBox.highlightedIndex === index
                            background: Rectangle { color: highlighted ? window.accentColor : "transparent" }
                        }
                        background: Rectangle { color: window.cardColor; radius: 6; border.color: window.borderColor }
                        indicator: Text { text: "▼"; color: window.textColor; anchors.right: parent.right; anchors.rightMargin: 8 }
                    }
                }

                // 🗓️ ГОД (список от 2020 до текущего)
                RowLayout {
                    spacing: 8
                    Label { text: "Год:"; color: window.textColor; Layout.preferredWidth: 60 }
                    ComboBox {
                        id: yearCombo
                        Layout.fillWidth: true
                        model: {
                            var years = []
                            var current = new Date().getFullYear()
                            for (var y = 2020; y <= current; y++) years.push(y)
                            return years
                        }
                        delegate: ItemDelegate {
                            width: parent.width
                            contentItem: Text {
                                text: modelData
                                color: window.textColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: ComboBox.highlightedIndex === index
                            background: Rectangle { color: highlighted ? window.accentColor : "transparent" }
                        }
                        background: Rectangle { color: window.cardColor; radius: 6; border.color: window.borderColor }
                        indicator: Text { text: "▼"; color: window.textColor; anchors.right: parent.right; anchors.rightMargin: 8 }
                    }
                }
            }

            // === Синхронизация значений при открытии ===
            onOpened: {
                var d = new Date(selectedDate)
                dayCombo.currentIndex = d.getDate() - 1
                monthCombo.currentIndex = d.getMonth()
                yearCombo.currentIndex = yearCombo.model.indexOf(d.getFullYear())
            }

            // === Применение выбора ===
            onAccepted: {
                var d = new Date(
                    yearCombo.model[yearCombo.currentIndex],
                    monthCombo.currentIndex,  // 0-11
                    dayCombo.currentIndex + 1 // 1-31
                )
                selectedDate = d.toISOString().split('T')[0]
            }
        }

        // === КАРТОЧКА ПРОГРЕССА (ИСПРАВЛЕННАЯ) ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 280  // ✅ Явная высота, чтобы не схлопывалась
            color: window.cardColor
            radius: 12
            border.color: window.borderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Label {
                    text: "📊 Прогресс за " + selectedDate
                    font.bold: true
                    color: window.accentColor
                    font.pixelSize: 15
                }

                // КАЛОРИИ
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    RowLayout {
                        spacing: 8
                        Label { text: "🔥 Калории"; color: window.textColor; font.pixelSize: 12 }
                        Label { text: daySummary.calories + " / 2000"; color: daySummary.calories > 2000 ? "#ff6b6b" : window.textSecondaryColor; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { Layout.fillWidth: true; height: 8; color: window.bgColor; radius: 4; clip: true
                        Rectangle { width: parent.width * Math.min(daySummary.calories / 2000, 1); height: parent.height; color: daySummary.calories > 2000 ? "#ff6b6b" : "#00d9ff"; radius: 4; Behavior on width { NumberAnimation { duration: 300 } } }
                    }
                }

                // БЕЛКИ
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    RowLayout {
                        spacing: 8
                        Label { text: "🥩 Белки"; color: window.textColor; font.pixelSize: 12 }
                        Label { text: daySummary.protein.toFixed(1) + " / 150г"; color: daySummary.protein > 150 ? "#ff6b6b" : window.textSecondaryColor; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { Layout.fillWidth: true; height: 6; color: window.bgColor; radius: 3; clip: true
                        Rectangle { width: parent.width * Math.min(daySummary.protein / 150, 1); height: parent.height; color: daySummary.protein > 150 ? "#ff6b6b" : "#ff6b6b"; radius: 3; Behavior on width { NumberAnimation { duration: 300 } } }
                    }
                }

                // ЖИРЫ
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    RowLayout {
                        spacing: 8
                        Label { text: "🥑 Жиры"; color: window.textColor; font.pixelSize: 12 }
                        Label { text: daySummary.fat.toFixed(1) + " / 70г"; color: daySummary.fat > 70 ? "#ff6b6b" : window.textSecondaryColor; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { Layout.fillWidth: true; height: 6; color: window.bgColor; radius: 3; clip: true
                        Rectangle { width: parent.width * Math.min(daySummary.fat / 70, 1); height: parent.height; color: daySummary.fat > 70 ? "#ff6b6b" : "#ffd93d"; radius: 3; Behavior on width { NumberAnimation { duration: 300 } } }
                    }
                }

                // УГЛЕВОДЫ
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    RowLayout {
                        spacing: 8
                        Label { text: "🍞 Углеводы"; color: window.textColor; font.pixelSize: 12 }
                        Label { text: daySummary.carbs.toFixed(1) + " / 250г"; color: daySummary.carbs > 250 ? "#ff6b6b" : window.textSecondaryColor; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { Layout.fillWidth: true; height: 6; color: window.bgColor; radius: 3; clip: true
                        Rectangle { width: parent.width * Math.min(daySummary.carbs / 250, 1); height: parent.height; color: daySummary.carbs > 250 ? "#ff6b6b" : "#6bcb77"; radius: 3; Behavior on width { NumberAnimation { duration: 300 } } }
                    }
                }
            }
        }
        // === ВОДНЫЙ БАЛАНС ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: window.cardColor
            radius: 12
            border.color: window.borderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    spacing: 8
                    Label { text: "💧 Вода"; color: window.textColor; font.pixelSize: 14; font.bold: true }
                    Label {
                        text: waterToday + " / " + waterGoal + " мл"
                        color: waterToday >= waterGoal ? "#6bcb77" : window.textSecondaryColor
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 10
                    color: window.bgColor
                    radius: 5
                    clip: true
                    Rectangle {
                        width: parent.width * Math.min(waterToday / waterGoal, 1)
                        height: parent.height
                        color: {
                            if (waterToday >= 5000) return "#ff6b6b"
                            if (waterToday >= waterGoal) return "#6bcb77"
                            return "#00d9ff"
                        }
                        radius: 5
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }

                // Предупреждение: Будущее
                Label {
                    text: "⚠️ Нельзя добавлять воду в будущее!"
                    color: "#ff6b6b"
                    font.bold: true
                    visible: isFuture(selectedDate)
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // Предупреждение: Перебор
                Label {
                    text: "⚠️ Вы выпили достаточно!"
                    color: "#ff6b6b"
                    font.bold: true
                    visible: !isFuture(selectedDate) && waterToday >= 5000
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "+250 мл"
                        Layout.fillWidth: true
                        enabled: !isFuture(selectedDate) && waterToday < 5000
                        background: Rectangle {
                            color: enabled ? window.accentColor : window.textSecondaryColor
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? window.accentTextColor : "#888888"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        onClicked: addWaterEntry(250)
                    }

                    Button {
                        text: "+500 мл"
                        Layout.fillWidth: true
                        enabled: !isFuture(selectedDate) && waterToday < 5000
                        background: Rectangle {
                            color: enabled ? window.accentColor : window.textSecondaryColor
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? window.accentTextColor : "#888888"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        onClicked: addWaterEntry(500)
                    }

                    Button {
                        text: "🗑️ Сброс"
                        Layout.fillWidth: true
                        enabled: !isFuture(selectedDate)
                        background: Rectangle {
                            color: enabled ? window.errorColor : window.textSecondaryColor
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? window.textColor : "#888888"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        onClicked: {
                            DataService.clearWater(selectedDate)
                            updateWater()
                        }
                    }
                }
            }
        }
        // === КНОПКА УПРАВЛЕНИЯ ===
        Button {
            text: " Управление записями"
            Layout.fillWidth: true
            Layout.topMargin: 4  // ✅ Небольшой отступ сверху
            background: Rectangle { color: window.accentColor; radius: 8 }
            contentItem: Text { text: parent.text; color: window.accentTextColor; horizontalAlignment: Text.AlignHCenter; font.bold: true }
            onClicked: {
                detailLoader.source = "DiaryDetailPage.qml"
                detailLoader.item.targetDate = selectedDate
                detailLoader.item.backClicked.connect(() => detailLoader.source = "")
            }
        }

        Item { Layout.fillHeight: true }
    }

    //Loader {
    //    id: detailLoader
    //    anchors.fill: parent
    //}
}