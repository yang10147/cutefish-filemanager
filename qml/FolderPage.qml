/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.DesktopMenu  → Menu
 * FishUI.BusyIndicator → BusyIndicator
 * FishUI.AboutDialog  → Dialog
 * FishUI.Theme/Units  → Theme singleton
 * image://icontheme   → 保留（KDE 环境支持）
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform

import Cutefish.FileManager 1.0 as FM

import "./Dialogs"

Item {
    id: folderPage

    property alias currentUrl: dirModel.url
    property alias model: dirModel
    property Item currentView: _viewLoader.item
    property int statusBarHeight: 22

    signal requestPathEditor()

    onCurrentUrlChanged: {
        if (!_viewLoader.item)
            return
        _viewLoader.item.reset()
        _viewLoader.item.forceActiveFocus()
    }

    // Global Menu
    Platform.MenuBar {
        Platform.Menu {
            title: qsTr("File")
            Platform.MenuItem { text: qsTr("New Folder");  onTriggered: dirModel.newFolder() }
            Platform.MenuSeparator {}
            Platform.MenuItem { text: qsTr("Properties"); onTriggered: dirModel.openPropertiesDialog() }
            Platform.MenuSeparator {}
            Platform.MenuItem { text: qsTr("Quit");       onTriggered: root.close() }
        }
        Platform.Menu {
            title: qsTr("Edit")
            Platform.MenuItem { text: qsTr("Select All"); onTriggered: dirModel.selectAll() }
            Platform.MenuSeparator {}
            Platform.MenuItem { text: qsTr("Cut");        onTriggered: dirModel.cut() }
            Platform.MenuItem { text: qsTr("Copy");       onTriggered: dirModel.copy() }
            Platform.MenuItem { text: qsTr("Paste");      onTriggered: dirModel.paste() }
        }
        Platform.Menu {
            title: qsTr("Help")
            Platform.MenuItem { text: qsTr("About"); onTriggered: _aboutDialog.open() }
        }
    }

    // About dialog（替代 FishUI.AboutDialog）
    Dialog {
        id: _aboutDialog
        title: qsTr("About File Manager")
        modal: true
        anchors.centerIn: parent

        Label {
            text: qsTr("File Manager\nA file manager designed for CutefishOS.")
            wrapMode: Text.Wrap
        }

        standardButtons: Dialog.Ok
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        anchors.rightMargin: 1
        radius: Theme.mediumRadius
        color: Theme.secondBackgroundColor
    }

    Label {
        id: _fileTips
        text: qsTr("Empty folder")
        font.pointSize: 15
        anchors.centerIn: parent
        visible: dirModel.status === FM.FolderModel.Ready
                 && _viewLoader.status === Loader.Ready
                 && _viewLoader.item.count === 0
    }

    FM.FolderModel {
        id: dirModel
        viewAdapter: viewAdapter
        sortMode: settings.sortMode

        Component.onCompleted: {
            if (arg)
                dirModel.url = arg
            else
                dirModel.url = dirModel.homePath()
        }

        onCurrentIndexChanged: {
            _viewLoader.item.currentIndex = dirModel.currentIndex
        }
    }

    Connections {
        target: dirModel

        function onNotification(text) {
            // 简单用 ToolTip 显示通知
            notificationTimer.stop()
            notificationLabel.text = text
            notificationLabel.visible = true
            notificationTimer.start()
        }

        function onScrollToItem(index) {
            _viewLoader.item.currentIndex = index
        }
    }

    // 通知条
    Label {
        id: notificationLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        padding: 6
        visible: false
        z: 999
        background: Rectangle {
            color: Theme.highlightColor
            radius: Theme.smallRadius
        }
        color: Theme.highlightedTextColor
        Timer {
            id: notificationTimer
            interval: 3000
            onTriggered: notificationLabel.visible = false
        }
    }

    FM.ItemViewAdapter {
        id: viewAdapter
        adapterView: _viewLoader.item
        adapterModel: _viewLoader.item && _viewLoader.item.positioner
                      ? _viewLoader.item.positioner : dirModel
        adapterIconSize: 40
        adapterVisibleArea: _viewLoader.item
                            ? Qt.rect(_viewLoader.item.contentX, _viewLoader.item.contentY,
                                      _viewLoader.item.contentWidth, _viewLoader.item.contentHeight)
                            : Qt.rect(0, 0, 0, 0)
    }

    // 右键菜单（空白区域）
    Menu {
        id: folderMenu

        MenuItem {
            text: qsTr("Open")
            onTriggered: dirModel.openSelected()
        }
        MenuItem {
            text: qsTr("Properties")
            onTriggered: dirModel.openPropertiesDialog()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: 2
        spacing: 0

        Loader {
            id: _viewLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            asynchronous: true
            sourceComponent: {
                switch (settings.viewMethod) {
                    case 0: return _listViewComponent
                    case 1: return _gridViewComponent
                }
            }

            onSourceComponentChanged: {
                if (_viewLoader.item) {
                    _viewLoader.item.forceActiveFocus()
                    shortCut.install(_viewLoader.item)
                }
            }
        }

        // 状态栏占位
        Item {
            height: statusBarHeight
        }
    }

    // 状态栏
    Item {
        id: _statusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: statusBarHeight
        z: 999

        MouseArea { anchors.fill: parent }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.smallSpacing
            anchors.rightMargin: Theme.smallSpacing
            spacing: Theme.largeSpacing

            Label {
                font.pointSize: 10
                text: dirModel.count === 1
                      ? qsTr("%1 item").arg(dirModel.count)
                      : qsTr("%1 items").arg(dirModel.count)
            }

            Label {
                font.pointSize: 10
                text: qsTr("%1 selected").arg(dirModel.selectionCount)
                visible: dirModel.selectionCount >= 1
            }

            BusyIndicator {
                height: statusBarHeight
                width: height
                running: visible
                visible: dirModel.status === FM.FolderModel.Listing
            }

            Label {
                text: dirModel.selectedItemSize
                visible: dirModel.url !== "trash:///"
            }

            Item { Layout.fillWidth: true }

            Button {
                implicitHeight: statusBarHeight
                text: qsTr("Empty Trash")
                font.pointSize: 10
                onClicked: dirModel.emptyTrash()
                visible: dirModel.url === "trash:///"
                         && _viewLoader.item
                         && _viewLoader.item.count > 0
                focusPolicy: Qt.NoFocus
            }
        }
    }

    function rename() {
        _viewLoader.item.rename()
    }

    Component.onCompleted: {
        dirModel.requestRename.connect(rename)
    }

    Component {
        id: _gridViewComponent

        FolderGridView {
            model: dirModel
            delegate: FolderGridItem {}

            leftMargin: Theme.smallSpacing
            rightMargin: Theme.largeSpacing
            topMargin: 0
            bottomMargin: Theme.smallSpacing

            onIconSizeUpdated: settings.gridIconSize = iconSize
            onCountChanged: _fileTips.visible = count === 0
        }
    }

    Component {
        id: _listViewComponent

        FolderListView {
            model: dirModel

            topMargin: Theme.smallSpacing
            leftMargin: Theme.largeSpacing
            rightMargin: Theme.largeSpacing
            bottomMargin: Theme.smallSpacing
            spacing: Theme.largeSpacing

            onCountChanged: _fileTips.visible = count === 0
            delegate: FolderListItem {}
        }
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

    FM.ShortCut {
        id: shortCut
        onOpen:           dirModel.openSelected()
        onCopy:           dirModel.copy()
        onCut:            dirModel.cut()
        onPaste:          dirModel.paste()
        onRename:         dirModel.requestRename()
        onOpenPathEditor: folderPage.requestPathEditor()
        onSelectAll:      dirModel.selectAll()
        onBackspace:      dirModel.up()
        onDeleteFile:     dirModel.keyDeletePress()
        onRefresh:        dirModel.refresh()
        onKeyPressed: (text) => dirModel.keyboardSearch(text)
        onShowHidden:     dirModel.showHiddenFiles = !dirModel.showHiddenFiles
        onClose:          root.close()
        onUndo:           dirModel.undo()
    }

    function openUrl(url) {
        dirModel.url = url
        if (_viewLoader.item)
            _viewLoader.item.forceActiveFocus()
    }

    function goBack()    { dirModel.goBack() }
    function goForward() { dirModel.goForward() }
}
