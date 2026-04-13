/*
 * Qt6/Wayland port 2026 - FishUI.Window → Window
 */

import QtQuick
import "../"
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

Window {
    id: control

    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visible: true
    title: qsTr("Delete")

    width: _mainLayout.implicitWidth + Theme.largeSpacing * 2
    height: _mainLayout.implicitHeight + Theme.largeSpacing * 2 + 36  // 36 = approx title bar

    minimumWidth: width;  minimumHeight: height
    maximumWidth: width;  maximumHeight: height

    Rectangle {
        anchors.fill: parent
        color: Theme.secondBackgroundColor
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: Theme.largeSpacing
        spacing: Theme.largeSpacing

        Label {
            text: qsTr("Do you want to delete it permanently?")
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
                text: qsTr("Delete")
                focus: true
                Layout.fillWidth: true
                highlighted: true
                onClicked: {
                    control.close()
                    model.deleteSelected()
                }
            }
        }
    }
}
