/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 * FishUI.Theme/Units → Theme singleton
 */

import QtQuick
import QtQuick.Controls

import Cutefish.FileManager 1.0 as FM
import Cutefish.DragDrop 1.0 as DragDrop

GridView {
    id: control

    property bool isDesktopView: false
    property int iconSize: settings ? settings.gridIconSize : 64
    property int maximumIconSize: settings ? settings.maximumIconSize : 256
    property int minimumIconSize: settings ? settings.minimumIconSize : 64

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

    signal iconSizeUpdated(int size)

    cellWidth: {
        var extra = calcExtraSpacing(iconSize + Theme.largeSpacing * 2,
                                     width - leftMargin - rightMargin)
        return iconSize + Theme.largeSpacing * 2 + extra
    }

    cellHeight: iconSize + Theme.fontHeight * 2 + Theme.largeSpacing * 3

    ScrollBar.vertical: ScrollBar {}

    // Pinch zoom
    PinchArea {
        anchors.fill: parent
        enabled: true
        z: -1

        onPinchUpdated: (pinch) => {
            var newSize = control.iconSize + pinch.scale - 1
            newSize = Math.max(control.minimumIconSize, Math.min(control.maximumIconSize, newSize))
            if (newSize !== control.iconSize) {
                control.iconSize = newSize
                control.iconSizeUpdated(newSize)
            }
        }
    }

    // Wheel zoom (Ctrl+scroll)
    WheelHandler {
        acceptedModifiers: Qt.ControlModifier
        onWheel: (event) => {
            var delta = event.angleDelta.y > 0 ? 8 : -8
            var newSize = Math.max(control.minimumIconSize,
                                   Math.min(control.maximumIconSize, control.iconSize + delta))
            if (newSize !== control.iconSize) {
                control.iconSize = newSize
                control.iconSizeUpdated(newSize)
            }
        }
    }

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

    onCachedRectangleSelectionChanged: {
        if (cachedRectangleSelection === null) return
        if (cachedRectangleSelection.length) control.currentIndex[0]
        dirModel.updateSelection(cachedRectangleSelection, control.ctrlPressed)
    }

    onContentXChanged: cancelRename()
    onContentYChanged: cancelRename()

    onPressXChanged: cPress = mapToItem(control.contentItem, pressX, pressY)
    onPressYChanged: cPress = mapToItem(control.contentItem, pressX, pressY)

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
            if (mouse.button === Qt.LeftButton && control.lastPressedIndex >= 0) {
                dirModel.setSelected(control.lastPressedIndex)
                dirModel.openSelected()
            }
        }

        onPressed: (mouse) => {
            control.forceActiveFocus()

            if (control.editor && childAt(mouse.x, mouse.y) !== control.editor)
                control.editor.commit()

            pressX = mouse.x
            pressY = mouse.y

            var item = control.itemAt(mouse.x - control.leftMargin,
                                      mouse.y + control.contentY - control.topMargin)

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

            var cPos = mapToItem(control.contentItem, mouse.x, mouse.y)
            var item = control.itemAt(mouse.x - control.leftMargin,
                                      mouse.y + control.contentY - control.topMargin)

            control.hoveredItem = (item && !item.blank) ? item : null

            if (control.rubberBand) {
                var rB = control.rubberBand
                var leftEdge = Math.min(control.contentX, control.originX)

                if (cPos.x < cPress.x) {
                    rB.x = Math.max(leftEdge, cPos.x)
                    rB.width = Math.abs(rB.x - cPress.x)
                } else {
                    rB.x = cPress.x
                    rB.width = Math.min(Math.max(control.width, control.contentItem.width) + leftEdge - rB.x,
                                        Math.abs(rB.x - cPos.x))
                }
                if (cPos.y < cPress.y) {
                    rB.y = Math.max(0, cPos.y)
                    rB.height = Math.abs(rB.y - cPress.y)
                } else {
                    rB.y = cPress.y
                    rB.height = Math.min(Math.max(control.height, control.contentItem.height) - rB.y,
                                         Math.abs(rB.y - cPos.y))
                }
                rB.width = Math.max(1, rB.width)
                rB.height = Math.max(1, rB.height)
                control.rectangleSelect(rB.x, rB.y, rB.width, rB.height)
                return
            }

            if (pressX !== -1) {
                if (pressedItem !== null && dirModel.isSelected(pressedItem.index)) {
                    control.dragX = mouse.x
                    control.dragY = mouse.y
                    control.verticalDropHitscanOffset = pressedItem.y + pressedItem.height / 2
                    dirModel.dragSelected(mouse.x, mouse.y)
                    control.dragX = -1; control.dragY = -1
                    clearPressState()
                } else {
                    if (control.editor && control.editor.targetItem) return
                    dirModel.pinSelection()
                    control.rubberBand = rubberBandObject.createObject(control.contentItem,
                        {x: cPress.x, y: cPress.y})
                    control.interactive = false
                }
            }
        }

        onContainsMouseChanged: {
            if (!containsMouse && !control.rubberBand) {
                clearPressState()
                control.hoveredItem = null
            }
        }

        onReleased: (mouse) => {
            if (pressedItem !== null && !control.rubberBand &&
                    !control.shiftPressed && !control.ctrlPressed && !dirModel.dragging) {
                dirModel.clearSelection()
                dirModel.setSelected(pressedItem.index)
            }
            pressCanceled()
        }

        onCanceled: pressCanceled()
    }

    function pressCanceled() {
        if (control.rubberBand) {
            control.rubberBand.close()
            control.rubberBand = null
            control.interactive = true
            control.cachedRectangleSelection = null
            dirModel.unpinSelection()
        }
        clearPressState()
    }

    function clearPressState() {
        pressedItem = null
        pressX = -1; pressY = -1
    }

    function rectangleSelect(x, y, w, h) {
        var indexes = []
        for (var i = y; i <= y + h; i += 10) {
            var idx = control.indexAt(control.leftMargin, i)
            if (!indexes.includes(idx) && idx > -1 && idx < control.count)
                indexes.push(idx)
        }
        cachedRectangleSelection = indexes
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
        if (editor) {
            editor.cancel()
        }
    }

    function reset() {
        control.currentIndex = -1
    }

    function calcExtraSpacing(cellSize, containerSize) {
        var avail = Math.floor(containerSize / cellSize)
        if (avail <= 0) return 0
        return Math.floor(Math.max(containerSize - avail * cellSize, 0) / avail)
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
                    control.currentIndex = targetItem.index
                    targetItem = null
                    control.editor.destroy()
                    control.editor = null
                }
            }
        }
    }
}
