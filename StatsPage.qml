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
            contentItem: Text { text: parent.text; color: window.textColor; horizontalAlignment: Text.AlignHCenter }
            onClicked: backClicked()
        }

        Label {
            text: "За последнюю неделю:"
            font.bold: true
            color: window.accentColor
            font.pixelSize: 18
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: DataService.getWeekStats(new Date().toISOString().split('T')[0])
            delegate: ItemDelegate {
                width: parent.width
                background: Rectangle { color: pressed ? window.cardColor : "transparent"; radius: 8 }
                contentItem: ColumnLayout {
                    spacing: 4

                    Text {
                        text: "📅 " + modelData.date
                        color: window.accentColor
                        font.bold: true
                        font.pixelSize: 14
                    }

                    Text {
                        text: "🔥 " + modelData.calories + " ккал"
                        color: window.textColor
                        font.pixelSize: 13
                    }

                    RowLayout {
                        spacing: 12
                        Text {
                            text: "🥩 Б: " + modelData.protein.toFixed(1) + "г"
                            color: "#ff6b6b"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "🥑 Ж: " + modelData.fat.toFixed(1) + "г"
                            color: "#ffd93d"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "🍞 У: " + modelData.carbs.toFixed(1) + "г"
                            color: "#6bcb77"
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: window.borderColor
                    }
                }
            }
        }
    }
}