/*
 * Qt6/Wayland port 2026 - FishUI.Window → Window
 */

import QtQuick
import "../"
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

import Cutefish.FileManager 1.0

Window {
    id: control

    title: qsTr("File Manager")
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visible: true

    width: 320
    height: _mainLayout.implicitHeight + Theme.largeSpacing * 2 + 36

    minimumWidth: width;  minimumHeight: height
    maximumWidth: width;  maximumHeight: height

    Rectangle {
        anchors.fill: parent
        color: Theme.secondBackgroundColor
    }

    Fm { id: fm }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: Theme.largeSpacing
        spacing: Theme.largeSpacing

        Label {
            text: qsTr("Do you want to permanently delete all files from the Trash?")
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        RowLayout {
            spacing: Theme.largeSpacing

            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: control.close()
            }

            Button {
                text: qsTr("Empty Trash")
                focus: true
                Layout.fillWidth: true
                highlighted: true
                onClicked: {
                    fm.emptyTrash()
                    control.close()
                }
            }
        }
    }
}
