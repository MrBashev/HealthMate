import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()
    property string selectedDate: new Date().toISOString().split('T')[0]

    background: Rectangle { color: window.bgColor }

    property var daySummary: {
        "calories": 0, "protein": 0, "fat": 0, "carbs": 0
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

    onSelectedDateChanged: {
        var summary = DataService.getDaySummary(selectedDate)
        daySummary = {
            "calories": summary.calories,
            "protein": summary.protein,
            "fat": summary.fat,
            "carbs": summary.carbs
        }
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

        Label {
            text: "Выберите дату:"
            color: window.textColor
            font.bold: true
        }

        // === ВЫБОР ДНЯ ===
        RowLayout {
            spacing: 4
            Repeater {
                model: getWeekDates()
                delegate: Button {
                    text: modelData.name + "\n" + modelData.date.slice(5)
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: selectedDate === modelData.date ? window.accentColor : window.cardColor
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: selectedDate === modelData.date ? window.accentTextColor : window.textColor
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: selectedDate = modelData.date
                }
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

    Loader {
        id: detailLoader
        anchors.fill: parent
    }
}