/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * QtGraphicalEffects → Qt5Compat.GraphicalEffects（此文件不用特效，直接删）
 */

import QtQuick
import QtQuick.Controls

import Cutefish.FileManager 1.0

Item {
    id: control

    property string url: ""

    signal itemClicked(string path)
    signal editorAccepted(string path)

    Rectangle {
        anchors.fill: parent
        color: Theme.darkMode ? Qt.lighter(Theme.secondBackgroundColor, 1.3)
                              : Theme.secondBackgroundColor
        radius: Theme.smallRadius
        z: -1
    }

    ListView {
        id: _pathView
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        model: _pathBarModel
        orientation: Qt.Horizontal
        layoutDirection: Qt.LeftToRight
        clip: true

        leftMargin: 3
        rightMargin: 3
        spacing: Theme.smallSpacing

        onCountChanged: {
            _pathView.currentIndex = _pathView.count - 1
            _pathView.positionViewAtEnd()
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: openEditor()
            z: -1
        }

        highlight: Rectangle {
            radius: Theme.smallRadius
            color: Qt.rgba(Theme.highlightColor.r,
                           Theme.highlightColor.g,
                           Theme.highlightColor.b,
                           Theme.darkMode ? 0.3 : 0.1)
            smooth: true
        }

        delegate: MouseArea {
            id: _item
            height: ListView.view.height - ListView.view.topMargin - ListView.view.bottomMargin
            width: _name.width + Theme.largeSpacing
            hoverEnabled: true
            z: -1

            property bool selected: index === _pathView.count - 1

            onClicked: control.itemClicked(model.path)

            Rectangle {
                anchors.fill: parent
                radius: Theme.smallRadius
                color: _item.pressed
                       ? Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b,
                                 Theme.darkMode ? 0.05 : 0.1)
                       : _item.containsMouse
                         ? Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b,
                                   Theme.darkMode ? 0.1 : 0.05)
                         : "transparent"
                smooth: true
            }

            Label {
                id: _name
                text: model.name
                anchors.centerIn: parent
                color: selected ? Theme.highlightColor : Theme.textColor
            }
        }
    }

    TextField {
        id: _pathEditor
        anchors.fill: parent
        visible: false
        selectByMouse: true
        inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase

        text: _pathBarModel.url
        color: Theme.darkMode ? "white" : "black"

        background: Rectangle {
            radius: Theme.smallRadius
            color: Theme.darkMode ? Qt.lighter(Theme.secondBackgroundColor, 1.7)
                                  : Theme.secondBackgroundColor
            border.width: 1
            border.color: Theme.highlightColor
        }

        onAccepted: {
            control.editorAccepted(text)
            closeEditor()
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape)
                focus = false
        }

        onActiveFocusChanged: {
            if (!activeFocus)
                closeEditor()
        }
    }

    PathBarModel {
        id: _pathBarModel
    }

    function updateUrl(url) {
        control.url = url
        _pathBarModel.url = url
    }

    function openEditor() {
        _pathEditor.text = _pathBarModel.url
        _pathEditor.visible = true
        _pathEditor.forceActiveFocus()
        _pathEditor.selectAll()
        _pathView.visible = false
    }

    function closeEditor() {
        _pathEditor.visible = false
        _pathView.visible = true
    }
}
