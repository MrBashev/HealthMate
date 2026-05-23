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

        ListView {
            id: foodList
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            model: DataService.getAllFoods()
            clip: true
            spacing: 4

            delegate: ItemDelegate {
                width: parent.width
                height: 56
                highlighted: selectedFoodId === modelData.id
                background: Rectangle {
                    color: highlighted ? window.accentColor : (pressed ? window.cardColor : "transparent")
                    radius: 8
                }
                contentItem: RowLayout {
                    spacing: 8
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name
                            color: highlighted ? window.accentTextColor : window.textColor
                            font.bold: true
                        }
                        Text {
                            text: "🔥" + modelData.calories + " ккал | " +
                                  "Б:" + Math.round(modelData.protein || 0) + " " +
                                  "Ж:" + Math.round(modelData.fat || 0) + " " +
                                  "У:" + Math.round(modelData.carbs || 0)
                            color: highlighted ? window.accentTextColor : window.textSecondaryColor
                            font.pixelSize: 11
                        }
                    }
                }
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
                width: parent ? parent.width : 300
                height: 36
                color: window.bgColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

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
                        font.pixelSize: 13
                        color: window.accentColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
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

        // === КОПИРОВАНИЕ ДНЯ ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Кнопка копирования
            Button {
                text: "📋 Скопировать этот день"
                Layout.fillWidth: true
                background: Rectangle { color: window.accentColor; radius: 8 }
                contentItem: Text { text: parent.text; color: window.accentTextColor; horizontalAlignment: Text.AlignHCenter; font.bold: true }
                onClicked: {
                    DataService.copyDayLogs(targetDate)
                    copyFeedback.text = "✅ Скопировано " + DataService.copiedLogsCount() + " записей"
                    copyFeedback.visible = true
                    copyTimer.restart()
                }
            }

            // Кнопка вставки (видима только если есть буфер и день пустой)
            Button {
                text: "📌 Вставить сюда (" + DataService.copiedLogsCount() + ")"
                Layout.fillWidth: true
                enabled: !isFuture
                visible: DataService.hasCopiedLogs() && logList.count === 0
                background: Rectangle { color: window.successColor; radius: 8 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; font.bold: true }
                onClicked: {
                    DataService.pasteCopiedLogs(targetDate)
                    refreshList()
                    pasteFeedback.text = "✅ Вставлено " + DataService.copiedLogsCount() + " записей"
                    pasteFeedback.visible = true
                    pasteTimer.restart()
                }
            }
        }

        // === ШАБЛОНЫ ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "💾 Сохранить как шаблон"
                Layout.fillWidth: true
                enabled: !isFuture && logList.count > 0
                background: Rectangle { color: enabled ? window.accentColor : window.textSecondaryColor; radius: 8 }
                contentItem: Text { text: parent.text; color: enabled ? window.accentTextColor : "#888"; horizontalAlignment: Text.AlignHCenter; font.bold: true }
                onClicked: saveTemplateDialog.open()
            }

            Button {
                text: "📂 Загрузить шаблон"
                Layout.fillWidth: true
                enabled: !isFuture
                background: Rectangle { color: enabled ? window.cardColor : window.textSecondaryColor; radius: 8; border.color: window.borderColor }
                contentItem: Text { text: parent.text; color: enabled ? window.textColor : "#888"; horizontalAlignment: Text.AlignHCenter; font.bold: true }
                onClicked: loadTemplateDialog.open()
            }
        }

        // === DIALOG СОХРАНЕНИЯ ШАБЛОНА ===
        Dialog {
            id: saveTemplateDialog
            title: "Сохранить как шаблон"
            modal: true
            anchors.centerIn: parent
            padding: 20
            standardButtons: Dialog.Ok | Dialog.Cancel
            background: Rectangle { color: window.bgColor; radius: 16; border.color: window.borderColor }

            contentItem: ColumnLayout {
                spacing: 12
                implicitWidth: 280
                Label { text: "Название шаблона:"; color: window.textColor; font.bold: true }
                TextField {
                    id: templateNameField
                    placeholderText: "Например: Мой завтрак"
                    Layout.fillWidth: true
                    color: window.textColor
                    background: Rectangle { color: window.cardColor; radius: 6; border.color: window.borderColor }
                }
            }

            onAccepted: {
                var name = templateNameField.text.trim()
                if (name.length > 0) {
                    if (DataService.saveAsTemplate(name)) {
                        templateFeedback.text = "✅ Шаблон «" + name + "» сохранён!"
                        templateFeedback.visible = true
                        templateTimer.restart()
                    }
                    templateNameField.text = ""
                }
            }
        }

        // === DIALOG ЗАГРУЗКИ ШАБЛОНА ===
        Dialog {
            id: loadTemplateDialog
            title: "Выберите шаблон"
            modal: true
            anchors.centerIn: parent
            padding: 20
            standardButtons: Dialog.Cancel
            background: Rectangle { color: window.bgColor; radius: 16; border.color: window.borderColor }

            contentItem: ColumnLayout {
                spacing: 8
                implicitWidth: 280

                Repeater {
                    model: DataService.getTemplates()
                    delegate: Button {
                        text: modelData.name
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        background: Rectangle { color: pressed ? window.accentColor : window.cardColor; radius: 8; border.color: window.borderColor }
                        contentItem: RowLayout {
                            Label { text: modelData.name; color: window.textColor; Layout.fillWidth: true; leftPadding: 8 }
                            Button {
                                text: "🗑️"
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                background: Rectangle { color: window.errorColor; radius: 6 }
                                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
                                onClicked: {
                                    DataService.deleteTemplate(modelData.id)
                                    loadTemplateDialog.contentItem.children[0].model = DataService.getTemplates()
                                }
                            }
                        }
                        onClicked: {
                            DataService.applyTemplate(modelData.id, targetDate)
                            refreshList()
                            loadTemplateDialog.close()
                            templateFeedback.text = "✅ Шаблон применён!"
                            templateFeedback.visible = true
                            templateTimer.restart()
                        }
                    }
                }

                Label {
                    text: "Нет сохранённых шаблонов"
                    visible: loadTemplateDialog.contentItem.children[0].count === 0
                    color: window.textSecondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }

        // Обратная связь по шаблонам
        Label {
            id: templateFeedback
            text: ""
            color: window.successColor
            font.bold: true
            visible: false
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
        Timer { id: templateTimer; interval: 2000; onTriggered: templateFeedback.visible = false }

        // Всплывающие подсказки
        Label {
            id: copyFeedback
            text: ""
            color: window.accentColor
            font.bold: true
            visible: false
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Label {
            id: pasteFeedback
            text: ""
            color: window.successColor
            font.bold: true
            visible: false
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Timer {
            id: copyTimer
            interval: 2000
            onTriggered: copyFeedback.visible = false
        }

        Timer {
            id: pasteTimer
            interval: 2000
            onTriggered: pasteFeedback.visible = false
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