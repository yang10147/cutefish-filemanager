/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.IconItem → Image with icontheme
 */

import QtQuick
import "../"
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

Item {
    id: control

    property int widthValue: _mainLayout.implicitWidth + Theme.largeSpacing * 3
    property int heightValue: _mainLayout.implicitHeight + Theme.largeSpacing * 3

    width: widthValue
    height: heightValue

    onWidthValueChanged:  main.updateSize(widthValue, heightValue)
    onHeightValueChanged: main.updateSize(widthValue, heightValue)

    focus: true
    Keys.enabled: true
    Keys.onEscapePressed: main.reject()

    Rectangle {
        anchors.fill: parent
        color: Theme.secondBackgroundColor
    }

    onVisibleChanged: {
        if (visible && _textField.enabled)
            _textField.forceActiveFocus()
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.largeSpacing * 1.5
        anchors.rightMargin: Theme.largeSpacing * 1.5
        anchors.topMargin: Theme.smallSpacing
        anchors.bottomMargin: Theme.largeSpacing * 1.5
        spacing: Theme.largeSpacing

        RowLayout {
            spacing: Theme.largeSpacing * 2

            // FishUI.IconItem → Image
            Image {
                width: 64; height: 64
                sourceSize: Qt.size(64, 64)
                source: "image://icontheme/" + main.iconName
                smooth: true
                antialiasing: true
            }

            TextField {
                id: _textField
                text: main.fileName
                focus: true
                Layout.fillWidth: true
                selectByMouse: true
                Keys.onEscapePressed: main.reject()
                enabled: main.isWritable
            }
        }

        GridLayout {
            columns: 2
            columnSpacing: Theme.largeSpacing
            rowSpacing: Theme.largeSpacing
            Layout.alignment: Qt.AlignTop

            Label { text: qsTr("Type:");     Layout.alignment: Qt.AlignRight; color: Theme.disabledTextColor; visible: mimeType.visible }
            Label { id: mimeType;            text: main.mimeType;    visible: text.length > 0 }

            Label { text: qsTr("Location:"); Layout.alignment: Qt.AlignRight; color: Theme.disabledTextColor }
            Label { text: main.location }

            Label { text: qsTr("Size:");     Layout.alignment: Qt.AlignRight; color: Theme.disabledTextColor }
            Label { text: main.fileSize ? main.fileSize : qsTr("Calculating...") }

            Label { text: qsTr("Created:");  Layout.alignment: Qt.AlignRight; color: Theme.disabledTextColor; visible: creationTime.visible }
            Label { id: creationTime;        text: main.creationTime; visible: text.length > 0 }

            Label { text: qsTr("Modified:"); Layout.alignment: Qt.AlignRight; color: Theme.disabledTextColor; visible: modifiedTime.visible }
            Label { id: modifiedTime;        text: main.modifiedTime; visible: text.length > 0 }

            Label { text: qsTr("Accessed:"); Layout.alignment: Qt.AlignRight; color: Theme.disabledTextColor; visible: accessTime.visible }
            Label { id: accessTime;          text: main.accessedTime; visible: text.length > 0 }
        }

        Item { height: Theme.smallSpacing }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Theme.largeSpacing

            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: main.reject()
            }

            Button {
                text: qsTr("OK")
                Layout.fillWidth: true
                highlighted: true
                onClicked: main.accept(_textField.text)
            }
        }
    }
}
