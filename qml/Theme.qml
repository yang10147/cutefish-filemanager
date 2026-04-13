pragma Singleton
import QtQuick

QtObject {
    readonly property int smallSpacing:  4
    readonly property int largeSpacing:  8
    readonly property int smallRadius:   4
    readonly property int mediumRadius:  8
    readonly property int bigRadius:    12
    readonly property int fontHeight:   16
    readonly property real devicePixelRatio: 1.0

    readonly property bool darkMode: false  // CachyOS KDE 默认亮色，可手动改 true

    readonly property color backgroundColor:       "#f5f5f5"
    readonly property color secondBackgroundColor: "#ebebeb"
    readonly property color textColor:             "#212121"
    readonly property color disabledTextColor:     "#9e9e9e"
    readonly property color highlightColor:        "#1976d2"
    readonly property color highlightedTextColor:  "#ffffff"
}
