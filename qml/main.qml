/*
 * Copyright (C) 2021 CutefishOS Team.
 * Qt6/Wayland port 2026 - FishUI.Window → ApplicationWindow
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import "./Controls"

ApplicationWindow {
    id: root
    width: settings.width
    height: settings.height
    minimumWidth: 900
    minimumHeight: 580
    visible: true
    title: qsTr("File Manager")

    // 系统原生标题栏，无需自定义 header

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property QtObject settings: GlobalSettings {}

    // 保存窗口尺寸
    onClosing: {
        if (root.visibility !== Window.Maximized &&
                root.visibility !== Window.FullScreen) {
            settings.width = root.width
            settings.height = root.height
        }
    }

    // 工具栏（原 headerItem）
    header: ToolBar {
        height: 44
        background: Rectangle {
            color: Theme.secondBackgroundColor
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.smallSpacing * 1.5
            anchors.rightMargin: Theme.smallSpacing * 1.5
            anchors.topMargin: Theme.smallSpacing
            anchors.bottomMargin: Theme.smallSpacing
            spacing: Theme.smallSpacing

            // 后退
            IconButton {
                Layout.fillHeight: true
                implicitWidth: height
                source: Theme.darkMode ? "qrc:/images/dark/go-previous.svg"
                                       : "qrc:/images/light/go-previous.svg"
                onClicked: _folderPage.goBack()
            }

            // 前进
            IconButton {
                Layout.fillHeight: true
                implicitWidth: height
                source: Theme.darkMode ? "qrc:/images/dark/go-next.svg"
                                       : "qrc:/images/light/go-next.svg"
                onClicked: _folderPage.goForward()
            }

            // 路径栏
            PathBar {
                id: _pathBar
                Layout.fillWidth: true
                Layout.fillHeight: true
                onItemClicked: (path) => _folderPage.openUrl(path)
                onEditorAccepted: (path) => _folderPage.openUrl(path)
            }

            // 视图切换 + 选项菜单
            IconButton {
                Layout.fillHeight: true
                implicitWidth: height
                source: settings.viewMethod === 0
                        ? (Theme.darkMode ? "qrc:/images/dark/list.svg" : "qrc:/images/light/list.svg")
                        : (Theme.darkMode ? "qrc:/images/dark/grid.svg" : "qrc:/images/light/grid.svg")
                onClicked: optionsMenu.popup()
            }
        }
    }

    OptionsMenu {
        id: optionsMenu
    }

    // 主体内容
    RowLayout {
        anchors.fill: parent
        spacing: 0

        SideBar {
            id: _sideBar
            Layout.fillHeight: true
            width: 188
            onClicked: (path) => _folderPage.openUrl(path)
            onOpenInNewWindow: (path) => _folderPage.model.openInNewWindow(path)
        }

        // 分隔线
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: Theme.darkMode ? Qt.rgba(1,1,1,0.08) : Qt.rgba(0,0,0,0.08)
        }

        FolderPage {
            id: _folderPage
            Layout.fillWidth: true
            Layout.fillHeight: true
            onCurrentUrlChanged: {
                _sideBar.updateSelection(currentUrl)
                _pathBar.updateUrl(currentUrl)
            }
            onRequestPathEditor: _pathBar.openEditor()
        }
    }
}
