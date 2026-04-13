/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.WheelHandler → WheelHandler (Qt6 内置)
 * FishUI.DesktopMenu  → Menu
 * FishUI.Theme/Units  → Theme singleton
 * QtGraphicalEffects  → Qt5Compat.GraphicalEffects
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Cutefish.FileManager 1.0

ListView {
    id: sideBar

    signal clicked(string path)
    signal openInNewWindow(string path)

    // Qt6 内置 WheelHandler
    WheelHandler {
        target: sideBar
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Fm {
        id: _fm
    }

    PlacesModel {
        id: placesModel
        onDeviceSetupDone: (filePath) => sideBar.clicked(filePath)
    }

    model: placesModel
    clip: true

    leftMargin: Theme.smallSpacing * 1.5
    rightMargin: Theme.smallSpacing * 1.5
    bottomMargin: Theme.smallSpacing
    spacing: Theme.smallSpacing

    ScrollBar.vertical: ScrollBar {
        bottomPadding: Theme.smallSpacing
    }

    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    highlightResizeDuration: 0

    highlight: Rectangle {
        radius: Theme.mediumRadius
        color: Theme.secondBackgroundColor
        smooth: true

        Rectangle {
            anchors.fill: parent
            radius: Theme.mediumRadius
            color: Qt.rgba(Theme.highlightColor.r,
                           Theme.highlightColor.g,
                           Theme.highlightColor.b,
                           Theme.darkMode ? 0.3 : 0.2)
        }
    }

    section.property: "category"
    section.delegate: Item {
        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        height: Theme.fontHeight + Theme.largeSpacing + Theme.smallSpacing

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: Qt.application.layoutDirection === Qt.RightToLeft ? 0 : Theme.smallSpacing
            anchors.topMargin: Theme.largeSpacing
            color: Theme.textColor
            font.pointSize: 9
            font.bold: true
            text: section
        }
    }

    delegate: Item {
        id: _item
        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        height: Theme.fontHeight + Theme.largeSpacing * 1.5

        property bool checked: sideBar.currentIndex === index
        property color hoveredColor: Theme.darkMode
                                     ? Qt.lighter(Theme.backgroundColor, 1.1)
                                     : Qt.darker(Theme.backgroundColor, 1.1)

        MouseArea {
            id: _mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (model.isDevice && model.setupNeeded)
                        placesModel.requestSetup(index)
                    else
                        sideBar.clicked(model.path ? model.path : model.url)
                } else if (mouse.button === Qt.RightButton) {
                    _menu.popup()
                }
            }
        }

        Menu {
            id: _menu

            MenuItem {
                text: qsTr("Open")
                onTriggered: {
                    if (model.isDevice && model.setupNeeded)
                        placesModel.requestSetup(index)
                    else
                        sideBar.clicked(model.path ? model.path : model.url)
                }
            }

            MenuItem {
                text: qsTr("Open in new window")
                onTriggered: sideBar.openInNewWindow(model.path ? model.path : model.url)
            }

            MenuSeparator {
                visible: _ejectMenuItem.visible || _umountMenuItem.visible
            }

            MenuItem {
                id: _ejectMenuItem
                text: qsTr("Eject")
                visible: model.isDevice && !model.setupNeeded &&
                         model.isOpticalDisc && !model.url.toString() === _fm.rootPath()
                onTriggered: placesModel.requestEject(index)
            }

            MenuItem {
                id: _umountMenuItem
                text: qsTr("Unmount")
                visible: model.isDevice && !model.setupNeeded &&
                         !model.isOpticalDisc && !model.url.toString() === _fm.rootPath()
                onTriggered: placesModel.requestTeardown(index)
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.mediumRadius
            color: _mouseArea.pressed
                   ? Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b,
                             Theme.darkMode ? 0.05 : 0.1)
                   : (_mouseArea.containsMouse && !checked)
                     ? Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b,
                               Theme.darkMode ? 0.1 : 0.05)
                     : "transparent"
            smooth: true
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.smallSpacing
            anchors.rightMargin: Theme.smallSpacing
            spacing: Theme.smallSpacing

            Image {
                height: 22
                width: height
                sourceSize: Qt.size(22, 22)
                source: "qrc:/images/" + model.iconPath
                Layout.alignment: Qt.AlignVCenter
                smooth: false
                antialiasing: true

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: checked ? Theme.highlightColor : Theme.textColor
                }
            }

            Label {
                text: model.name
                color: checked ? Theme.highlightColor : Theme.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    function updateSelection(path) {
        sideBar.currentIndex = -1
        for (var i = 0; i < sideBar.count; ++i) {
            if (path === sideBar.model.get(i).path ||
                    path === sideBar.model.get(i).url) {
                sideBar.currentIndex = i
                break
            }
        }
    }
}
