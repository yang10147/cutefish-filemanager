/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * QtGraphicalEffects → Qt5Compat.GraphicalEffects
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Cutefish.FileManager 1.0

Item {
    id: _listItem
    width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
    height: ListView.view.itemHeight

    Accessible.name: model.fileName
    Accessible.role: Accessible.Canvas

    property Item iconArea: _image.visible ? _image : _icon
    property Item labelArea: _label
    property Item labelArea2: _label2

    property int index: model.index
    property bool hovered: ListView.view.hoveredItem === _listItem
    property bool selected: model.selected
    property bool blank: model.blank

    property color hoveredColor: Theme.darkMode
        ? Qt.lighter(Theme.backgroundColor, 2.3)
        : Qt.darker(Theme.backgroundColor, 1.05)
    property color selectedColor: Theme.darkMode
        ? Qt.lighter(Theme.backgroundColor, 1.2)
        : Qt.darker(Theme.backgroundColor, 1.15)

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: selected ? Theme.highlightColor : hovered ? hoveredColor : "transparent"
        visible: selected || hovered
        opacity: selected ? 0.1 : 1
    }

    // 双击打开文件
    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onDoubleTapped: {
            dirModel.setSelected(_listItem.index)
            dirModel.openSelected()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.smallSpacing
        anchors.rightMargin: Theme.smallSpacing
        spacing: Theme.largeSpacing

        Item {
            id: iconItem
            Layout.fillHeight: true
            width: parent.height * 0.8
            opacity: model.isHidden ? 0.5 : 1.0

            Image {
                id: _icon
                anchors.centerIn: iconItem
                width: iconItem.width; height: width
                sourceSize: Qt.size(width, height)
                source: "image://icontheme/" + model.iconName
                visible: !_image.visible
                asynchronous: true
            }

            Image {
                id: _image
                width: parent.height * 0.8; height: width
                anchors.centerIn: iconItem
                sourceSize: Qt.size(_icon.width, _icon.height)
                source: model.thumbnail ? model.thumbnail : ""
                visible: status === Image.Ready
                fillMode: Image.PreserveAspectFit
                asynchronous: true; cache: false

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: _image.width; height: _image.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, _image.paintedWidth)
                            height: Math.min(parent.height, _image.paintedHeight)
                            radius: height * 0.1
                        }
                    }
                }
            }

            Image {
                anchors.right: _icon.visible ? _icon.right : _image.right
                anchors.bottom: _icon.visible ? _icon.bottom : _image.bottom
                source: "image://icontheme/emblem-symbolic-link"
                width: 16; height: 16
                visible: model.isLink
                sourceSize: Qt.size(width, height)
            }
        }

        ColumnLayout {
            spacing: 0

            Label {
                id: _label
                text: model.fileName
                Layout.fillWidth: true
                color: selected ? Theme.highlightColor : Theme.textColor
                textFormat: Text.PlainText
                elide: Qt.ElideMiddle
                opacity: model.isHidden ? 0.8 : 1.0
            }

            Label {
                id: _label2
                text: model.fileSize
                color: selected ? Theme.highlightColor : Theme.disabledTextColor
                textFormat: Text.PlainText
                Layout.fillWidth: true
                opacity: model.isHidden ? 0.8 : 1.0
            }
        }

        Label {
            text: model.modified
            textFormat: Text.PlainText
            color: selected ? Theme.highlightColor : Theme.disabledTextColor
            opacity: model.isHidden ? 0.8 : 1.0
        }
    }
}
