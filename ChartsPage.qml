import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    background: Rectangle { color: window.bgColor }
    signal backClicked()

    property int minCal: 0
    property int maxCal: 0
    property int avgCal: 0
    property var chartData: []
    property string chartMode: "calories"  // "calories" или "macros"

    // Данные БЖУ
    property real proteinGrams: 0
    property real fatGrams: 0
    property real carbsGrams: 0
    property real totalMacros: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Button {
            text: "← Назад"
            Layout.fillWidth: true
            onClicked: backClicked()
        }

        // === ПЕРЕКЛЮЧАТЕЛЬ ===
        RowLayout {
            spacing: 8

            Button {
                text: "📊 Калории"
                Layout.fillWidth: true
                background: Rectangle {
                    color: chartMode === "calories" ? window.accentColor : window.cardColor
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: chartMode === "calories" ? window.accentTextColor : window.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: {
                    chartMode = "calories"
                    loadData()
                }
            }

            Button {
                text: "🥧 БЖУ"
                Layout.fillWidth: true
                background: Rectangle {
                    color: chartMode === "macros" ? window.accentColor : window.cardColor
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: chartMode === "macros" ? window.accentTextColor : window.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: {
                    chartMode = "macros"
                    loadMacros()
                }
            }
        }

        // === ГРАФИК КАЛОРИЙ ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: chartMode === "calories" ? 200 : 0
            color: window.cardColor
            radius: 8
            clip: true
            visible: chartMode === "calories"

            Canvas {
                id: calorieCanvas
                anchors.fill: parent
                anchors.margins: 10

                property color lineColor: window.accentColor
                property color gridColor: window.borderColor
                property color textColor: window.textSecondaryColor

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    if (chartData.length === 0) return

                    var w = width
                    var h = height
                    var padding = 20
                    var graphW = w - padding * 2
                    var graphH = h - padding * 2

                    var maxVal = Math.max(...chartData.map(d => d.y)) * 1.1
                    if (maxVal < 100) maxVal = 100

                    // Сетка
                    ctx.strokeStyle = gridColor
                    ctx.lineWidth = 1
                    for (var i = 0; i <= 3; i++) {
                        var y = padding + (graphH / 3) * i
                        ctx.beginPath()
                        ctx.moveTo(padding, y)
                        ctx.lineTo(w - padding, y)
                        ctx.stroke()
                    }

                    // Линия
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

                    // Точки
                    ctx.fillStyle = lineColor
                    for (var i = 0; i < chartData.length; i++) {
                        var x = padding + (graphW / (chartData.length - 1 || 1)) * i
                        var y = h - padding - (chartData[i].y / maxVal) * graphH

                        ctx.beginPath()
                        ctx.arc(x, y, 4, 0, Math.PI * 2)
                        ctx.fill()
                    }
                }


                Component.onCompleted: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }

            // Подписи дней
            RowLayout {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 5
                spacing: 0

                Repeater {
                    model: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                    Label {
                        text: modelData
                        color: calorieCanvas.textColor
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // === ДИАГРАММА БЖУ ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: chartMode === "macros" ? 250 : 0
            color: window.cardColor
            radius: 8
            clip: true
            visible: chartMode === "macros"

            Canvas {
                id: macrosCanvas
                anchors.fill: parent
                anchors.margins: 10

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    if (width < 10 || height < 10) return

                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2 - 20

                    if (totalMacros === 0) {
                        // Нет данных
                        ctx.fillStyle = window.textSecondaryColor
                        ctx.font = "14px sans-serif"
                        ctx.textAlign = "center"
                        ctx.fillText("Нет данных за сегодня", centerX, centerY)
                        return
                    }

                    // Углы для секторов
                    var proteinAngle = (proteinGrams / totalMacros) * 2 * Math.PI
                    var fatAngle = (fatGrams / totalMacros) * 2 * Math.PI
                    var carbsAngle = (carbsGrams / totalMacros) * 2 * Math.PI

                    // Белки (красный)
                    ctx.beginPath()
                    ctx.moveTo(centerX, centerY)
                    ctx.arc(centerX, centerY, radius, -Math.PI/2, -Math.PI/2 + proteinAngle)
                    ctx.closePath()
                    ctx.fillStyle = "#ff6b6b"
                    ctx.fill()

                    // Жиры (жёлтый)
                    ctx.beginPath()
                    ctx.moveTo(centerX, centerY)
                    ctx.arc(centerX, centerY, radius, -Math.PI/2 + proteinAngle, -Math.PI/2 + proteinAngle + fatAngle)
                    ctx.closePath()
                    ctx.fillStyle = "#ffd93d"
                    ctx.fill()

                    // Углеводы (зелёный)
                    ctx.beginPath()
                    ctx.moveTo(centerX, centerY)
                    ctx.arc(centerX, centerY, radius, -Math.PI/2 + proteinAngle + fatAngle, -Math.PI/2 + proteinAngle + fatAngle + carbsAngle)
                    ctx.closePath()
                    ctx.fillStyle = "#6bcb77"
                    ctx.fill()

                    // Центральный круг (пончик)
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, radius * 0.5, 0, Math.PI * 2)
                    ctx.fillStyle = window.cardColor
                    ctx.fill()

                    // Текст в центре
                    ctx.fillStyle = window.textColor
                    ctx.font = "bold 16px sans-serif"
                    ctx.textAlign = "center"
                    ctx.fillText("БЖУ", centerX, centerY - 10)
                    ctx.font = "12px sans-serif"
                    ctx.fillText(totalMacros.toFixed(0) + "г", centerX, centerY + 10)
                }

                Component.onCompleted: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }

            // Легенда
            ColumnLayout {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                spacing: 4

                RowLayout {
                    spacing: 8
                    Rectangle { width: 12; height: 12; color: "#ff6b6b"; radius: 2 }
                    Label {
                        text: "🥩 Белки: " + proteinGrams.toFixed(1) + "г (" + (totalMacros > 0 ? (proteinGrams/totalMacros*100).toFixed(0) : 0) + "%)"
                        color: window.textColor
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    spacing: 8
                    Rectangle { width: 12; height: 12; color: "#ffd93d"; radius: 2 }
                    Label {
                        text: "🥑 Жиры: " + fatGrams.toFixed(1) + "г (" + (totalMacros > 0 ? (fatGrams/totalMacros*100).toFixed(0) : 0) + "%)"
                        color: window.textColor
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    spacing: 8
                    Rectangle { width: 12; height: 12; color: "#6bcb77"; radius: 2 }
                    Label {
                        text: "🍞 Углеводы: " + carbsGrams.toFixed(1) + "г (" + (totalMacros > 0 ? (carbsGrams/totalMacros*100).toFixed(0) : 0) + "%)"
                        color: window.textColor
                        font.pixelSize: 12
                    }
                }
            }
        }

        // Статистика калорий (только для режима калорий)
        RowLayout {
            Layout.fillWidth: true
            visible: chartMode === "calories"
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
        if (chartMode === "calories") calorieCanvas.requestPaint()
    }

    function loadMacros() {
        var macros = DataService.getTodayMacros()
        proteinGrams = macros.protein
        fatGrams = macros.fat
        carbsGrams = macros.carbs
        totalMacros = macros.total

        if (chartMode === "macros") macrosCanvas.requestPaint()
    }

    function calcStats(arr) {
        if (!arr.length) { minCal = maxCal = avgCal = 0; return }
        var sum = 0, mn = arr[0], mx = arr[0]
        for (var v of arr) { sum += v; if (v < mn) mn = v; if (v > mx) mx = v }
        minCal = mn; maxCal = mx; avgCal = Math.round(sum / arr.length)
    }

    Component.onCompleted: loadData()
    onVisibleChanged: if (visible) {
        if (chartMode === "calories") loadData()
        else loadMacros()
    }
}