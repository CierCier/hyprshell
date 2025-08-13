import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            property var modelData
            screen: modelData

            anchors {
                right: true
                bottom: true
            }

            margins {
                right: 50
                bottom: 50
            }

            implicitWidth: content.width
            implicitHeight: content.height

            color: "transparent"

            mask: Region {}

            WlrLayershell.layer: WlrLayer.Overlay

            ColumnLayout {
                id: content

                Text {
                    text: "Activate Windows"
                    color: "#50ffffff"
                    font.pointSize: 22
                }
                Text {
                    text: "Go to Settings to activate Windows"
                    color: "#50ffffff"
                    font.pointSize: 14
                }
            }
        }
    }
}
