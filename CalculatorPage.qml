import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Кнопка Назад
        Button {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle { color: "#2d2d44"; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: backClicked()
        }

        // Поля ввода
        TextField {
            id: ageField
            placeholderText: "Возраст (лет)"
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhDigitsOnly
            background: Rectangle { color: "#2d2d44"; radius: 4 }
        }

        TextField {
            id: heightField
            placeholderText: "Рост (см)"
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhDigitsOnly
            background: Rectangle { color: "#2d2d44"; radius: 4 }
        }

        TextField {
            id: weightField
            placeholderText: "Вес (кг)"
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhDigitsOnly
            background: Rectangle { color: "#2d2d44"; radius: 4 }
        }

        // Активность
        ComboBox {
            id: activityBox
            Layout.fillWidth: true
            model: ["Сидячий", "Лёгкая", "Средняя", "Высокая", "Тяжёлая"]
            background: Rectangle { color: "#2d2d44"; radius: 4 }
        }

        // Кнопка Рассчитать
        Button {
            text: "Рассчитать"
            Layout.fillWidth: true
            background: Rectangle { color: "#00d9ff"; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: "black"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: {
                var age = parseInt(ageField.text) || 25
                var height = parseFloat(heightField.text) || 170
                var weight = parseFloat(weightField.text) || 70

                var bmr = HealthCore.calculateBMR("F", age, height, weight)
                var tdee = HealthCore.calculateTDEE(bmr, activityBox.currentIndex + 1)

                resultLabel.text = "BMR: " + bmr + " ккал\nTDEE: " + tdee + " ккал"

                // Расчёт БЖУ
                var macros = HealthCore.calculateMacros(tdee, "maintain")
                macrosLabel.text = "\nРекомендуемые БЖУ:\n" +
                                   "🥩 Белки: " + macros.protein.toFixed(1) + "г\n" +
                                   "🥑 Жиры: " + macros.fat.toFixed(1) + "г\n" +
                                   "🍞 Углеводы: " + macros.carbs.toFixed(1) + "г"
            }
        }

        // Результат
        Label {
            id: resultLabel
            color: "white"
            wrapMode: Text.WordWrap
            font.pixelSize: 16
        }

        // БЖУ рекомендации
        Label {
            id: macrosLabel
            color: "#aaaaaa"
            wrapMode: Text.WordWrap
            font.pixelSize: 14
        }

        Item { Layout.fillHeight: true }
    }
}