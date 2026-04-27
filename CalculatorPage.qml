import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    background: Rectangle { color: window.bgColor }
    signal backClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        StyledButton {
            text: "← Назад"
            Layout.fillWidth: true
            background: Rectangle { color: window.cardColor; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: window.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: backClicked()
        }

        TextField {
            id: ageField
            placeholderText: "Возраст (лет)"
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhDigitsOnly
            color: window.textColor
            placeholderTextColor: window.textSecondaryColor
            background: Rectangle { color: window.cardColor; radius: 4 }
        }

        TextField {
            id: heightField
            placeholderText: "Рост (см)"
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhDigitsOnly
            color: window.textColor
            placeholderTextColor: window.textSecondaryColor
            background: Rectangle { color: window.cardColor; radius: 4 }
        }

        TextField {
            id: weightField
            placeholderText: "Вес (кг)"
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhDigitsOnly
            color: window.textColor
            placeholderTextColor: window.textSecondaryColor
            background: Rectangle { color: window.cardColor; radius: 4 }
        }

        ComboBox {
            id: activityBox
            Layout.fillWidth: true
            model: ["Сидячий", "Лёгкая", "Средняя", "Высокая", "Тяжёлая"]
            background: Rectangle { color: window.cardColor; radius: 4 }
            contentItem: Text {
                text: activityBox.currentText
                color: window.textColor
                verticalAlignment: Text.AlignVCenter
            }
            delegate: ItemDelegate {
                background: Rectangle { color: window.cardColor }
                contentItem: Text {
                    text: modelData
                    color: window.textColor
                }
            }
            popup.background: Rectangle { color: window.surfaceColor }
        }

        StyledButton {
            text: "Рассчитать"
            Layout.fillWidth: true
            background: Rectangle { color: window.accentColor; radius: 8 }
            contentItem: Text {
                text: parent.text
                color: window.accentTextColor
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

                var macros = HealthCore.calculateMacros(tdee, "maintain")
                macrosLabel.text = "\nРекомендуемые БЖУ:\n" +
                                   "🥩 Белки: " + macros.protein.toFixed(1) + "г\n" +
                                   "🥑 Жиры: " + macros.fat.toFixed(1) + "г\n" +
                                   "🍞 Углеводы: " + macros.carbs.toFixed(1) + "г"
            }
        }

        Label {
            id: resultLabel
            color: window.textColor
            wrapMode: Text.WordWrap
            font.pixelSize: 16
        }

        Label {
            id: macrosLabel
            color: window.textSecondaryColor
            wrapMode: Text.WordWrap
            font.pixelSize: 14
        }

        Item { Layout.fillHeight: true }
    }
}