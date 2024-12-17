import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Shapes 1.15
import QtQuick.Layouts
import QtMultimedia

ApplicationWindow {
    id: appWindow
    title: "Track.io"
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
            text: "This is a centered message"
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
                        id: logoHeaderRect
                        width: parent.height * 0.8
                        height: parent.height * 0.8
                        color: "transparent"

                        anchors.verticalCenter: parent.verticalCenter

                        anchors.left: parent.left
                        anchors.leftMargin: parent.height * 0.15

                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.15

                        Image {
                            id: logo
                            width: parent.height * 0.8
                            height: parent.height * 0.8
                            anchors.fill: parent

                            source: "assets/Logo.png"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Rectangle {
                        id: logoTextRect
                        width: height
                        height: parent.height
                        color: "transparent"

                        anchors.left: logoHeaderRect.right
                        anchors.leftMargin: -5

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -10

                        Text {
                            id: logoText
                            color: "#ffffff"
                            anchors.fill: parent
                            text: ".io"
                            font.weight: Font.Bold
                            font.pixelSize: parent.width * 0.55
                        }
                    }

                }

                    Rectangle {
                        id: loginTextRect
                        color: "transparent"
                        height: header.height * 0.9
                        width: parent.width

                        anchors.top: header.bottom
                        anchors.topMargin: height * 2

                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * 0.08

                        anchors.right: parent.right
                        anchors.rightMargin: parent.width * 0.08

                        Text {
                            id: loginText
                            color: "#ffffff"
                            text: "Login"
                            font.pixelSize: parent.width * 0.11
                            anchors.fill: parent
                            font.weight: Font.DemiBold
                            font.bold: true
                        }

                        Rectangle {
                            id: emailBox
                            color: "#ffffff"
                            radius: 10
                            width: parent.width * 0.83
                            height: parent.height * 0.85
                            
                            anchors.left: parent.left
                            anchors.leftMargin: 0

                            anchors.right: parent.right
                            anchors.rightMargin: 0

                            anchors.top: parent.bottom
                            anchors.topMargin: parent.height * 0.2

                            Rectangle {
                                id: emailRectangle
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
                                width: emailBox.width - emailRectangle.width * 1.4
                                anchors.left: emailRectangle.right
                                anchors.leftMargin: 5
                                anchors.verticalCenter: emailRectangle.verticalCenter
                                font.pixelSize: emailText.font.pixelSize
                                clip: true
                                font.weight: Font.Medium
                                font.bold: true
                            }

                        }

                            Rectangle {
                                id: passwordBox
                                color: "#ffffff"
                                radius: 10

                                width: parent.width
                                height: parent.height * 0.85
                                // Fix anchor conflicts and margins
                                anchors.left: parent.left
                                anchors.leftMargin: 0

                                anchors.right: parent.right
                                anchors.rightMargin: 0

                                anchors.top: emailBox.bottom
                                anchors.topMargin: parent.height * 0.4

                                Rectangle {
                                    id: passwordRectangle
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
                                    anchors.left: passwordRectangle.right
                                    anchors.leftMargin: 5
                                    anchors.verticalCenter: passwordRectangle.verticalCenter
                                    width: passwordBox.width - passwordRectangle.width * 1.25
                                    font.pixelSize: passwordText.font.pixelSize
                                    clip: true
                                    font.weight: Font.Medium
                                    font.bold: true
                                    echoMode: TextInput.Password
                                }
                            }

                            Rectangle {
                                id: loginBox
                                color: "#ffffff"
                                radius: 10
                                width: parent.width * 0.83
                                height: parent.height * 0.7

                                anchors.top: passwordBox.bottom
                                anchors.topMargin: parent.height * 0.4

                                anchors.right: parent.right
                                anchors.rightMargin: 0

                                anchors.left: parent.left
                                anchors.leftMargin: 0

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
                                        font.pixelSize: loginBox.height * 0.5
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.weight: Font.DemiBold
                                        font.bold: true
                                    }
                                    onClicked: {
                                        if (backend.on_login_clicked(emailTextInput.text, passwordTextInput.text)) {
                                            
                                            stackView.push(reccomendationsPage, StackView.Immediate)
                                        }
                                        
                                    }
                                }
                            }

                            Rectangle {
                                id: registerBox
                                radius: 10
                                border.color: "#ffffff"
                                border.width: 2
                                width: parent.width
                                height: parent.height * 0.7
                                color: "#00e0ea75"

                                anchors.top: loginBox.bottom
                                anchors.topMargin: parent.height * 0.2

                                anchors.right: parent.right
                                anchors.rightMargin: 0

                                anchors.left: parent.left
                                anchors.leftMargin: 0

                                Button {
                                    id: button
                                    visible: true
                                    text: "Register"
                                    anchors.fill: parent
                                    display: AbstractButton.TextOnly
                                    background: null

                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: registerBox.height * 0.5
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        if (backend.on_register_clicked(emailTextInput.text, passwordTextInput.text)) {
                                            stackView.push(registerDetailsPage, StackView.Immediate)
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        }
    Component {
        id: reccomendationsPage

        Item {
            width: parent.width
            height: parent.height

            Rectangle {
                id: backgroundRect
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
                        id: logoHeaderRect
                        width: parent.height * 0.8
                        height: parent.height * 0.8
                        color: "transparent"

                        anchors.verticalCenter: parent.verticalCenter

                        anchors.left: parent.left
                        anchors.leftMargin: parent.height * 0.15

                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.15

                        Image {
                            id: logo
                            width: parent.height * 0.8
                            height: parent.height * 0.8
                            anchors.fill: parent

                            source: "assets/Logo.png"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Rectangle {
                        id: logoTextRect
                        width: height
                        height: parent.height
                        color: "transparent"

                        anchors.left: logoHeaderRect.right
                        anchors.leftMargin: -5

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -10

                        Text {
                            id: logoText
                            color: "#ffffff"
                            anchors.fill: parent
                            text: ".io"
                            font.weight: Font.Bold
                            font.pixelSize: parent.width * 0.55
                        }
                    }

                Rectangle {
                    id: settingsRect
                    color: "transparent"
                    width: parent.width * 0.1
                    height: parent.height

                    anchors.right: parent.right
                    anchors.rightMargin: parent.height * 0.15

                    anchors.top: parent.top
                    anchors.topMargin: 0

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

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
                                
                                onClicked: stackView.push(loginPage) // Replace with navigation logic


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
                id: imageRect
                color: "transparent"
                width: height
                height: parent.height * 0.4

                anchors.top: header.bottom
                anchors.topMargin: header.height

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
                anchors.topMargin: 0
            }

            Text {
                id: trackName
                color: "#ffffff"
                text: backend.trackName
                font.pointSize: parent.width * 0.03

                anchors.centerIn: trackNameRect
            }

            Rectangle {
                id: rectangle4
                color: "transparent"
                width: parent.width
                height: parent.height * 0.35

                anchors.top: trackNameRect.bottom
                anchors.topMargin: 0
            }

            Rectangle {
                id: playbackRect
                width: parent.width
                height: parent.height * 0.1
                color: "transparent"

                anchors.left: rectangle4.left
                anchors.leftMargin: parent.width * 0.1

                anchors.right: rectangle4.right
                anchors.rightMargin: parent.width * 0.1

                anchors.top: rectangle4.top
                anchors.topMargin: 0

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

                    width: playbackRect.width * 0.13
                    height: width
                    fillMode: Image.PreserveAspectFit

                    anchors.left: playbackRect.left
                    anchors.leftMargin: 0

                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                mediaPlayer.pause();
                            }

                            else {
                                console.log("playing");
                                mediaPlayer.play();
                                console.log("Playback state: " + mediaPlayer.playbackState);
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
                                to: mediaPlayer.duration
                                value: mediaPlayer.position


                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: 10



                                Connections {
                                    target: mediaPlayer
                                    function onPositionChanged() {
                                        progressBar.value = mediaPlayer.position;
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
                                    console.log("DISLIKE clicked");
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

                Rectangle {
                    id: swipeArea
                    width: parent.width
                    height: parent.height * 1.8
                    color: "transparent"

                    anchors.top: playbackRect.bottom
                    anchors.topMargin: 0

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

            ToolBar {
                id: menuBar
                width: parent.width
                height: parent.height * 0.1 // Adjust height as needed
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
                        icon.width: width * 0.5
                        icon.height: height * 0.5
                        

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: console.log("Search Clicked") // Replace with navigation logic
                    }

                    ToolButton {
                        id: leaderboardButton
                        icon.source: "assets/leaderboardIcon.svg" // Replace with your icon path
                        icon.color: "grey"
                        icon.width: width * 0.5
                        icon.height: height * 0.5
                        
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: console.log("Leaderboard Clicked") // Replace with navigation logic
                    }

                    ToolButton {
                        id: recommendationsButton
                        icon.source: "assets/Blank.svg" // Replace with your icon path
                        icon.width: width * 0.9
                        icon.height: height * 0.9
                        background: Rectangle { 
                            color: "transparent"

                        }
                        
                        Image {
                            source: "assets/Logo.png"
                            width: recommendationsButton.width * 1.2 // Icon size is larger than the button
                            height: recommendationsButton.height * 1.2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0// Keep icon centered in the button
                            fillMode: Image.PreserveAspectFit
                        }

                        Layout.fillWidth: false
                        Layout.fillHeight: true
                        onClicked: { 
                            console.log("Recommendations Clicked");
                            stackView.push(reccomendationsPage, StackView.Immediate);
                            backend.on_recommendation_clicked();

                        }

                    }

                    ToolButton {
                        id: profileButton
                        icon.source: "assets/profile.svg" // Replace with your icon path
                        icon.color: "grey"
                        icon.width: width * 0.5
                        icon.height: height * 0.5
                        
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: console.log("Profile Clicked") // Replace with navigation logic
                    }

                    ToolButton {
                        id: bookmarksButton
                        icon.source: "assets/bookmarksIconBlack.svg" // Replace with your icon path
                        icon.color: "grey"
                        icon.width: width * 0.5
                        icon.height: height * 0.5
                        
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: console.log("Bookmarks Clicked") // Replace with navigation logic
                    }
                }
            }

            }
        }
    }

    Component {
        id: registerDetailsPage

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
                        id: logoHeaderRect
                        width: parent.height * 0.8
                        height: parent.height * 0.8
                        color: "transparent"

                        anchors.verticalCenter: parent.verticalCenter

                        anchors.left: parent.left
                        anchors.leftMargin: parent.height * 0.15

                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.15

                        Image {
                            id: logo
                            width: parent.height * 0.8
                            height: parent.height * 0.8
                            anchors.fill: parent

                            source: "assets/Logo.png"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Rectangle {
                        id: logoTextRect
                        width: height
                        height: parent.height
                        color: "transparent"

                        anchors.left: logoHeaderRect.right
                        anchors.leftMargin: 0

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -5

                        Text {
                            id: logoText
                            color: "#ffffff"
                            anchors.fill: parent
                            text: ".io"
                            font.weight: Font.Bold
                            font.pointSize: parent.width * 0.5
                        }
                    }

                }

                    Rectangle {
                        id: userDetailsTextRect
                        color: "transparent"
                        height: header.height * 0.9
                        width: parent.width

                        anchors.top: header.bottom
                        anchors.topMargin: height * 2

                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * 0.08

                        anchors.right: parent.right
                        anchors.rightMargin: parent.width * 0.08

                        Text {
                            id: userDetailsText
                            color: "#ffffff"
                            text: "User Details"
                            font.pointSize: parent.width * 0.08
                            anchors.fill: parent
                            font.weight: Font.DemiBold
                            font.bold: true
                        }

                        Rectangle {
                            id: firstNameBox
                            color: "#ffffff"
                            radius: 10
                            width: parent.width * 0.83
                            height: parent.height * 0.85
                            // Fix anchor conflicts and margins
                            anchors.left: parent.left
                            anchors.leftMargin: 0

                            anchors.right: parent.right
                            anchors.rightMargin: 0

                            anchors.top: parent.bottom
                            anchors.topMargin: parent.height * 0.2

                            Rectangle {
                                id: firstNameRectangle
                                color: "transparent"
                                width: firstNameText.width
                                height: parent.height
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 0

                                anchors.top: parent.top
                                anchors.topMargin: 0

                                anchors.left: parent.left
                                anchors.leftMargin: 5

                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: firstNameText
                                    color: "#000000"
                                    text: "First Name:"
                                    font.pointSize: parent.height * 0.3
                                    anchors.centerIn: parent
                                    font.weight: Font.DemiBold
                                    font.bold: true
                                }
                            }

                            TextInput {
                                id: firstNameTextInput
                                width: firstNameBox.width - firstNameRectangle.width * 1.25
                                anchors.left: firstNameRectangle.right
                                anchors.leftMargin: 5
                                anchors.verticalCenter: firstNameRectangle.verticalCenter
                                font.pixelSize: firstNameText.font.pixelSize
                                clip: true
                                font.weight: Font.Medium
                                font.bold: true
                            }

                        }

                            Rectangle {
                                id: lastNameBox
                                color: "#ffffff"
                                radius: 10

                                width: parent.width
                                height: parent.height * 0.85
                                // Fix anchor conflicts and margins
                                anchors.left: parent.left
                                anchors.leftMargin: 0

                                anchors.right: parent.right
                                anchors.rightMargin: 0

                                anchors.top: firstNameBox.bottom
                                anchors.topMargin: parent.height * 0.4

                                Rectangle {
                                    id: lastNameRectangle
                                    color: "transparent"
                                    width: lastNameText.width
                                    height: parent.height
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 0

                                    anchors.top: parent.top
                                    anchors.topMargin: 0

                                    anchors.left: parent.left
                                    anchors.leftMargin: 5

                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        id: lastNameText
                                        color: "#000000"
                                        text: "Last Name:"
                                        font.pointSize: parent.height * 0.3
                                        anchors.centerIn: parent
                                        font.weight: Font.DemiBold
                                        font.bold: true

                                    }
                                }

                                TextInput {
                                    id: lastNameTextInput
                                    anchors.left: lastNameRectangle.right
                                    anchors.leftMargin: 5
                                    anchors.verticalCenter: lastNameRectangle.verticalCenter
                                    width: lastNameBox.width - lastNameRectangle.width * 1.25
                                    font.pixelSize: lastNameText.font.pixelSize
                                    clip: true
                                    font.weight: Font.Medium
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                id: enterBox
                                color: "#ffffff"
                                radius: 10
                                width: parent.width * 0.83
                                height: parent.height * 0.7

                                anchors.top: lastNameBox.bottom
                                anchors.topMargin: parent.height * 0.4

                                anchors.right: parent.right
                                anchors.rightMargin: 0

                                anchors.left: parent.left
                                anchors.leftMargin: 0

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
                                    text: "Create Account"
                                    anchors.fill: parent
                                    display: AbstractButton.TextOnly
                                    background: null

                                    contentItem: Text {
                                        text: parent.text
                                        color: "black"
                                        font.pixelSize: enterBox.height * 0.5
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.weight: Font.DemiBold
                                        font.bold: true
                                    }
                                    onClicked: {
                                        backend.on_register_submit(firstNameTextInput.text, lastNameTextInput.text)
                                        stackView.push(reccomendationsPage, StackView.Immediate)
                                    }
                                }
                            }
                    }
                }
            }
        }
}


