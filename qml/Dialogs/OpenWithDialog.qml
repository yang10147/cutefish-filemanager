/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.IconItem → Image with icontheme
 * FishUI.Theme/Units → Theme singleton
 */

import QtQuick
import "../"
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: control

    property string url: main.url

    width: 420
    height: _mainLayout.implicitHeight + Theme.largeSpacing * 2

    Rectangle {
        anchors.fill: parent
        color: Theme.secondBackgroundColor
    }

    Component.onCompleted: {
        var items = mimeAppManager.recommendedApps(control.url)
        for (var i in items) {
            listView.model.append(items[i])
        }
        defaultCheckBox.checked = false
        doneButton.focus = true
    }

    function openApp() {
        if (defaultCheckBox.checked)
            mimeAppManager.setDefaultAppForFile(control.url,
                listView.model.get(listView.currentIndex).desktopFile)
        launcher.launchApp(listView.model.get(listView.currentIndex).desktopFile, control.url)
        main.close()
    }

    Keys.enabled: true
    Keys.onEscapePressed: main.close()

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        spacing: 0

        GridView {
            id: listView
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            model: ListModel {}
            clip: true
            ScrollBar.vertical: ScrollBar {}

            leftMargin: Theme.smallSpacing
            rightMargin: Theme.smallSpacing

            cellHeight: {
                var extra = calcExtraSpacing(80, Layout.preferredHeight)
                return 80 + extra
            }
            cellWidth: {
                var extra = calcExtraSpacing(120, listView.width - leftMargin - rightMargin)
                return 120 + extra
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No applications")
                visible: listView.count === 0
            }

            delegate: Item {
                id: item
                width: GridView.view.cellWidth
                height: GridView.view.cellHeight
                scale: mouseArea.pressed ? 0.95 : 1.0

                Behavior on scale { NumberAnimation { duration: 100 } }

                property bool isSelected: listView.currentIndex === index

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onDoubleClicked: control.openApp()
                    onClicked: listView.currentIndex = index
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Theme.smallSpacing
                    radius: Theme.mediumRadius
                    color: isSelected ? Theme.highlightColor
                         : mouseArea.containsMouse
                           ? Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b, 0.1)
                           : "transparent"
                    smooth: true
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.smallSpacing
                    spacing: Theme.smallSpacing

                    Image {
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 36
                        Layout.alignment: Qt.AlignHCenter
                        sourceSize: Qt.size(36, 36)
                        source: "image://icontheme/" + model.icon
                        smooth: true
                        antialiasing: true
                    }

                    Label {
                        text: model.name
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        color: isSelected ? Theme.highlightedTextColor : Theme.textColor
                    }
                }
            }
        }

        CheckBox {
            id: defaultCheckBox
            focusPolicy: Qt.NoFocus
            text: qsTr("Set as default")
            enabled: listView.count >= 1
            padding: 0
            Layout.leftMargin: Theme.largeSpacing
            Layout.bottomMargin: Theme.largeSpacing
        }

        RowLayout {
            spacing: Theme.largeSpacing
            Layout.leftMargin: Theme.largeSpacing
            Layout.rightMargin: Theme.largeSpacing
            Layout.bottomMargin: Theme.largeSpacing

            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: main.close()
            }

            Button {
                id: doneButton
                focus: true
                highlighted: true
                text: qsTr("Open")
                enabled: listView.count > 0
                Layout.fillWidth: true
                onClicked: control.openApp()
            }
        }
    }

    function calcExtraSpacing(cellSize, containerSize) {
        var available = Math.floor(containerSize / cellSize)
        if (available <= 0) return 0
        var extra = Math.max(containerSize - available * cellSize, 0)
        return Math.floor(extra / available)
    }
}
