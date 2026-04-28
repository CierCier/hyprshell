import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: spinnerContainer
    width: (spinner.width + Config.spinnerSpacing + spinnerText.width) * Config.generalScale
    height: childrenRect.height * Config.generalScale

    Behavior on opacity {
        enabled: Config.enableAnimations
        NumberAnimation {
            duration: 150
        }
    }
    Behavior on visible {
        enabled: Config.enableAnimations && Config.spinnerDisplayText
        ParallelAnimation {
            running: spinnerContainer.visible && Config.spinnerDisplayText
            NumberAnimation {
                target: spinnerText
                property: Config.loginAreaPosition === "left" ? "anchors.leftMargin" : (Config.loginAreaPosition === "right" ? "anchors.rightMargin" : "anchors.topMargin")
                from: -spinner.height
                to: Config.spinnerSpacing
                duration: 300
                easing.type: Easing.OutQuart
            }
            NumberAnimation {
                target: spinnerEffect
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 200
            }
        }
    }

    Item {
        id: spinnerGraphic
        width: Config.spinnerIconSize * Config.generalScale
        height: width
        
        Component.onCompleted: {
            if (Config.loginAreaPosition === "left") {
                anchors.left = parent.left;
                anchors.verticalCenter = parent.verticalCenter;
            } else if (Config.loginAreaPosition === "right") {
                anchors.right = parent.right;
                anchors.verticalCenter = parent.verticalCenter;
            } else {
                anchors.top = parent.top;
                anchors.horizontalCenter = parent.horizontalCenter;
            }
        }

        // Outer Ring
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: Config.spinnerColor
            opacity: 0.3
        }

        // Rotating Segment 1
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 3
            border.color: Config.spinnerColor
            
            // Mask or partial border effect via Canvas or just a child
            Rectangle {
                width: parent.width
                height: parent.height / 2
                y: 0
                color: "transparent"
                clip: true
                Rectangle {
                    width: parent.width
                    height: parent.width
                    radius: width / 2
                    color: "transparent"
                    border.width: 3
                    border.color: Config.spinnerColor
                }
            }
            
            RotationAnimation on rotation {
                from: 0; to: 360; duration: 1500; loops: Animation.Infinite; running: spinnerContainer.visible
            }
        }

        // Inner Rotating Dotted Ring
        Item {
            anchors.fill: parent
            anchors.margins: 6
            
            Repeater {
                model: 8
                Rectangle {
                    width: 4; height: 4; radius: 2
                    color: Config.spinnerColor
                    x: (parent.width / 2) + (parent.width / 2 - 2) * Math.cos(index * 2 * Math.PI / 8) - 2
                    y: (parent.height / 2) + (parent.height / 2 - 2) * Math.sin(index * 2 * Math.PI / 8) - 2
                }
            }
            
            RotationAnimation on rotation {
                from: 360; to: 0; duration: 3000; loops: Animation.Infinite; running: spinnerContainer.visible
            }
        }
    }

    Text {
        id: spinnerText
        visible: Config.spinnerDisplayText
        text: Config.spinnerText
        color: Config.spinnerColor
        font.pixelSize: Config.spinnerFontSize * Config.generalScale
        font.weight: Config.spinnerFontWeight
        font.family: Config.spinnerFontFamily

        Component.onCompleted: {
            if (Config.loginAreaPosition === "left") {
                anchors.left = spinnerGraphic.right;
                anchors.leftMargin = Config.spinnerSpacing;
                anchors.verticalCenter = parent.verticalCenter;
            } else if (Config.loginAreaPosition === "right") {
                anchors.right = spinnerGraphic.left;
                anchors.rightMargin = Config.spinnerSpacing;
                anchors.verticalCenter = parent.verticalCenter;
            } else {
                anchors.top = spinnerGraphic.bottom;
                anchors.topMargin = Config.spinnerSpacing;
                anchors.horizontalCenter = parent.horizontalCenter;
            }
        }

        onVisibleChanged: {
            if (visible && Config.enableAnimations && Config.spinnerDisplayText) {
                spinnerTextInterval.running = true;
            } else {
                spinnerTextAnimation.running = false;
                spinnerTextInterval.running = false;
            }
        }

        SequentialAnimation on scale {
            id: spinnerTextAnimation
            running: false
            loops: Animation.Infinite
            NumberAnimation {
                from: 1.0
                to: 1.05
                duration: 900
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: 1.05
                to: 1.0
                duration: 900
                easing.type: Easing.InOutQuad
            }
        }
    }

    Timer {
        id: spinnerTextInterval
        interval: 3500
        repeat: false
        running: false
        onTriggered: {
            spinnerTextAnimation.running = true;
        }
    }

    Component.onDestruction: {
        if (spinnerTextInterval) {
            spinnerTextInterval.running = false;
            spinnerTextInterval.stop();
        }
        if (spinnerTextAnimation) {
            spinnerTextAnimation.running = false;
            spinnerTextAnimation.stop();
        }
    }
}
