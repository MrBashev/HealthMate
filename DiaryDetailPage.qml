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
                        DataService.addLogEntry(selectedFoodId, grams, "Обед", targetDate)
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

        // === СПИСОК ЗАПИСЕЙ ===
        Label { text: "Список:"; color: window.textColor; font.bold: true }
        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: DataService.getDayLogs(targetDate)
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.cardColor : "transparent" }
                contentItem: RowLayout {
                    Text { text: modelData.name + " (" + modelData.grams + "г)"; color: window.textColor; Layout.fillWidth: true }
                    Button {
                        text: "❌"
                        background: Rectangle { color: window.errorColor; radius: 4 }
                        contentItem: Text { text: parent.text; color: "white" }
                        onClicked: {
                            DataService.deleteLogEntry(modelData.id)
                            refreshList()
                        }
                    }
                }
            }
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