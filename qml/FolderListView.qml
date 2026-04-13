/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.Theme/Units → Theme singleton
 */

import QtQuick
import QtQuick.Controls

import Cutefish.FileManager 1.0 as FM
import Cutefish.DragDrop 1.0 as DragDrop

ListView {
    id: control

    property int itemHeight: Theme.fontHeight * 2 + Theme.largeSpacing
    property Item hoveredItem: null
    property Item pressedItem: null
    property int lastPressedIndex: -1
    property Item editor: null
    property Item rubberBand: null

    property bool ctrlPressed: false
    property bool shiftPressed: false
    property int anchorIndex: 0

    property int dragX: -1
    property int dragY: -1
    property int verticalDropHitscanOffset: 0

    property var cachedRectangleSelection: null
    property point cPress: Qt.point(-1, -1)
    property int pressX: -1
    property int pressY: -1
    property var positioner: null

    ScrollBar.vertical: ScrollBar {}

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Control)  ctrlPressed = true
        else if (event.key === Qt.Key_Shift) { shiftPressed = true; anchorIndex = currentIndex }
    }

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Control)  ctrlPressed = false
        else if (event.key === Qt.Key_Shift) { shiftPressed = false; anchorIndex = 0 }
    }

    Keys.onEscapePressed: {
        if (!editor || !editor.targetItem) {
            dirModel.clearSelection()
            event.accepted = false
        }
    }

    Keys.onUpPressed: {
        if (!editor || !editor.targetItem) {
            var idx = Math.max(0, currentIndex - 1)
            currentIndex = idx
            updateSelection(event.modifiers)
        }
    }

    Keys.onDownPressed: {
        if (!editor || !editor.targetItem) {
            var idx = Math.min(control.count - 1, currentIndex + 1)
            currentIndex = idx
            updateSelection(event.modifiers)
        }
    }

    onCachedRectangleSelectionChanged: {
        if (cachedRectangleSelection === null) return
        dirModel.updateSelection(cachedRectangleSelection, control.ctrlPressed)
    }

    onContentYChanged: cancelRename()

    DragDrop.DropArea {
        anchors.fill: parent
        onDrop: (event) => control.drop(control, event, mapToItem(control, event.x, event.y))
    }

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        propagateComposedEvents: true
        preventStealing: true
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        z: -1

        onDoubleClicked: (mouse) => {
            console.log("doubleClicked button=" + mouse.button + " lastPressedIndex=" + control.lastPressedIndex)
            if (mouse.button === Qt.LeftButton && control.lastPressedIndex >= 0) {
                dirModel.setSelected(control.lastPressedIndex)
                dirModel.openSelected()
            }
        }

        onPressed: (mouse) => {
            console.log("onPressed x=" + mouse.x + " y=" + mouse.y)
            control.forceActiveFocus()

            if (control.editor && childAt(mouse.x, mouse.y) !== control.editor)
                control.editor.commit()

            pressX = mouse.x
            pressY = mouse.y

            var item = control.itemAt(mouse.x, mouse.y + control.contentY)

            if (!item || item.blank) {
                if (!control.ctrlPressed) {
                    control.currentIndex = -1
                    dirModel.clearSelection()
                }
                if (mouse.buttons & Qt.RightButton) {
                    clearPressState()
                    dirModel.openContextMenu(null, mouse.modifiers)
                    mouse.accepted = true
                }
            } else {
                control.hoveredItem = item
                pressedItem = item
                control.lastPressedIndex = pressedItem ? pressedItem.index : -1
                console.log("pressed lastPressedIndex=" + control.lastPressedIndex + " item=" + item)

                if (control.shiftPressed && control.currentIndex !== -1) {
                    dirModel.setRangeSelected(control.anchorIndex, item.index)
                } else {
                    if (!control.ctrlPressed && !dirModel.isSelected(item.index))
                        dirModel.clearSelection()
                    if (control.ctrlPressed) dirModel.toggleSelected(item.index)
                    else dirModel.setSelected(item.index)
                }

                control.currentIndex = item.index

                if (mouse.buttons & Qt.RightButton) {
                    clearPressState()
                    dirModel.openContextMenu(null, mouse.modifiers)
                    mouse.accepted = true
                }
            }
        }

        onPositionChanged: (mouse) => {
            control.ctrlPressed = (mouse.modifiers & Qt.ControlModifier)
            control.shiftPressed = (mouse.modifiers & Qt.ShiftModifier)

            var item = control.itemAt(mouse.x, mouse.y + control.contentY)
            control.hoveredItem = (item && !item.blank) ? item : null

            if (pressX !== -1 && pressedItem !== null && dirModel.isSelected(pressedItem.index)) {
                control.dragX = mouse.x
                control.dragY = mouse.y
                control.verticalDropHitscanOffset = pressedItem.y + pressedItem.height / 2
                dirModel.dragSelected(mouse.x, mouse.y)
                control.dragX = -1; control.dragY = -1
                clearPressState()
            }
        }

        onContainsMouseChanged: {
            if (!containsMouse) {
                clearPressState()
                control.hoveredItem = null
            }
        }

        onReleased: (mouse) => {
            if (pressedItem !== null && !control.shiftPressed &&
                    !control.ctrlPressed && !dirModel.dragging) {
                dirModel.clearSelection()
                dirModel.setSelected(pressedItem.index)
            }
            pressCanceled()
        }

        onCanceled: pressCanceled()
    }

    function pressCanceled() {
        clearPressState()
    }

    function clearPressState() {
        pressedItem = null
        pressX = -1; pressY = -1
    }

    function updateSelection(modifier) {
        if (modifier & Qt.ShiftModifier)
            dirModel.setRangeSelected(anchorIndex, currentIndex)
        else {
            dirModel.clearSelection()
            dirModel.setSelected(currentIndex)
        }
    }

    function rename() {
        if (currentIndex >= 0) {
            var item = control.itemAtIndex(currentIndex)
            if (item) {
                editor = editorComponent.createObject(control)
                editor.targetItem = item
            }
        }
    }

    function cancelRename() {
        if (editor) editor.cancel()
    }

    function reset() {
        control.currentIndex = -1
    }

    Component {
        id: editorComponent

        TextField {
            id: _editor
            visible: false
            wrapMode: Text.NoWrap
            verticalAlignment: TextEdit.AlignVCenter
            z: 999
            selectByMouse: true

            background: Item {
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: Theme.smallSpacing
                    anchors.bottomMargin: Theme.smallSpacing
                    radius: Theme.smallRadius
                    color: Theme.backgroundColor
                }
            }

            property Item targetItem: null

            onTargetItemChanged: {
                if (targetItem !== null) {
                    var pos = control.mapFromItem(targetItem, targetItem.labelArea.x, targetItem.labelArea.y)
                    width = targetItem.labelArea.width
                    height = Theme.fontHeight + Theme.largeSpacing * 2
                    x = control.mapFromItem(targetItem.labelArea, 0, 0).x
                    y = pos.y + (targetItem.height - height) / 2
                    text = targetItem.labelArea.text
                    targetItem.labelArea.visible = false
                    targetItem.labelArea2.visible = false
                    _editor.select(0, dirModel.fileExtensionBoundary(targetItem.index))
                    visible = true
                    control.interactive = false
                } else {
                    visible = false
                    control.interactive = true
                }
            }

            onVisibleChanged: {
                if (visible) _editor.forceActiveFocus()
                else control.forceActiveFocus()
            }

            Keys.onPressed: (event) => {
                switch (event.key) {
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    commit(); event.accepted = true; break
                case Qt.Key_Escape:
                    cancel(); event.accepted = true; break
                }
            }

            function commit() {
                if (targetItem) {
                    targetItem.labelArea.visible = true
                    targetItem.labelArea2.visible = true
                    dirModel.rename(targetItem.index, text)
                    control.currentIndex = targetItem.index
                    targetItem = null
                    control.editor.destroy()
                    control.editor = null
                }
            }

            function cancel() {
                if (targetItem) {
                    targetItem.labelArea.visible = true
                    targetItem.labelArea2.visible = true
                    control.currentIndex = targetItem.index
                    targetItem = null
                    control.editor.destroy()
                    control.editor = null
                }
            }
        }
    }
}
