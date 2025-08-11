import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Shapes 
import QtQuick.Layouts
import QtMultimedia
import QtWebEngine
import QtQuick.Dialogs 
import Qt.labs.platform as Platform


ApplicationWindow {
    id: appWindow
    title: "trackio"
    visible: true
    width: 414
    height: 736
    minimumWidth: 414
    maximumWidth: 414
    minimumHeight: 736
    maximumHeight: 736

    StackView {
        id: stackView
        visible: true
        anchors.fill: parent
        initialItem: loginPage
    }

    Dialog {
        id: messageDialog
        title: "Error"
        width: 300
        height: 100
        anchors.centerIn: parent

        contentItem: Column { 
            spacing: 10
            topPadding: -5

            Text {
                id: dialogMessage
                text: "Error message"
                color: "white"
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                id: closeButton
                text: "Close"
                anchors.horizontalCenter: parent.horizontalCenter
                background : Rectangle {
                    color: "light grey"
                }
                onClicked: messageDialog.close()

            }
        }
    }

    Rectangle {
        id: dimOverlay
        color: "black"
        opacity: 0.4
        anchors.fill: parent
        visible: false
        z: 1
    }

    BusyIndicator {
        id: loadingIndicator
        width: 100
        height: 100

        anchors.centerIn: parent
        running: true
        visible: false
    }

    Connections {
        target: backend
        function onShowMessage() {
            dialogMessage.text = backend.update_status();
            messageDialog.open();
        }
    }

    Component {
        id: loginPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                // Change the ApplicationWindow size when the login page is loaded
                appWindow.minimumHeight = 250
                appWindow.height = 250
                appWindow.maximumHeight = 250
            }


            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }
            }

            Rectangle {
                id: header
                color: "transparent"
                height: parent.height * 0.25
                width: parent.width

                anchors.top: parent.top

                Rectangle {
                    id: appNameRect
                    height: parent.height
                    width: appNameTextRect.width + logoRect.width + 5
                    color: "transparent"

                    anchors.centerIn: parent

                    Rectangle {
                        id: appNameTextRect
                        width: appNameTextMetrics.width
                        height: parent.height
                        color: "transparent"
                        anchors.left: parent.left

                        Text {
                            id: appNameText
                            color: "#ffffff"
                            text: "tracki"
                            font.pixelSize: parent.height * 0.6

                            font.weight: Font.DemiBold
                            font.bold: true


                        }

                        TextMetrics {
                            id: appNameTextMetrics
                            text: appNameText.text
                            font: appNameText.font
                        }
                    }

                    Rectangle {
                        id: logoRect
                        height: appNameTextMetrics.height * 0.5
                        width: appNameTextMetrics.height * 0.5
                        color: "transparent"

                        anchors.left: appNameTextRect.right
                        anchors.leftMargin: 5

                        anchors.verticalCenter: appNameTextRect.verticalCenter

                        Image {
                            id: logoImage
                            width: parent.height * 0.2
                            height: parent.height * 0.2
                            anchors.fill: parent
                            source: "assets/Logo.png"
                            fillMode: Image.PreserveAspectFit

                        }
                    }
                }
            }

            Rectangle {
                id: body
                height: parent.height * 0.75
                width: parent.width
                color: "transparent"

                anchors.top: header.bottom


                Rectangle {
                    id: emailRect
                    color: "white"
                    radius: 10
                    width: parent.width * 0.85
                    height: parent.height * 0.2

                    anchors.top: parent.top
                    anchors.topMargin: 0

                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: emailTextRect
                        color: "transparent"
                        width: emailText.width
                        height: parent.height

                        anchors.left: parent.left
                        anchors.leftMargin: 5

                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: emailText
                            color: "#000000"
                            text: "Email:"
                            font.pixelSize: parent.height * 0.4
                            anchors.centerIn: parent
                            font.weight: Font.DemiBold
                            font.bold: true
                        }
                    }

                    TextInput {
                        id: emailTextInput
                        width: emailRect.width - emailTextRect.width * 1.4
                        anchors.left: emailTextRect.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: emailText.font.pixelSize
                        clip: true
                        font.weight: Font.Medium
                        font.bold: true
                    }
                }

                Rectangle {
                    id: passwordRect
                    color: "white"
                    radius: 10

                    width: parent.width * 0.85
                    height: parent.height * 0.2


                    anchors.top: emailRect.bottom
                    anchors.topMargin: parent.height * 0.05

                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: passwordTextRect
                        color: "transparent"
                        width: passwordText.width
                        height: parent.height
                        anchors.left: parent.left
                        anchors.leftMargin: 5

                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: passwordText
                            color: "#000000"
                            text: "Password:"
                            font.pixelSize: parent.height * 0.4
                            anchors.centerIn: parent
                            font.weight: Font.DemiBold
                            font.bold: true

                        }
                    }

                    TextInput {
                        id: passwordTextInput
                        anchors.left: passwordTextRect.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        width: passwordRect.width - passwordTextRect.width * 1.25
                        font.pixelSize: passwordText.font.pixelSize
                        clip: true
                        font.weight: Font.Medium
                        font.bold: true
                        echoMode: TextInput.Password
                    }
                }

                Rectangle {
                    id: loginRect
                    color: "white"
                    radius: 10
                    width: parent.width * 0.85
                    height: parent.height * 0.2

                    anchors.top: passwordRect.bottom
                    anchors.topMargin: parent.height * 0.07
                    anchors.horizontalCenter: parent.horizontalCenter

                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: "#e0ea75"
                        }

                        GradientStop {
                            position: 1
                            color: "#e1720b"
                        }
                        orientation: Gradient.Horizontal
                    }


                    Button {
                        visible: true
                        text: "Login"
                        anchors.fill: parent
                        display: AbstractButton.TextOnly
                        background: null

                        contentItem: Text {
                            text: parent.text
                            color: "black"
                            font.pixelSize: loginRect.height * 0.5
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.weight: Font.DemiBold
                            font.bold: true
                        }
                        onClicked: {
                            loadingIndicator.visible = true
                            dimOverlay.visible = true
                            var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                            timer.interval = 100  // Set the delay time in milliseconds
                            timer.repeat = false
                            timer.triggered.connect(function() {
                                if (backend.on_register_clicked(emailTextInput.text, passwordTextInput.text)) {
                                    stackView.push(registerPage, StackView.Immediate)


                                } else if (backend.on_login_clicked(emailTextInput.text, passwordTextInput.text)) {
                                    stackView.push(reccomendationsPage, StackView.Immediate)
                                }
                                loadingIndicator.visible = false
                                dimOverlay.visible = false
                            })
                            timer.start()
                        }
                    }
                }

                Rectangle {
                    id: forgotPasswordRect
                    width: forgotPasswordTextMetrics.width
                    height: forgotPasswordTextMetrics.height
                    color: "transparent"

                    anchors.top: loginRect.bottom
                    anchors.topMargin: 5

                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: forgotPasswordText
                        text: "Forgot your password? Click Here!"
                        color: "white"
                        font.pixelSize: passwordText.font.pixelSize
                        font.underline: true
                    }

                    TextMetrics {
                        id: forgotPasswordTextMetrics
                        text: forgotPasswordText.text
                        font: forgotPasswordText.font
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push(forgotPasswordPage, StackView.Immediate)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: reccomendationsPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                appWindow.minimumHeight = 736
                appWindow.height = 736
                appWindow.maximumHeight = 736
            }

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "transparent"
                    height: width * 0.12
                    width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Rectangle {
                        id: settingsRect
                        color: "transparent"
                        width: parent.width * 0.1
                        height: parent.height

                        anchors.right: parent.right
                        anchors.rightMargin: parent.height * 0.15

                        ToolBar {
                            id: settingsBar
                            width: parent.width
                            height: parent.height // Adjust height as needed
                            anchors.fill: parent
                            background: Rectangle {
                                color: "transparent"
                            }

                            RowLayout {
                                id: settingsLayout
                                anchors.fill: parent

                                ToolButton {
                                    id: settingsButton
                                    icon.source: "assets/Blank.svg" // Replace with your icon path
                                    icon.width: parent.width * 0.8
                                    icon.height: parent.height * 0.8

                                    onClicked: stackView.push(settingsPage) // Replace with navigation logic


                                    Image {
                                        id: settingsIcon
                                        source: "assets/settingsIconWhite.svg"
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: body
                    width: parent.width
                    height: parent.height * 0.85
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                        id: imageRect
                        color: "transparent"
                        width: height
                        height: parent.height * 0.5

                        anchors.top: parent.top
                        anchors.topMargin: header.height * 0.5

                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * 0.1

                        anchors.right: parent.right
                        anchors.rightMargin: parent.width * 0.1

                        Image {
                            id: albumImage
                            width: parent.width
                            height: parent.height

                            anchors.fill: parent

                            fillMode: Image.PreserveAspectFit
                            source: backend.albumImage
                        }
                    }

                    Rectangle {
                        id: trackNameRect
                        color: "transparent"
                        width: parent.width
                        height: parent.height * 0.05

                        anchors.top: imageRect.bottom
                        anchors.topMargin: 15

                        Text {
                            id: trackName
                            color: "#ffffff"
                            text: backend.trackName
                            width: trackNameRect.width - 20
                            font.pixelSize: parent.width * 0.04
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.centerIn: trackNameRect
                        }
                    }

                    Rectangle {
                        id: controlsRect
                        color: "transparent"
                        width: parent.width
                        height: parent.height * 0.35

                        anchors.top: trackNameRect.bottom
                        anchors.topMargin: 15


                        Rectangle {
                            id: playbackRect
                            width: parent.width
                            height: parent.height * 0.1
                            color: "transparent"

                            anchors.left: controlsRect.left
                            anchors.leftMargin: parent.width * 0.1

                            anchors.right: controlsRect.right
                            anchors.rightMargin: parent.width * 0.1

                            anchors.top: controlsRect.top

                            property alias mediaPlayer: mediaPlayer

                            MediaPlayer {
                                id: mediaPlayer
                                source: backend.mediaPlayer_source
                                audioOutput: AudioOutput {}
                                autoPlay: false
                            }

                            Image {
                                id: playPauseButton
                                source: mediaPlayer.playbackState === MediaPlayer.PlayingState
                                    ? "assets/pauseIcon.svg" : "assets/playIcon.svg"

                                width: playbackRect.width * 0.12
                                height: width
                                fillMode: Image.PreserveAspectFit

                                anchors.left: playbackRect.left
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                            mediaPlayer.pause();
                                        }

                                        else {
                                            mediaPlayer.play();
                                        }
                                    }
                                }

                                ProgressBar {
                                    id: progressBar
                                    width: playbackRect.width - playPauseButton.width - 115

                                    background: Rectangle {
                                        color: "light grey"
                                    }

                                    from: 0
                                    to: 30000 // 30 seconds in milliseconds
                                    value: Math.min(mediaPlayer.position, 30000)

                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.right
                                    anchors.leftMargin: 10

                                    Connections {
                                        target: mediaPlayer
                                        function onPositionChanged() {
                                        progressBar.value = Math.min(mediaPlayer.position, 30000);
                                        }
                                    }
                                }

                                Image {
                                    id: dislikeButton
                                    source: backend.dislikeButtonSource
                                    width: parent.width
                                    height: width
                                    fillMode: Image.PreserveAspectFit

                                    anchors.left: progressBar.right
                                    anchors.leftMargin: 10

                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (dislikeButton.source == "assets/dislikeGreyIcon.svg") {
                                                backend.dislikeButtonSource = "assets/dislikeRedIcon.svg";
                                                backend.likeButtonSource = "assets/loveGreyIcon.svg";
                                            }
                                            else {
                                                backend.dislikeButtonSource = "assets/dislikeGreyIcon.svg";
                                            }
                                        }
                                    }
                                }

                                Image {
                                    id: loveButton
                                    source: backend.likeButtonSource
                                    width: parent.width
                                    height: width
                                    fillMode: Image.PreserveAspectFit

                                    anchors.left: dislikeButton.right
                                    anchors.leftMargin: 10

                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                                if (loveButton.source == "assets/loveGreyIcon.svg") {
                                                    backend.likeButtonSource = "assets/loveRedIcon.svg";
                                                    backend.dislikeButtonSource = "assets/dislikeGreyIcon.svg"; // Reset dislike button
                                                }
                                                else {
                                                    backend.likeButtonSource = "assets/loveGreyIcon.svg";
                                                }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: swipeArea
                            width: parent.width
                            height: parent.height * 1
                            color: "transparent"

                            anchors.top: playbackRect.bottom

                            MouseArea {
                                id: swipeMouseArea
                                anchors.fill: parent
                                drag.target: null
                                drag.axis: Drag.YAxis

                                property real startY: 0

                                onPressed: {
                                    startY = mouse.y;
                                }

                                onReleased: {
                                    if (mouse.y - startY < -40) { // Threshold for upward swipe
                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && loveButton.source == "assets/loveGreyIcon.svg") {
                                            var opinion = 0;
                                            backend.on_swipe_up(opinion);
                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && loveButton.source == "assets/loveRedIcon.svg") {
                                            var opinion = 1;
                                            backend.on_swipe_up(opinion);
                                        } else {
                                            backend.on_swipe_up(-1);
                                        }

                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: footer
                    width: parent.width
                    height: parent.height - header.height - body.height
                    color: "transparent"

                    anchors.top: body.bottom

                    ToolBar {
                        id: menuBar
                        width: parent.width
                        height: parent.height // Adjust height as needed
                        anchors.bottom: parent.bottom
                        background: Rectangle {
                            color: "transparent" // Toolbar background color
                        }

                        RowLayout {
                            id: menuLayout
                            spacing: 0
                            anchors.fill: parent

                            ToolButton {
                                id: searchButton
                                icon.source: "assets/searchBarIcon.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: {
                                    stackView.push(searchPage, StackView.Immediate);
                                }
                            }

                            ToolButton {
                                id: leaderboardButton
                                icon.source: "assets/leaderboardIcon.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: console.log("Leaderboard Clicked") 
                            }

                            ToolButton {
                                id: recommendationsButton
                                icon.source: "assets/Blank.svg" 
                                icon.width: 104
                                icon.height: 66
                                background: Rectangle {
                                    color: "transparent"

                                }

                                Image {
                                    source: "assets/Logo.png"
                                    width: parent.width * 1.2 // Icon size is larger than the button
                                    height: parent.height * 1.2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom

                                    fillMode: Image.PreserveAspectFit
                                }

                                Layout.fillWidth: false
                                Layout.fillHeight: true
                                onClicked: {
                                    if (dislikeButton.source == "assets/dislikeRedIcon.svg" && loveButton.source == "assets/loveGreyIcon.svg") {
                                            var opinion = 0;
                                            backend.on_recommendation_clicked(opinion);
                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && loveButton.source == "assets/loveRedIcon.svg") {
                                            var opinion = 1;
                                            backend.on_recommendation_clicked(opinion);
                                        } else {
                                            backend.on_recommendation_clicked(-1);
                                        }
                                    stackView.push(reccomendationsPage, StackView.Immediate);
                                }

                            }

                            ToolButton {
                                id: profileButton
                                icon.source: "assets/profile.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(profilePage, StackView.Immediate)
                            }

                            ToolButton {
                                id: bookmarksButton
                                icon.source: "assets/bookmarksIconBlack.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(bookmarksPage, StackView.Immediate) // Replace with navigation logic
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: registerPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                appWindow.minimumHeight = 250
                appWindow.height = 250
                appWindow.maximumHeight = 250
            }

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "transparent"
                    height: parent.height * 0.25
                    width: parent.width

                    anchors.top: parent.top

                    Rectangle {
                        id: appNameRect
                        height: parent.height
                        width: appNameTextRect.width + logoRect.width + 5
                        color: "transparent"

                        anchors.centerIn: parent

                        Rectangle {
                            id: appNameTextRect
                            width: appNameTextMetrics.width
                            height: parent.height
                            color: "transparent"
                            anchors.left: parent.left

                            Text {
                                id: appNameText
                                color: "#ffffff"
                                text: "tracki"
                                font.pixelSize: parent.height * 0.6

                                font.weight: Font.DemiBold
                                font.bold: true


                            }

                            TextMetrics {
                                id: appNameTextMetrics
                                text: appNameText.text
                                font: appNameText.font
                            }
                        }

                        Rectangle {
                            id: logoRect
                            height: appNameTextMetrics.height * 0.5
                            width: appNameTextMetrics.height * 0.5
                            color: "transparent"

                            anchors.left: appNameTextRect.right
                            anchors.leftMargin: 5

                            anchors.verticalCenter: appNameTextRect.verticalCenter

                            Image {
                                id: logoImage
                                width: parent.height * 0.2
                                height: parent.height * 0.2
                                anchors.fill: parent
                                source: "assets/Logo.png"
                                fillMode: Image.PreserveAspectFit

                            }
                        }
                    }
                }

                Rectangle {
                    id: body
                    height: parent.height * 0.75
                    width: parent.width
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                        id: firstNameRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.2

                        anchors.top: parent.top
                        anchors.topMargin: 0

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: firstNameTextRect
                            color: "transparent"
                            width: firstNameText.width
                            height: parent.height

                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: firstNameText
                                color: "#000000"
                                text: "First Name:"
                                font.pixelSize: parent.height * 0.4
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                        }

                        TextInput {
                            id: firstNameTextInput
                            width: firstNameRect.width - firstNameTextRect.width * 1.4
                            anchors.left: firstNameTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: firstNameText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: lastNameRect
                        color: "white"
                        radius: 10

                        width: parent.width * 0.85
                        height: parent.height * 0.2


                        anchors.top: firstNameRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: lastNameTextRect
                            color: "transparent"
                            width: lastNameText.width
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: lastNameText
                                color: "#000000"
                                text: "Last Name:"
                                font.pixelSize: parent.height * 0.4
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true

                            }
                        }

                        TextInput {
                            id: lastNameTextInput
                            anchors.left: lastNameTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            width: lastNameRect.width - lastNameTextRect.width * 1.25
                            font.pixelSize: lastNameText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: registerRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.2

                        anchors.top: lastNameRect.bottom
                        anchors.topMargin: parent.height * 0.07
                        anchors.horizontalCenter: parent.horizontalCenter

                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: "#e0ea75"
                            }

                            GradientStop {
                                position: 1
                                color: "#e1720b"
                            }
                            orientation: Gradient.Horizontal
                        }


                        Button {
                            visible: true
                            text: "Register"
                            anchors.fill: parent
                            display: AbstractButton.TextOnly
                            background: null

                            contentItem: Text {
                                text: parent.text
                                color: "black"
                                font.pixelSize: registerRect.height * 0.5
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                            onClicked: {
                                loadingIndicator.visible = true
                                dimOverlay.visible = true
                                var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                                timer.interval = 100  // Set the delay time in milliseconds
                                timer.repeat = false
                                timer.triggered.connect(function() {
                                    if (backend.on_register_submit(firstNameTextInput.text, lastNameTextInput.text)) {
                                        stackView.push(reccomendationsPage, StackView.Immediate)
                                    }
                                    
                                    loadingIndicator.visible = false
                                    dimOverlay.visible = false
                                })
                                timer.start()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: forgotPasswordPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                appWindow.minimumHeight = 300
                appWindow.height = 300
                appWindow.maximumHeight = 300
            }

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "transparent"
                    height: parent.height * 0.21
                    width: parent.width

                    anchors.top: parent.top

                    Rectangle {
                        id: appNameRect
                        height: parent.height
                        width: appNameTextRect.width + logoRect.width + 5
                        color: "transparent"

                        anchors.centerIn: parent

                        Rectangle {
                            id: appNameTextRect
                            width: appNameTextMetrics.width
                            height: parent.height
                            color: "transparent"
                            anchors.left: parent.left

                            Text {
                                id: appNameText
                                color: "#ffffff"
                                text: "tracki"
                                font.pixelSize: parent.height * 0.6

                                font.weight: Font.DemiBold
                                font.bold: true


                            }

                            TextMetrics {
                                id: appNameTextMetrics
                                text: appNameText.text
                                font: appNameText.font
                            }
                        }

                        Rectangle {
                            id: logoRect
                            height: appNameTextMetrics.height * 0.5
                            width: appNameTextMetrics.height * 0.5
                            color: "transparent"

                            anchors.left: appNameTextRect.right
                            anchors.leftMargin: 5

                            anchors.verticalCenter: appNameTextRect.verticalCenter

                            Image {
                                id: logoImage
                                width: parent.height * 0.2
                                height: parent.height * 0.2
                                anchors.fill: parent
                                source: "assets/Logo.png"
                                fillMode: Image.PreserveAspectFit

                            }
                        }
                    }
                }

                Rectangle {
                    id: body
                    height: parent.height * 0.8
                    width: parent.width
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                        id: emailRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.15

                        anchors.top: parent.top
                        anchors.topMargin: 0

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: emailTextRect
                            color: "transparent"
                            width: emailText.width
                            height: parent.height

                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: emailText
                                color: "#000000"
                                text: "Email:"
                                font.pixelSize: parent.height * 0.45
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                        }

                        TextInput {
                            id: emailTextInput
                            width: emailRect.width - emailTextRect.width * 1.4
                            anchors.left: emailTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: emailText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: firstNameRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.15

                        anchors.top: emailRect.bottom
                        anchors.topMargin: parent.height * 0.04

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: firstNameTextRect
                            color: "transparent"
                            width: firstNameText.width
                            height: parent.height

                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: firstNameText
                                color: "#000000"
                                text: "First Name:"
                                font.pixelSize: parent.height * 0.45
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                        }

                        TextInput {
                            id: firstNameTextInput
                            width: firstNameRect.width - firstNameTextRect.width * 1.25
                            anchors.left: firstNameTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: firstNameText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: lastNameRect
                        color: "white"
                        radius: 10

                        width: parent.width * 0.85
                        height: parent.height * 0.15


                        anchors.top: firstNameRect.bottom
                        anchors.topMargin: parent.height * 0.04

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: lastNameTextRect
                            color: "transparent"
                            width: lastNameText.width
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: lastNameText
                                color: "#000000"
                                text: "Last Name:"
                                font.pixelSize: parent.height * 0.45
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true

                            }
                        }

                        TextInput {
                            id: lastNameTextInput
                            anchors.left: lastNameTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            width: lastNameRect.width - lastNameTextRect.width * 1.25
                            font.pixelSize: lastNameText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: resetPasswordRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.15

                        anchors.top: lastNameRect.bottom
                        anchors.topMargin: parent.height * 0.06
                        anchors.horizontalCenter: parent.horizontalCenter

                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: "#e0ea75"
                            }

                            GradientStop {
                                position: 1
                                color: "#e1720b"
                            }
                            orientation: Gradient.Horizontal
                        }


                        Button {
                            visible: true
                            text: "Reset Password"
                            anchors.fill: parent
                            display: AbstractButton.TextOnly
                            background: null

                            contentItem: Text {
                                text: parent.text
                                color: "black"
                                font.pixelSize: resetPasswordRect.height * 0.5
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                            onClicked: {
                                loadingIndicator.visible = true
                                dimOverlay.visible = true
                                var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                                timer.interval = 100  // Set the delay time in milliseconds
                                timer.repeat = false
                                timer.triggered.connect(function() {
                                    if (backend.on_reset_password_clicked(emailTextInput.text, firstNameTextInput.text, lastNameTextInput.text)) {
                                        stackView.push(resetPasswordPage, StackView.Immediate)
                                    } else if (dialogMessage.text == "Account does not exist, please register") {
                                        stackView.push(loginPage, StackView.Immediate)
                                    }
                                    loadingIndicator.visible = false
                                    dimOverlay.visible = false
                                })
                                timer.start()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: resetPasswordPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                appWindow.minimumHeight = 250
                appWindow.height = 250
                appWindow.maximumHeight = 250
            }

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "transparent"
                    height: parent.height * 0.25
                    width: parent.width

                    anchors.top: parent.top

                    Rectangle {
                        id: appNameRect
                        height: parent.height
                        width: appNameTextRect.width + logoRect.width + 5
                        color: "transparent"

                        anchors.centerIn: parent

                        Rectangle {
                            id: appNameTextRect
                            width: appNameTextMetrics.width
                            height: parent.height
                            color: "transparent"
                            anchors.left: parent.left

                            Text {
                                id: appNameText
                                color: "#ffffff"
                                text: "tracki"
                                font.pixelSize: parent.height * 0.6

                                font.weight: Font.DemiBold
                                font.bold: true


                            }

                            TextMetrics {
                                id: appNameTextMetrics
                                text: appNameText.text
                                font: appNameText.font
                            }
                        }

                        Rectangle {
                            id: logoRect
                            height: appNameTextMetrics.height * 0.5
                            width: appNameTextMetrics.height * 0.5
                            color: "transparent"

                            anchors.left: appNameTextRect.right
                            anchors.leftMargin: 5

                            anchors.verticalCenter: appNameTextRect.verticalCenter

                            Image {
                                id: logoImage
                                width: parent.height * 0.2
                                height: parent.height * 0.2
                                anchors.fill: parent
                                source: "assets/Logo.png"
                                fillMode: Image.PreserveAspectFit

                            }
                        }
                    }
                }

                Rectangle {
                    id: body
                    height: parent.height * 0.75
                    width: parent.width
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                        id: newPasswordRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.2

                        anchors.top: parent.top
                        anchors.topMargin: 0

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: newPasswordTextRect
                            color: "transparent"
                            width: newPasswordText.width
                            height: parent.height

                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: newPasswordText
                                color: "#000000"
                                text: "New Password:"
                                font.pixelSize: parent.height * 0.4
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                        }

                        TextInput {
                            id: newPasswordTextInput
                            width: newPasswordRect.width - newPasswordTextRect.width * 1.2
                            anchors.left: newPasswordTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: newPasswordText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                            echoMode: TextInput.PasswordEchoOnEdit
                        }
                    }

                    Rectangle {
                        id: repeatPasswordRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.2

                        anchors.top: newPasswordRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: repeatPasswordTextRect
                            color: "transparent"
                            width: repeatPasswordText.width
                            height: parent.height

                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: repeatPasswordText
                                color: "#000000"
                                text: "Confirm Password:"
                                font.pixelSize: parent.height * 0.4
                                anchors.centerIn: parent
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                        }

                        TextInput {
                            id: repeatPasswordTextInput
                            width: repeatPasswordRect.width - repeatPasswordTextRect.width * 1.2
                            anchors.left: repeatPasswordTextRect.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: repeatPasswordText.font.pixelSize
                            clip: true
                            font.weight: Font.Medium
                            font.bold: true
                            echoMode: TextInput.PasswordEchoOnEdit
                        }
                    }

                    Rectangle {
                        id: resetPasswordRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.2

                        anchors.top: repeatPasswordRect.bottom
                        anchors.topMargin: parent.height * 0.07
                        anchors.horizontalCenter: parent.horizontalCenter

                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: "#e0ea75"
                            }

                            GradientStop {
                                position: 1
                                color: "#e1720b"
                            }
                            orientation: Gradient.Horizontal
                        }


                        Button {
                            visible: true
                            text: "Reset Password"
                            anchors.fill: parent
                            display: AbstractButton.TextOnly
                            background: null

                            contentItem: Text {
                                text: parent.text
                                color: "black"
                                font.pixelSize: resetPasswordRect.height * 0.5
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.weight: Font.DemiBold
                                font.bold: true
                            }
                            onClicked: {
                                loadingIndicator.visible = true
                                dimOverlay.visible = true
                                var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                                timer.interval = 100  // Set the delay time in milliseconds
                                timer.repeat = false
                                timer.triggered.connect(function() {
                                    if (backend.on_reset_password_submit(newPasswordTextInput.text, repeatPasswordTextInput.text)) {
                                        stackView.push(loginPage, StackView.Immediate)
                                    }
                                    loadingIndicator.visible = false
                                    dimOverlay.visible = false
                                })
                                timer.start()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: searchPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "#00000000"
                    height: width * 0.12
                    width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Rectangle {
                        id: searchRect
                        width: parent.width 
                        height: parent.height * 0.6
                        color: "white"
                        radius: 10

                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: searchLogoRect
                            width: height
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                source: "assets/searchBarIcon.svg"
                                anchors.fill: parent
                            }
                        }

                        Rectangle {
                            id: searchInputRect
                            color: "transparent"
                            width: parent.width - 40
                            height: parent.height

                            anchors.left: searchLogoRect.right
                            anchors.leftMargin: 0

                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0               

                            TextField {
                                id: searchTextInput
                                width: parent.width
                                height: parent.height
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                color: "black"
                                placeholderText: "Search"
                                clip: true
                                font.pixelSize: height * 0.6
                                placeholderTextColor: "black"

                                background: Rectangle {
                                    color: "transparent"
                                }

                                onEditingFinished: {
                                    loadingIndicator.visible = true
                                    dimOverlay.visible = true
                                    var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                                    timer.interval = 100  // Set the delay time in milliseconds
                                    timer.repeat = false
                                    timer.triggered.connect(function() {
                                        listView.model = backend.search(searchTextInput.text)
                                        loadingIndicator.visible = false
                                        dimOverlay.visible = false
                                    })
                                    timer.start()
                                    

                                }
                            }   
                        }
                    }
                }

                Rectangle {
                    id: body
                    width: parent.width
                    height: parent.height * 0.85
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                    id: listViewRect
                    width: parent.width
                    height: parent.height 

                    anchors.fill: parent

                    color: "transparent"

                    ListView {
                        id: listView
        
                            width: parent.width
                            height: parent.height
                            model: []
                            clip: true
                            focus: true

                                

                            delegate: Item {
                                width: ListView.view.width
                                height: 100

                                Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    color: model.index % 2 === 0 ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(255, 255, 255, 0.2)

                                    Rectangle {
                                        id: albumImageRect
                                        width: parent.height * 0.8
                                        height: parent.height * 0.8

                                        anchors.left: parent.left
                                        anchors.leftMargin: 15

                                        anchors.verticalCenter: parent.verticalCenter


                                        Image {
                                            id: albumImage
                                            width: parent.height
                                            height: parent.height
                                            anchors.fill: parent
                                            source: modelData.album_cover
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    Text {
                                        width: parent.width - albumImageRect.width - 90
                                        text: modelData.track_name + " by " + modelData.artist_name
                                        font.pixelSize: parent.height * 0.18
                                        font.weight: Font.DemiBold

                                        anchors.left: albumImageRect.right
                                        anchors.leftMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 4
                                        color: "white"
                                        
                                    }

                                    Rectangle {
                                        id: likeButtonRect
                                        width: parent.height * 0.5
                                        height: parent.height * 0.5
                                        color: "transparent"

                                        anchors.right: parent.right
                                        anchors.rightMargin: 0

                                        anchors.top: parent.top
                                        anchors.topMargin: 0

                                        Image {
                                            id: likeButton
                                            width: parent.height * 0.8
                                            height: parent.height * 0.8
                                            source: modelData.opinion == 1 ? "assets/loveRedIcon.svg" : "assets/loveGreyIcon.svg"
                                            fillMode: Image.PreserveAspectFit
                                            anchors.centerIn: parent


                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (likeButton.source == "assets/loveGreyIcon.svg") {
                                                        likeButton.source = "assets/loveRedIcon.svg";
                                                        dislikeButton.source = "assets/dislikeGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        } 
                                                    }

                                                    else {
                                                        likeButton.source = "assets/loveGreyIcon.svg";
                                                        dislikeButton.source = "assets/dislikeGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        }

                                                    }
                                                
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: dislikeButtonRect
                                        width: parent.height * 0.5
                                        height: parent.height * 0.5
                                        color: "transparent"

                                        anchors.top: likeButtonRect.bottom
                                        anchors.topMargin: 0

                                        anchors.right: parent.right
                                        anchors.rightMargin: 0

                                        Image {
                                            id: dislikeButton
                                            width: parent.height * 0.8
                                            height: parent.height * 0.8
                                            source: modelData.opinion == 0 ? "assets/dislikeRedIcon.svg" : "assets/dislikeGreyIcon.svg"
                                            fillMode: Image.PreserveAspectFit
                                            anchors.centerIn: parent


                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (dislikeButton.source == "assets/dislikeGreyIcon.svg") {
                                                        dislikeButton.source = "assets/dislikeRedIcon.svg";
                                                        likeButton.source = "assets/loveGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        } 
                                                    }

                                                    else {
                                                        dislikeButton.source = "assets/dislikeGreyIcon.svg";
                                                        likeButton.source = "assets/loveGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        }

                                                    }
                                                
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: footer
                    width: parent.width
                    height: parent.height - header.height - body.height
                    color: "transparent"

                    anchors.top: body.bottom
                

                    ToolBar {
                        id: menuBar
                        width: parent.width
                        height: parent.height 
                        anchors.bottom: parent.bottom
                        background: Rectangle {
                            color: "transparent" 
                        }

                        RowLayout {
                            id: menuLayout
                            spacing: 0
                            anchors.fill: parent

                            ToolButton {
                                id: searchButton
                                icon.source: "assets/searchBarIcon.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: {
                                    stackView.push(searchPage, StackView.Immediate)
                                }
                            }

                            ToolButton {
                                id: leaderboardButton
                                icon.source: "assets/leaderboardIcon.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: console.log("Leaderboard Clicked") 
                            }

                            ToolButton {
                                id: recommendationsButton
                                icon.source: "assets/Blank.svg" 
                                icon.width: 104
                                icon.height: 66
                                background: Rectangle { 
                                    color: "transparent"
                                }
                                
                                Image {
                                    source: "assets/Logo.png"
                                    width: parent.width * 1.2 
                                    height: parent.height * 1.2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 0
                                    fillMode: Image.PreserveAspectFit
                                }

                                Layout.fillWidth: false
                                Layout.fillHeight: true
                                onClicked: { 
                                    stackView.push(reccomendationsPage, StackView.Immediate);
                                    backend.on_recommendation_clicked(-1);
                                }
                            }

                            ToolButton {
                                id: profileButton
                                icon.source: "assets/profile.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(profilePage, StackView.Immediate)
                            }

                            ToolButton {
                                id: bookmarksButton
                                icon.source: "assets/bookmarksIconBlack.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(bookmarksPage, StackView.Immediate) 
                            }
                        }
                    }
                }   
            }
        }
    }
    Component {
        id: settingsPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "transparent"
                    height: width * 0.12
                    width: parent.width

                    anchors.top: parent.top

                    Rectangle {
                        id: backButtonRect
                        height: parent.height
                        width: parent.height
                        color: "transparent"

                        anchors.left: parent.left

                        Button {
                            id: backButton
                            text: "Back"


                            background: Rectangle{
                                color: "transparent"
                            }

                            anchors.fill: parent
                            
                            onClicked: stackView.pop()

                        }
                    }
                }

                Rectangle {
                    id: body
                    height: parent.height - header.height
                    width: parent.width
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                        id: connectToSpotifyButtonRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: parent.top
                        anchors.topMargin: 0

                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            id: connectToSpotifyButton
                            text: "Connect to Spotify"

                            anchors.fill: parent

                            onClicked: {
                                backend.on_connect_spotify_clicked()
                                stackView.push(spotifyAuthPage)
                            }

                            
                        }
                    }

                    Rectangle {
                        id: adminButtonRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: connectToSpotifyButtonRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        visible: backend.account_type === "admin"

                        Button {
                            id: adminButton
                            text: "Admin"

                            anchors.fill: parent

                            onClicked: {
                                stackView.push(adminPage)
                            }
                        }
                    }

                    Rectangle {
                        id: logOutButtonRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: adminButtonRect.visible ? adminButtonRect.bottom : connectToSpotifyButtonRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            id: logOutButton
                            text: "Sign Out"

                            anchors.fill: parent

                            onClicked: {
                                stackView.push(loginPage)
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: spotifyAuthPage

        Rectangle {
            id: webViewRect
            width: parent.width
            height: parent.height

            WebEngineView {
               id: webView
                anchors.fill: parent
                url: backend.auth_url

                onUrlChanged: { 
                    if ((webView.url.toString()).startsWith("http://localhost:8888")) {
                    backend.handle_spotify_callback(webView.url)
                    backend.collect_all_track_uris()
                    stackView.pop()
                    }
                        
                }
            }
        }
    }

    Component {
        id: adminPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "transparent"
                    height: width * 0.12
                    width: parent.width

                    anchors.top: parent.top

                    Rectangle {
                        id: backButtonRect
                        height: parent.height
                        width: parent.height
                        color: "transparent"

                        anchors.left: parent.left

                        Button {
                            id: backButton
                            text: "Back"


                            background: Rectangle{
                                color: "transparent"
                            }

                            anchors.fill: parent
                            
                            onClicked: stackView.pop()

                        }
                    }
                }

                Rectangle {
                    id: body
                    color: "transparent"
                    height: parent.height - header.height
                    width: parent.width

                    anchors.top: header.bottom

                    Rectangle {
                        id: updateTrackDatabaseRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: parent.top
                        anchors.topMargin: 0

                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            id: updateTrackDatabaseButton
                            text: "Update Track Database"

                            anchors.fill: parent

                            onClicked: {
                                backend.update_track_database()
                            }
                        }
                    }

                    Rectangle {
                        id: cleanSpotifyDatasetRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: updateTrackDatabaseRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        Platform.FolderDialog {
                            id: folderDialog
                            title: "Select Spotify Dataset Folder"
                            
                            onAccepted: {
                                backend.clean_spotify_dataset(folderDialog.folder)
                            }
                        }

                        Button {
                            id: cleanSpotifyDatasetButton
                            text: "Clean Spotify Dataset"

                            anchors.fill: parent

                            onClicked: {
                                folderDialog.open()
                            }
                        }
                    }

                    Rectangle {
                        id: getSpotifyDatasetAudioFeaturesRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: cleanSpotifyDatasetRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        Platform.FileDialog {
                            id: fileDialog
                            title: "Select Spotify Dataset File"
                            nameFilters: ["CSV files (*.csv)"]
                            
                            
                            onAccepted: {
                                backend.get_spotify_dataset_audio_features(fileDialog.file)
                                messageDialog.text = "Audio Features Retrieved to audio_features.csv"
                                messageDialog.open()
                            }
                        }

                        Button {
                            id: getSpotifyDatasetAudioFeaturesButton
                            text: "Get Spotify Dataset Audio Features"

                            anchors.fill: parent

                            onClicked: {
                                fileDialog.open()
                            }
                        }

                    }

                    Rectangle {
                        id: createFullDatasetRect
                        color: "white"
                        radius: 10
                        width: parent.width * 0.85
                        height: parent.height * 0.1

                        anchors.top: getSpotifyDatasetAudioFeaturesRect.bottom
                        anchors.topMargin: parent.height * 0.05

                        anchors.horizontalCenter: parent.horizontalCenter

                        Platform.FileDialog {
                            id: selectDatasetAndAudioFeaturesDialog
                            title: "Select Spotify Dataset and Audio Features Files"
                            fileMode: Platform.FileDialog.OpenFiles
                            nameFilters: ["CSV files (*.csv)"]
                            
                            onAccepted: {
                                loadingIndicator.visible = true
                                    dimOverlay.visible = true
                                    var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                                    timer.interval = 100  // Set the delay time in milliseconds
                                    timer.repeat = false
                                    timer.triggered.connect(function() {
                                        backend.create_full_dataset(selectDatasetAndAudioFeaturesDialog.files)
                                        loadingIndicator.visible = false
                                        dimOverlay.visible = false
                                        dialogMessage.text = "Full Dataset Created"
                                        messageDialog.open()
                                    })
                                    timer.start()
                            }
                        }

                        Button {
                            id: createFullDatasetButton
                            text: "Create Full Dataset"

                            anchors.fill: parent

                            onClicked: {
                                selectDatasetAndAudioFeaturesDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: bookmarksPage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                Component.onCompleted: {
                    listView.model = backend.on_bookmarks_clicked()
                }
                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "#00000000"
                    height: width * 0.12
                    width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Rectangle {
                        id: searchRect
                        width: parent.width 
                        height: parent.height * 0.6
                        color: "white"
                        radius: 10

                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: searchLogoRect
                            width: height
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            Image {
                                width: parent.width * 0.8
                                height: parent.height * 0.8
                                source: "assets/searchBarIcon.svg"
                                anchors.fill: parent
                            }
                        }

                        Rectangle {
                            id: searchInputRect
                            color: "transparent"
                            width: parent.width - 40
                            height: parent.height

                            anchors.left: searchLogoRect.right
                            anchors.leftMargin: 0

                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0               

                            TextField {
                                id: searchTextInput
                                width: parent.width
                                height: parent.height
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                color: "black"
                                placeholderText: "Search"
                                clip: true
                                font.pixelSize: height * 0.6
                                placeholderTextColor: "black"

                                background: Rectangle {
                                    color: "transparent"
                                }

                                onEditingFinished: {
                                    loadingIndicator.visible = true
                                    dimOverlay.visible = true
                                    var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent, 'dynamicTimer')
                                    timer.interval = 100  // Set the delay time in milliseconds
                                    timer.repeat = false
                                    timer.triggered.connect(function() {
                                        listView.model = backend.searchBookmarks(searchTextInput.text, filterComboBox.currentText)
                                        loadingIndicator.visible = false
                                        dimOverlay.visible = false
                                    })
                                    timer.start()
                                    

                                }
                            }   
                        }
                    }

                    
                }

                Rectangle {
                    id: body
                    width: parent.width
                    height: parent.height * 0.85
                    color: "transparent"

                    anchors.top: header.bottom
                    
                    Rectangle {
                        id: filterComboBoxRect
                        width: parent.width
                        height: parent.height * 0.03
                        color: "transparent"

                        anchors.top: parent.top

                        ComboBox {
                            id: filterComboBox
                            width: parent.width * 0.2
                            height: parent.height

                            anchors.right: parent.right
                            anchors.rightMargin: 10

                            model: ["All", "Liked", "Disliked"]

                            Component.onCompleted: {
                                listView.model = backend.filter_saved_tracks(filterComboBox.currentText)

                            }

                            onActivated: listView.model = backend.filter_saved_tracks(filterComboBox.currentText)
                        }

                    }

                    Rectangle {
                    id: listViewRect
                    width: parent.width
                    height: parent.height - filterComboBoxRect.height - 10

                    anchors.top: filterComboBoxRect.bottom
                    anchors.topMargin: 10

                    color: "transparent"

                    ListView {
                        id: listView
        
                            width: parent.width
                            height: parent.height
                            model: []
                            clip: true
                            focus: true

                            delegate: Item {
                                width: ListView.view.width
                                height: 100

                                Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    color: model.index % 2 === 0 ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(255, 255, 255, 0.2)

                                    Rectangle {
                                        id: albumImageRect
                                        width: parent.height * 0.8
                                        height: parent.height * 0.8

                                        anchors.left: parent.left
                                        anchors.leftMargin: 15

                                        anchors.verticalCenter: parent.verticalCenter


                                        Image {
                                            id: albumImage
                                            width: parent.height
                                            height: parent.height
                                            anchors.fill: parent
                                            source: modelData.album_cover
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    Text {
                                        width: parent.width - albumImageRect.width - 90
                                        text: modelData.track_name + " by " + modelData.artist_name
                                        font.pixelSize: parent.height * 0.18
                                        font.weight: Font.DemiBold

                                        anchors.left: albumImageRect.right
                                        anchors.leftMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 4
                                        color: "white"
                                        
                                    }

                                    Rectangle {
                                        id: likeButtonRect
                                        width: parent.height * 0.5
                                        height: parent.height * 0.5
                                        color: "transparent"

                                        anchors.right: parent.right
                                        anchors.rightMargin: 0

                                        anchors.top: parent.top
                                        anchors.topMargin: 0

                                        Image {
                                            id: likeButton
                                            width: parent.height * 0.8
                                            height: parent.height * 0.8
                                            source: modelData.opinion == 1 ? "assets/loveRedIcon.svg" : "assets/loveGreyIcon.svg"
                                            fillMode: Image.PreserveAspectFit
                                            anchors.centerIn: parent


                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (likeButton.source == "assets/loveGreyIcon.svg") {
                                                        likeButton.source = "assets/loveRedIcon.svg";
                                                        dislikeButton.source = "assets/dislikeGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        } 
                                                    }

                                                    else {
                                                        likeButton.source = "assets/loveGreyIcon.svg";
                                                        dislikeButton.source = "assets/dislikeGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        }

                                                    }
                                                
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: dislikeButtonRect
                                        width: parent.height * 0.5
                                        height: parent.height * 0.5
                                        color: "transparent"

                                        anchors.top: likeButtonRect.bottom
                                        anchors.topMargin: 0

                                        anchors.right: parent.right
                                        anchors.rightMargin: 0

                                        Image {
                                            id: dislikeButton
                                            width: parent.height * 0.8
                                            height: parent.height * 0.8
                                            source: modelData.opinion == 0 ? "assets/dislikeRedIcon.svg" : "assets/dislikeGreyIcon.svg"
                                            fillMode: Image.PreserveAspectFit
                                            anchors.centerIn: parent


                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (dislikeButton.source == "assets/dislikeGreyIcon.svg") {
                                                        dislikeButton.source = "assets/dislikeRedIcon.svg";
                                                        likeButton.source = "assets/loveGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        } 
                                                    }

                                                    else {
                                                        dislikeButton.source = "assets/dislikeGreyIcon.svg";
                                                        likeButton.source = "assets/loveGreyIcon.svg";
                                                        if (dislikeButton.source == "assets/dislikeRedIcon.svg" && likeButton.source == "assets/loveGreyIcon.svg") {
                                                            var opinion = 0;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else if (dislikeButton.source == "assets/dislikeGreyIcon.svg" && likeButton.source == "assets/loveRedIcon.svg") {
                                                            var opinion = 1;
                                                            backend.search_save_opinion(modelData.track_uri, opinion);
                                                        } else {
                                                            backend.search_save_opinion(modelData.track_uri, -1);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: footer
                    width: parent.width
                    height: parent.height - header.height - body.height
                    color: "transparent"

                    anchors.top: body.bottom
                
                    ToolBar {
                        id: menuBar
                        width: parent.width
                        height: parent.height 
                        anchors.bottom: parent.bottom
                        background: Rectangle {
                            color: "transparent" 
                        }

                        RowLayout {
                            id: menuLayout
                            spacing: 0
                            anchors.fill: parent

                            ToolButton {
                                id: searchButton
                                icon.source: "assets/searchBarIcon.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: {
                                    stackView.push(searchPage, StackView.Immediate)
                                }
                            }

                            ToolButton {
                                id: leaderboardButton
                                icon.source: "assets/leaderboardIcon.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: console.log("Leaderboard Clicked") // Replace with navigation logic
                            }

                            ToolButton {
                                id: recommendationsButton
                                icon.source: "assets/Blank.svg" // Replace with your icon path
                                icon.width: 104
                                icon.height: 66
                                background: Rectangle { 
                                    color: "transparent"
                                }
                                
                                Image {
                                    source: "assets/Logo.png"
                                    width: parent.width * 1.2 // Icon size is larger than the button
                                    height: parent.height * 1.2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 0// Keep icon centered in the button
                                    fillMode: Image.PreserveAspectFit
                                }

                                Layout.fillWidth: false
                                Layout.fillHeight: true
                                onClicked: { 
                                    stackView.push(reccomendationsPage, StackView.Immediate);
                                    backend.on_recommendation_clicked(-1);
                                }
                            }

                            ToolButton {
                                id: profileButton
                                icon.source: "assets/profile.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(profilePage, StackView.Immediate) 
                            }

                            ToolButton {
                                id: bookmarksButton
                                icon.source: "assets/bookmarksIconBlack.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(bookmarksPage, StackView.Immediate) // Replace with navigation logic
                            }
                        }
                    }
                }   
            }
        }
    }

    Component {
        id: profilePage

        Rectangle {
            id: backgroundRect
            width: parent.width
            height: parent.height

            Rectangle {
                id: gradientRect
                color: "#ffffff"
                anchors.fill: parent

                Component.onCompleted: {
                    profileNameText.text = "Hi " + backend.get_username()
                    
                    var current_track = backend.get_currently_playing()
                    var top_genres = backend.get_top_genres()
                    var top_artists = backend.get_top_artists()
                    if (current_track.playing_status == true) {
                        albumImage.source = current_track.album_cover
                        trackInfoText.text = current_track.track_name + " by " + current_track.artist_name

                    } else {
                        currentlyPlayingRect.visible = false
                        currentlyPlayingTextRect.visible = false
                    }

                    if (top_genres.length > 0) {
                        topGenresInfoText.text = top_genres[0] + ", " + top_genres[1] + ", " + top_genres[2] + ", " + top_genres[3] + ", " + top_genres[4] 
                    } else {
                        topGenresTextRect.visible = false
                        topGenresRect.visible = false
                    }   
                    
                    if (top_artists.length > 0) {
                        topArtists1InfoText.text = top_artists[0].name
                        topArtists2InfoText.text = top_artists[1].name
                        topArtists3InfoText.text = top_artists[2].name
                        topArtists1Image.source = top_artists[0].images[0].url
                        topArtists2Image.source = top_artists[1].images[0].url
                        topArtists3Image.source = top_artists[2].images[0].url
                        artist1ToolButton.url = top_artists[0].external_urls.spotify
                        artist2ToolButton.url = top_artists[1].external_urls.spotify
                        artist3ToolButton.url = top_artists[2].external_urls.spotify
                    } else {
                        topArtistsRect.visible = false
                        topArtistsTextRect.visible = false
                    }
                            
                }

                onVisibleChanged: {
                    if (visible) {
                        var current_track = backend.get_currently_playing()
                        var top_genres = backend.get_top_genres()
                        var top_artists = backend.get_top_artists()
                        albumImage.source = current_track.album_cover
                        trackInfoText.text = current_track.track_name + " by " + current_track.artist_name
                        topGenresInfoText.text = top_genres[0] + ", " + top_genres[1] + ", " + top_genres[2] + ", " + top_genres[3] + ", " + top_genres[4] 
                        topArtists1InfoText.text = top_artists[0].name
                        topArtists2InfoText.text = top_artists[1].name
                        topArtists3InfoText.text = top_artists[2].name
                        topArtists1Image.source = top_artists[0].images[0].url
                        topArtists2Image.source = top_artists[1].images[0].url
                        topArtists3Image.source = top_artists[2].images[0].url
                        artist1ToolButton.url = top_artists[0].external_urls.spotify
                        artist2ToolButton.url = top_artists[1].external_urls.spotify
                        artist3ToolButton.url = top_artists[2].external_urls.spotify

                    }
                }

                gradient: Gradient {
                    GradientStop {
                        position: 1
                        color: "#434343"
                    }

                    GradientStop {
                        position: 0
                        color: "#171616"
                    }
                    orientation: Gradient.Horizontal
                }

                Rectangle {
                    id: header
                    color: "#00000000"
                    height: width * 0.12
                    width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Rectangle {
                        id: settingsRect
                        color: "transparent"
                        width: parent.width * 0.1
                        height: parent.height

                        anchors.right: parent.right
                        anchors.rightMargin: parent.height * 0.15

                        ToolBar {
                            id: settingsBar
                            width: parent.width
                            height: parent.height // Adjust height as needed
                            anchors.fill: parent
                            background: Rectangle {
                                color: "transparent"
                            }

                            RowLayout {
                                id: settingsLayout
                                anchors.fill: parent

                                ToolButton {
                                    id: settingsButton
                                    icon.source: "assets/Blank.svg" // Replace with your icon path
                                    icon.width: parent.width * 0.8
                                    icon.height: parent.height * 0.8

                                    onClicked: stackView.push(settingsPage) // Replace with navigation logic


                                    Image {
                                        id: settingsIcon
                                        source: "assets/settingsIconWhite.svg"
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: body
                    width: parent.width
                    height: parent.height * 0.85
                    color: "transparent"

                    anchors.top: header.bottom

                    Rectangle {
                        id: profileNameRect
                        width: parent.width * 0.85
                        height: parent.height * 0.07
                        color: "transparent"
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: profileNameText
                            text: ""
                            color: "white"
                            font.family: "Arial"
                            font.pixelSize: parent.height * 0.9
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter

                        }
                    }

                    Rectangle {
                        id: profileNameUnderlineRect
                        height: 3
                        width: profileNameRect.width
                        color: "white"
                        
                        anchors.top: profileNameRect.bottom
                        anchors.topMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        id: currentlyPlayingTextRect
                        width: parent.width * 0.85
                        height: parent.height * 0.07
                        color: "transparent"

                        anchors.top: profileNameUnderlineRect.bottom
                        anchors.topMargin: 10

                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: currentlyPlayingText
                            text: "Currently Playing: "
                            color: "white"
                            font.pixelSize: parent.height * 0.6
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                        }

                    }

                    Rectangle {
                        id: currentlyPlayingRect
                        width: parent.width * 0.85
                        height: parent.height * 0.1
                        color: Qt.rgba(255, 255, 255, 0.1)

                        anchors.top: currentlyPlayingTextRect.bottom
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: albumImageRect
                            width: parent.height * 0.8
                            height: parent.height * 0.8

                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: albumImage
                                source: "assets/Blank.svg"
                                width: parent.height
                                height: parent.height
                            }
                        }

                        Rectangle {
                            id: trackInfoRect
                            width: parent.width - albumImageRect.width - 10
                            height: parent.height
                            color: "transparent"
                            anchors.left: albumImageRect.right
                            anchors.leftMargin: 10

                            Text {
                                id: trackInfoText
                                text: ""
                                color: "white" 
                                font.pixelSize: parent.height * 0.3
                                font.weight: Font.DemiBold
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                width: parent.width
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                            }
                        }
                    }

                    Rectangle {
                        id: topGenresTextRect
                        width: parent.width * 0.85
                        height: parent.height * 0.07
                        color: "transparent"

                        anchors.top: currentlyPlayingRect.visible ? currentlyPlayingRect.bottom : profileNameUnderlineRect.bottom
                        anchors.topMargin: 10

                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: topGenresText
                            text: "Top Genres: "
                            color: "white"
                            font.pixelSize: parent.height * 0.6
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter                                
                            anchors.left: parent.left
                        }
                    }

                    Rectangle {
                        id: topGenresRect
                        width: parent.width * 0.85
                        height: parent.height * 0.1
                        color: Qt.rgba(255, 255, 255, 0.1)

                        anchors.top: topGenresTextRect.bottom
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: topGenresInfoTextRect
                            width: parent.width
                            height: parent.height
                            color: "transparent"
                            anchors.fill: parent

                            Text {
                                id: topGenresInfoText
                                text: ""
                                color: "white" 
                                font.pixelSize: parent.height * 0.3
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                            }
                        }
                    }

                    Rectangle {
                        id: topArtistsTextRect
                        width: parent.width * 0.85
                        height: parent.height * 0.07
                        color: "transparent"

                        anchors.top: topGenresRect.bottom
                        anchors.topMargin: 10

                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: topArtistsText
                            text: "Top Artists: "
                            color: "white"
                            font.pixelSize: parent.height * 0.6
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter                                
                            anchors.left: parent.left
                        }
                    }

                    Rectangle {
                        id: topArtistsRect
                        width: parent.width * 0.85
                        height: parent.height * 0.3
                        color: Qt.rgba(255, 255, 255, 0.1)

                        anchors.top: topArtistsTextRect.bottom
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            id: topArtists1ImageRect
                            width: parent.height * 0.25
                            height: parent.height * 0.25

                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            anchors.top: parent.top
                            anchors.topMargin: 10

                            Image {
                                id: topArtists1Image
                                width: parent.width
                                height: parent.height
                            }

                        }

                        Rectangle {
                            id: topArtists1InfoTextRect
                            width: parent.width - topArtists1ImageRect.width - 10 - artist1ToolButton.width
                            height: parent.height * 0.25
                            color: "transparent"
                            anchors.left: topArtists1ImageRect.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: topArtists1ImageRect.verticalCenter

                            Text {
                                id: topArtists1InfoText
                                text: ""
                                color: "white" 
                                font.pixelSize: parent.height * 0.45
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                            }
                        }

                        Rectangle {
                            id: topArtists2ImageRect
                            width: parent.height * 0.25
                            height: parent.height * 0.25

                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: topArtists2Image
                                width: parent.width
                                height: parent.height
                            }

                        }

                        Rectangle {
                            id: topArtists2InfoTextRect
                            width: parent.width - topArtists2ImageRect.width - 10 - artist2ToolButton.width
                            height: parent.height * 0.25
                            color: "transparent"
                            anchors.left: topArtists2ImageRect.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: topArtists2InfoText
                                text: ""
                                color: "white" 
                                font.pixelSize: parent.height * 0.45
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                            }
                        }

                        Rectangle {
                            id: topArtists3ImageRect
                            width: parent.height * 0.25
                            height: parent.height * 0.25

                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            anchors.bottom: topArtistsRect.bottom
                            anchors.bottomMargin: 10

                            Image {
                                id: topArtists3Image
                                width: parent.width
                                height: parent.height
                            }

                        }

                        Rectangle {
                            id: topArtists3InfoTextRect
                            width: parent.width - topArtists3ImageRect.width - 10 - artist3ToolButton.width
                            height: parent.height * 0.25
                            color: "transparent"
                            anchors.left: topArtists3ImageRect.right
                            anchors.leftMargin: 10

                            anchors.verticalCenter: topArtists3ImageRect.verticalCenter

                            Text {
                                id: topArtists3InfoText
                                text: ""
                                color: "white" 
                                font.pixelSize: parent.height * 0.45
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                            }
                        }
                        ToolButton {
                            id: artist1ToolButton
                            height: parent.height * 0.3
                            width: height

                            anchors.right: parent.right
                            anchors.top: parent.top

                            icon.source: "assets/spotify.png"
                            icon.width: width
                            icon.height: height
                            property string url: ""
                            onClicked: {
                                Qt.openUrlExternally(url)
                            }
                        }
                        
                        ToolButton {
                            id: artist2ToolButton
                            height: parent.height * 0.3
                            width: height

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            icon.source: "assets/spotify.png"
                            icon.width: width
                            icon.height: height
                            property string url: ""
                            onClicked: {
                                Qt.openUrlExternally(url)
                            }
                        }

                        ToolButton {
                            id: artist3ToolButton
                            height: parent.height * 0.3
                            width: height

                            anchors.right: parent.right
                            anchors.bottom: parent.bottom

                            icon.source: "assets/spotify.png"
                            icon.width: width
                            icon.height: height
                            property string url: ""
                            onClicked: {
                                Qt.openUrlExternally(url)
                            }
                        }
                    }
                }

                Rectangle {
                    id: footer
                    width: parent.width
                    height: parent.height - header.height - body.height
                    color: "transparent"

                    anchors.top: body.bottom
                

                    ToolBar {
                        id: menuBar
                        width: parent.width
                        height: parent.height 
                        anchors.bottom: parent.bottom
                        background: Rectangle {
                            color: "transparent" 
                        }

                        RowLayout {
                            id: menuLayout
                            spacing: 0
                            anchors.fill: parent

                            ToolButton {
                                id: searchButton
                                icon.source: "assets/searchBarIcon.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: {
                                    stackView.push(searchPage, StackView.Immediate)
                                }
                            }

                            ToolButton {
                                id: leaderboardButton
                                icon.source: "assets/leaderboardIcon.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: console.log("Leaderboard Clicked") // Replace with navigation logic
                            }

                            ToolButton {
                                id: recommendationsButton
                                icon.source: "assets/Blank.svg" // Replace with your icon path
                                icon.width: 104
                                icon.height: 66
                                background: Rectangle { 
                                    color: "transparent"
                                }
                                
                                Image {
                                    source: "assets/Logo.png"
                                    width: parent.width * 1.2 
                                    height: parent.height * 1.2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 0
                                    fillMode: Image.PreserveAspectFit
                                }

                                Layout.fillWidth: false
                                Layout.fillHeight: true
                                onClicked: { 
                                    stackView.push(reccomendationsPage, StackView.Immediate);
                                    backend.on_recommendation_clicked(-1);
                                }
                            }

                            ToolButton {
                                id: profileButton
                                icon.source: "assets/profile.svg" 
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: {
                                    stackView.push(profilePage, StackView.Immediate);
                                    var current_track = backend.get_currently_playing();
                                    var top_genres = backend.get_top_genres();

                                    if (current_track.playing_status == true) {
                                        albumImage.source = current_track.album_cover
                                        trackInfoText.text = current_track.track_name + " by " + current_track.artist_name

                                    } else {
                                        currentlyPlayingRect.visible = false
                                        currentlyPlayingTextRect.visible = false
                                    }

                                    if (top_genres.length > 0) {
                                        topGenresInfoText.text = top_genres[0] + ", " + top_genres[1] + ", " + top_genres[2] + ", " + top_genres[3] + ", " + top_genres[4] 
                                    } else {
                                        topGenresTextRect.visible = false
                                        topGenresRect.visible = false
                                    }           
                                }
                            }

                            ToolButton {
                                id: bookmarksButton
                                icon.source: "assets/bookmarksIconBlack.svg" // Replace with your icon path
                                icon.color: "grey"
                                icon.width: 36
                                icon.height: 37
                                
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: stackView.push(bookmarksPage, StackView.Immediate) // Replace with navigation logic
                            }
                        }
                    }
                }
            }
        }
    }
}




