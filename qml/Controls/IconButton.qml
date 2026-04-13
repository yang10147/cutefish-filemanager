/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 */

import QtQuick
import QtQuick.Controls
import "../"

Item {
    id: control
    width: 24
    height: 24

    property alias source: _image.source
    property color backgroundColor: Theme.secondBackgroundColor
    property color hoveredColor: Theme.darkMode
                                 ? Qt.lighter(Theme.secondBackgroundColor, 1.7)
                                 : Qt.darker(Theme.secondBackgroundColor, 1.2)
    property color pressedColor: Theme.darkMode
                                 ? Qt.lighter(Theme.secondBackgroundColor, 1.4)
                                 : Qt.darker(Theme.secondBackgroundColor, 1.3)

    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: _mouseArea.pressed ? pressedColor
             : _mouseArea.containsMouse ? control.hoveredColor
             : control.backgroundColor
    }

    Image {
        id: _image
        anchors.centerIn: parent
        width: 18
        height: width
        sourceSize: Qt.size(width, height)
        smooth: false
        antialiasing: true
    }

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: control.clicked()
    }
}
