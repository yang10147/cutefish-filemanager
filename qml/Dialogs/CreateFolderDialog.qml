/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.ActionTextField → TextField
 */

import QtQuick
import "../"
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

Window {
    id: control

    title: qsTr("New folder name")
    flags: Qt.Dialog
    visible: true

    width: 420
    height: _mainLayout.implicitHeight + Theme.largeSpacing * 2

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

        TextField {
            id: _textField
            Layout.fillWidth: true
            text: qsTr("New folder")
            focus: true
            selectByMouse: true

            Keys.onEscapePressed: control.close()
            onAccepted: {
                main.newFolder(_textField.text)
                control.close()
            }

            Component.onCompleted: _textField.selectAll()
        }

        RowLayout {
            spacing: Theme.largeSpacing

            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: control.close()
            }

            Button {
                text: qsTr("OK")
                Layout.fillWidth: true
                enabled: _textField.text.length > 0
                highlighted: true
                onClicked: {
                    main.newFolder(_textField.text)
                    control.close()
                }
            }
        }
    }
}
