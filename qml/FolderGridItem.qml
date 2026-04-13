/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * QtGraphicalEffects → Qt5Compat.GraphicalEffects
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Cutefish.FileManager 1.0

Item {
    id: control

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property Item iconArea: _image.visible ? _image : _icon
    property Item labelArea: _label
    property Item labelArea2: _label  // alias for rename editor compat
    property Item background: _background

    property int index: model.index
    property bool hovered: GridView.view.hoveredItem === control
    property bool selected: model.selected
    property bool blank: model.blank
    property var fileName: model.displayName

    visible: GridView.view.isDesktopView ? !blank : true

    onSelectedChanged: {
        if (!GridView.view.isDesktopView) return
        if (selected && !blank) {
            control.grabToImage(function(result) {
                dirModel.addItemDragImage(control.index,
                    control.x, control.y,
                    control.width, control.height,
                    result.image)
            })
        }
    }

    // 双击打开文件
    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onDoubleTapped: {
            dirModel.setSelected(control.index)
            dirModel.openSelected()
        }
    }

    Rectangle {
        id: _background
        width: Math.max(_iconItem.width, _label.paintedWidth)
        height: _iconItem.height + _label.paintedHeight + Theme.largeSpacing
        x: (parent.width - width) / 2
        y: _iconItem.y
        color: "transparent"
    }

    Item {
        id: _iconItem
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Theme.smallSpacing
        anchors.bottomMargin: Theme.smallSpacing
        z: 2

        width: parent.width - Theme.largeSpacing * 2
        height: control.GridView.view.iconSize
        opacity: model.isHidden ? 0.5 : 1.0

        Image {
            id: _icon
            width: control.GridView.view.iconSize
            height: width
            anchors.centerIn: parent
            sourceSize: Qt.size(width, height)
            source: "image://icontheme/" + model.iconName
            visible: !_image.visible
            smooth: true
            antialiasing: true
        }

        Image {
            id: _image
            anchors.fill: parent
            anchors.margins: Theme.smallSpacing
            fillMode: Image.PreserveAspectFit
            visible: status === Image.Ready
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            sourceSize: Qt.size(width, height)
            source: model.thumbnail ? model.thumbnail : ""
            asynchronous: true
            cache: false
            smooth: true
            antialiasing: true

            layer.enabled: visible
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

        ColorOverlay {
            anchors.fill: _iconItem
            source: _iconItem
            color: Theme.highlightColor
            opacity: 0.5
            visible: control.selected
        }

        ColorOverlay {
            anchors.fill: _iconItem
            source: _iconItem
            color: "white"
            opacity: 0.3
            visible: control.hovered && !control.selected
        }
    }

    Label {
        id: _label
        z: 2
        anchors.top: _iconItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Theme.smallSpacing
        maximumLineCount: control.selected ? 3 : 2
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - Theme.largeSpacing * 2 - Theme.smallSpacing
        textFormat: Text.PlainText
        elide: Qt.ElideRight
        wrapMode: Text.Wrap
        text: control.fileName
        color: control.GridView.view.isDesktopView ? "white"
             : selected ? Theme.highlightColor
             : Theme.textColor
        opacity: model.isHidden ? 0.8 : 1.0
    }

    Rectangle {
        z: 1
        x: _label.x + (_label.width - _label.paintedWidth) / 2 - (Theme.smallSpacing / 2)
        y: _label.y
        width: _label.paintedWidth + Theme.smallSpacing
        height: _label.paintedHeight
        radius: 4
        color: Theme.highlightColor
        opacity: {
            if (control.selected && control.GridView.view.isDesktopView) return 1
            if (control.selected) return 0.2
            if (control.hovered) return 0.05
            return 0
        }
    }

    DropShadow {
        anchors.fill: _label
        source: _label
        z: 1
        horizontalOffset: 1
        verticalOffset: 1
        radius: 4
        samples: radius * 2 + 1
        spread: 0.35
        color: Qt.rgba(0, 0, 0, 0.3)
        opacity: model.isHidden ? 0.6 : 1
        visible: control.GridView.view.isDesktopView && !control.selected
    }
}
