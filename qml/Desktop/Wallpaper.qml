/*
 * Qt6/Wayland port 2026 - FishUI 已移除
 */

import QtQuick

Image {
    anchors.fill: parent
    source: "file:///usr/share/backgrounds/cutefish/default.jpg"
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    smooth: true

    // 纯色兜底
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
        visible: parent.status !== Image.Ready
    }
}
