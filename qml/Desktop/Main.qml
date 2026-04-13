/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * Dock margins: Dock C++ 对象仍然存在，保留引用；若不可用则 fallback 0
 */

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Cutefish.FileManager 1.0 as FM
import "../"

Item {
    id: rootItem

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    GlobalSettings { id: globalSettings }

    Wallpaper { anchors.fill: parent }

    FM.FolderModel {
        id: dirModel
        url: desktopPath()
        isDesktop: true
        sortMode: -1
        viewAdapter: viewAdapter

        onCurrentIndexChanged: {
            _folderView.currentIndex = dirModel.currentIndex
        }
    }

    FM.ItemViewAdapter {
        id: viewAdapter
        adapterView: _folderView
        adapterModel: dirModel
        adapterIconSize: 40
        adapterVisibleArea: Qt.rect(_folderView.contentX, _folderView.contentY,
                                    _folderView.contentWidth, _folderView.contentHeight)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: _folderView.forceActiveFocus()
    }

    FolderGridView {
        id: _folderView
        anchors.fill: parent

        isDesktopView: true
        iconSize: globalSettings.desktopIconSize
        maximumIconSize: globalSettings.maximumIconSize
        minimumIconSize: 22
        focus: true
        model: dirModel

        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        topMargin: 28

        // Dock margins — 若 Dock 未定义则使用 0
        leftMargin:   typeof Dock !== "undefined" ? Dock.leftMargin   : 0
        rightMargin:  typeof Dock !== "undefined" ? Dock.rightMargin  : 0
        bottomMargin: typeof Dock !== "undefined" ? Dock.bottomMargin : 0

        flow: GridView.FlowTopToBottom

        delegate: FolderGridItem {}

        onIconSizeUpdated: globalSettings.desktopIconSize = iconSize

        onActiveFocusChanged: {
            if (!activeFocus) {
                _folderView.cancelRename()
                dirModel.clearSelection()
            }
        }

        Component.onCompleted: {
            dirModel.requestRename.connect(rename)
        }
    }

    FM.ShortCut {
        id: shortCut

        Component.onCompleted: shortCut.install(_folderView)

        onOpen:      dirModel.openSelected()
        onCopy:      dirModel.copy()
        onCut:       dirModel.cut()
        onPaste:     dirModel.paste()
        onRename:    dirModel.requestRename()
        onSelectAll: dirModel.selectAll()
        onDeleteFile: dirModel.keyDeletePress()
        onKeyPressed: (text) => dirModel.keyboardSearch(text)
        onShowHidden: dirModel.showHiddenFiles = !dirModel.showHiddenFiles
        onUndo:      dirModel.undo()
    }

    Component {
        id: rubberBandObject

        FM.RubberBand {
            width: 0; height: 0; z: 99999
            color: Theme.highlightColor

            function close() { opacityAnimation.restart() }

            OpacityAnimator {
                id: opacityAnimation
                target: parent
                to: 0; from: 1; duration: 150
                easing { bezierCurve: [0.4, 0.0, 1, 1]; type: Easing.Bezier }
                onFinished: {
                    parent.visible = false
                    parent.enabled = false
                    parent.destroy()
                }
            }
        }
    }
}
