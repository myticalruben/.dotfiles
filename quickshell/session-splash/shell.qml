// Full-screen session splash for startup and for the end of the session.
//
// It is a layer-shell overlay, so it paints above normal windows without
// stealing keyboard focus. scripts/session-splash passes the distro data and
// the mode through the environment and decides when the session action runs.
// This file only draws: on startup it fades out and quits by itself; on exit
// it leaves the black backdrop up until the session actually goes away, so
// there is no flash of the desktop between the fade and the logout/reboot.

import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    readonly property string distroName: Quickshell.env("SESSION_SPLASH_NAME") || "Linux"
    readonly property string glyph: Quickshell.env("SESSION_SPLASH_GLYPH") || ""
    readonly property string accent: Quickshell.env("SESSION_SPLASH_ACCENT") || "#FFFFFF"
    readonly property bool exitMode: Quickshell.env("SESSION_SPLASH_MODE") === "exit"
    // Arranque: 250 ms de fade-in + 2,2 s de espera + 300 ms de fade-out.
    // Salida: se queda en 450 ms para no retrasar el logout.
    readonly property int holdMs: {
        var v = parseInt(Quickshell.env("SESSION_SPLASH_HOLD_MS") || "")
        return isNaN(v) ? 2200 : v
    }

    // The script passes the focused monitor. Very early in hyprland.start
    // hyprctl may not answer yet, so fall back to the first screen rather
    // than showing nothing.
    function activeScreen() {
        var wanted = Quickshell.env("SESSION_SPLASH_MONITOR")
        var screens = Quickshell.screens
        if (wanted) {
            for (var i = 0; i < screens.length; ++i)
                if (screens[i].name === wanted)
                    return screens[i]
        }
        return screens.length > 0 ? screens[0] : null
    }

    screen: activeScreen()
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "session-splash"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property real overlayOpacity: 0
    property real contentOpacity: 0
    property real logoScale: 0.92

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.overlayOpacity
    }

    // A full-width column keeps the glyph, the name and the dots centred on
    // each other without relying on a positioner to honour child anchors.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 14
        opacity: root.contentOpacity
        scale: root.logoScale

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            visible: root.glyph.length > 0
            text: root.glyph
            color: root.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 120
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.distroName
            color: "#F2F2F2"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 30
            font.weight: Font.Medium
            font.letterSpacing: 2
        }

        Item {
            width: parent.width
            height: 12

            Row {
                anchors.centerIn: parent
                spacing: 12

                Repeater {
                    model: 3

                    Rectangle {
                        width: 9
                        height: 9
                        radius: width / 2
                        color: root.accent
                        opacity: 0.2

                        SequentialAnimation on opacity {
                            running: root.contentOpacity > 0.01
                            loops: Animation.Infinite
                            PauseAnimation { duration: index * 130 }
                            NumberAnimation {
                                from: 0.2
                                to: 1.0
                                duration: 260
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                from: 1.0
                                to: 0.2
                                duration: 260
                                easing.type: Easing.InOutQuad
                            }
                            PauseAnimation { duration: (2 - index) * 130 }
                        }
                    }
                }
            }
        }
    }

    // 250 ms fade in, 2,2 s hold on startup (450 ms on exit), 300 ms fade out.
    // The exit path never fades
    // the black backdrop out: only the logo content goes away.
    SequentialAnimation {
        running: true

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "overlayOpacity"
                from: 0
                to: 1
                duration: 250
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "contentOpacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "logoScale"
                from: 0.92
                to: 1.0
                duration: 400
                easing.type: Easing.OutBack
            }
        }

        PauseAnimation { duration: root.exitMode ? 450 : root.holdMs }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "contentOpacity"
                to: 0
                duration: 300
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root
                property: "overlayOpacity"
                to: root.exitMode ? 1 : 0
                duration: 300
                easing.type: Easing.InCubic
            }
        }

        ScriptAction {
            script: {
                if (!root.exitMode)
                    Qt.quit()
            }
        }
    }

    // Exit mode has to stay black until the script's action lands. If that
    // action fails and the script cannot take the overlay down, a permanent
    // black screen would be worse than a short flash of the desktop.
    Timer {
        interval: 10000
        running: root.exitMode
        repeat: false
        onTriggered: Qt.quit()
    }
}
