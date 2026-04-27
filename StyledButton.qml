import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    property color buttonColor: window.cardColor
    property color pressedColor: window.accentColor

    background: Rectangle {
        id: bg
        color: control.pressed ? pressedColor : buttonColor
        radius: 8

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    contentItem: Text {
        text: control.text
        color: window.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}