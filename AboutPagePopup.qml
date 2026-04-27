import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: dialog
    title: "О приложении"
    modal: true
    anchors.centerIn: parent

    background: Rectangle {
        color: window.bgColor
        radius: 12
    }

    contentItem: Loader {
        source: "AboutPage.qml"
        active: true
    }

    footer: StyledButton {
        text: "Закрыть"
        onClicked: dialog.close()
        background: Rectangle { color: window.accentColor; radius: 8 }
        contentItem: Text {
            text: parent.text
            color: window.accentTextColor
            horizontalAlignment: Text.AlignHCenter
        }
    }
}