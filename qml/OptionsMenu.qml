/*
 * Qt6/Wayland port 2026 - FishUI.DesktopMenu → Menu
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Menu {
    id: control

    MenuItem {
        contentItem: RowLayout {
            spacing: Theme.largeSpacing
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/grid.svg" : "qrc:/images/light/grid.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                smooth: false
            }
            Label { text: qsTr("Icons"); Layout.fillWidth: true }
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/checked.svg" : "qrc:/images/light/checked.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                visible: settings.viewMethod === 1
                smooth: false
            }
        }
        onTriggered: settings.viewMethod = 1
    }

    MenuItem {
        contentItem: RowLayout {
            spacing: Theme.largeSpacing
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/list.svg" : "qrc:/images/light/list.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                smooth: false
            }
            Label { text: qsTr("List"); Layout.fillWidth: true }
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/checked.svg" : "qrc:/images/light/checked.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                visible: settings.viewMethod === 0
                smooth: false
            }
        }
        onTriggered: settings.viewMethod = 0
    }

    MenuSeparator {}

    MenuItem {
        contentItem: RowLayout {
            Label { text: qsTr("Name"); Layout.fillWidth: true; leftPadding: Theme.largeSpacing }
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/checked.svg" : "qrc:/images/light/checked.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                visible: settings.sortMode === 0
                smooth: false
            }
        }
        onTriggered: settings.sortMode = 0
    }

    MenuItem {
        contentItem: RowLayout {
            Label { text: qsTr("Date"); Layout.fillWidth: true; leftPadding: Theme.largeSpacing }
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/checked.svg" : "qrc:/images/light/checked.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                visible: settings.sortMode === 2
                smooth: false
            }
        }
        onTriggered: settings.sortMode = 2
    }

    MenuItem {
        contentItem: RowLayout {
            Label { text: qsTr("Type"); Layout.fillWidth: true; leftPadding: Theme.largeSpacing }
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/checked.svg" : "qrc:/images/light/checked.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                visible: settings.sortMode === 6
                smooth: false
            }
        }
        onTriggered: settings.sortMode = 6
    }

    MenuItem {
        contentItem: RowLayout {
            Label { text: qsTr("Size"); Layout.fillWidth: true; leftPadding: Theme.largeSpacing }
            Image {
                source: Theme.darkMode ? "qrc:/images/dark/checked.svg" : "qrc:/images/light/checked.svg"
                sourceSize: Qt.size(22, 22)
                width: 22; height: 22
                visible: settings.sortMode === 1
                smooth: false
            }
        }
        onTriggered: settings.sortMode = 1
    }
}
