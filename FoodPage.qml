import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    title: qsTr("Продукты")

    ListView {
        anchors.fill: parent
        model: DataService.getAllFoods()
        delegate: ItemDelegate {
            width: parent.width
            text: modelData.name + " - " + modelData.calories + " ккал"
            onClicked: console.log("Выбран:", modelData.name)
        }
    }
}