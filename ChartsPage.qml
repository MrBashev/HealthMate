import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    signal backClicked()

    background: Rectangle { color: window.bgColor }

    property int minCal: 0
    property int maxCal: 0
    property int avgCal: 0
    property var chartData: []  // Данные для графика

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Button {
            text: "← Назад"
            Layout.fillWidth: true
            //background: Rectangle { color: window.bgColor }
            onClicked: backClicked()
        }

        Label {
            text: "📊 Статистика калорий"
            font.bold: true
            font.pixelSize: 18
            color: window.accentColor
        }

        // === ГРАФИК НА CANVAS (стабильно в Qt 6.11) ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: window.cardColor
            radius: 8
            clip: true

            Canvas {
                id: chartCanvas
                anchors.fill: parent
                anchors.margins: 10

                // Цвета под тему
                property color lineColor: window.accentColor
                property color gridColor: window.borderColor
                property color textColor: window.textSecondaryColor
                property color pointColor: window.accentColor

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    if (chartData.length === 0) return

                    var w = width
                    var h = height
                    var padding = 20
                    var graphW = w - padding * 2
                    var graphH = h - padding * 2

                    // Находим мин/макс для масштаба
                    var maxVal = Math.max(...chartData.map(d => d.y)) * 1.1
                    if (maxVal < 500) maxVal = 500

                    // Рисуем сетку
                    ctx.strokeStyle = gridColor
                    ctx.lineWidth = 1
                    for (var i = 0; i <= 4; i++) {
                        var y = padding + (graphH / 4) * i
                        ctx.beginPath()
                        ctx.moveTo(padding, y)
                        ctx.lineTo(w - padding, y)
                        ctx.stroke()
                    }

                    // Рисуем линию
                    ctx.strokeStyle = lineColor
                    ctx.lineWidth = 3
                    ctx.lineJoin = "round"
                    ctx.beginPath()

                    for (var i = 0; i < chartData.length; i++) {
                        var x = padding + (graphW / (chartData.length - 1 || 1)) * i
                        var y = h - padding - (chartData[i].y / maxVal) * graphH

                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.stroke()

                    // Рисуем точки
                    ctx.fillStyle = pointColor
                    for (var i = 0; i < chartData.length; i++) {
                        var x = padding + (graphW / (chartData.length - 1 || 1)) * i
                        var y = h - padding - (chartData[i].y / maxVal) * graphH

                        ctx.beginPath()
                        ctx.arc(x, y, 4, 0, Math.PI * 2)
                        ctx.fill()
                    }
                }

                Component.onCompleted: redraw()
                onWidthChanged: redraw()
                onHeightChanged: redraw()
            }

            // Подписи дней внизу
            RowLayout {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                spacing: 0

                Repeater {
                    model: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                    Label {
                        text: modelData
                        color: chartCanvas.textColor
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // Статистика
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label { text: "📉 Мин: " + minCal; color: window.textSecondaryColor; Layout.fillWidth: true }
            Label { text: "📈 Макс: " + maxCal; color: window.textSecondaryColor; Layout.fillWidth: true }
            Label { text: "📊 Сред: " + avgCal; color: window.accentColor; font.bold: true; Layout.fillWidth: true }
        }

        Item { Layout.fillHeight: true }
    }

    function loadData() {
        var data = DataService.getWeekCalories(new Date().toISOString().split('T')[0])
        chartData = []
        var values = []

        if (data.length === 0) {
            for (var i = 0; i < 7; i++) {
                chartData.push({x: i, y: 0})
                values.push(0)
            }
        } else {
            for (var i = 0; i < data.length; i++) {
                chartData.push({x: i, y: data[i].calories})
                values.push(data[i].calories)
            }
        }

        calcStats(values)
        chartCanvas.requestPaint()  // Перерисовываем график
    }

    function calcStats(arr) {
        if (!arr.length) { minCal = maxCal = avgCal = 0; return }
        var sum = 0, mn = arr[0], mx = arr[0]
        for (var v of arr) { sum += v; if (v < mn) mn = v; if (v > mx) mx = v }
        minCal = mn; maxCal = mx; avgCal = Math.round(sum / arr.length)
    }

    Component.onCompleted: loadData()
    onVisibleChanged: if (visible) loadData()
}