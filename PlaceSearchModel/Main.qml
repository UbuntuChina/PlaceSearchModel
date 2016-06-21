import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtLocation 5.3
import QtPositioning 5.2

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "placesearchmodel.liu-xiao-guo"

    width: units.gu(60)
    height: units.gu(85)

    property bool centerCurrent: true

    Plugin {
        id: myPlugin
        name: "osm"
    }

    PositionSource {
        id: positionSource
        property variant lastSearchPosition: curLocation
        active: true
        updateInterval: 5000
        onPositionChanged:  {
            var currentPosition = positionSource.position.coordinate

            if ( centerCurrent ) {
                map.center = currentPosition
            }

            var distance = currentPosition.distanceTo(lastSearchPosition)
            //            if (distance > 500) {
            // 500m from last performed pizza search
            lastSearchPosition = currentPosition
            searchModel.searchArea = QtPositioning.circle(currentPosition)
            searchModel.update()
            //            }
        }
    }

    property variant curLocation: QtPositioning.coordinate( 59.93, 10.76, 0)

    PlaceSearchModel {
        id: searchModel
        plugin: myPlugin

        searchTerm: "KFC"
        searchArea: QtPositioning.circle(curLocation)

        Component.onCompleted: update()
    }

    Connections {
        target: searchModel
        onStatusChanged: {
            if (searchModel.status == PlaceSearchModel.Error)
                console.log(searchModel.errorString());
        }
    }

    Component {
        id: pop
        Popover {
            id: popover
            width: units.gu(20)
            property var model
            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        switch (model.type) {
                        case PlaceSearchModel.UnknownSearchResult:
                            return "type: UnknownSearchResult"
                        case PlaceSearchModel.PlaceResult:
                            return "type: PlaceResult"
                        case PlaceSearchModel.ProposedSearchResult:
                            return "type: ProposedSearchResult"
                        }
                    }
                    fontSize: "medium"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "title: " + model.title
                    fontSize: "medium"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "distance: " + (model.distance).toFixed(2) + "m"
                    fontSize: "medium"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "sponsored: " + model.sponsored
                    fontSize: "medium"
                }
            }
        }
    }

    Page {
        id: page
        header: standardHeader

        PageHeader {
            id: standardHeader
            visible: page.header === standardHeader
            title: "PlaceSearchModel"
            trailingActionBar.actions: [
                Action {
                    iconName: "edit"
                    text: "Edit"
                    onTriggered: page.header = editHeader
                }
            ]
        }

        PageHeader {
            id: editHeader
            visible: page.header === editHeader
            leadingActionBar.actions: [
                Action {
                    iconName: "back"
                    text: "Back"
                    onTriggered: {
                        page.header = standardHeader
                    }
                }
            ]
            contents: TextField {
                id: input
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                placeholderText: "input words .."
                text: "KFC"

                onAccepted: {
                    // clear all of the markers
                    mapItemView.model.reset()

                    searchModel.searchTerm = text
                    searchModel.update();
                }
            }
        }

        Item  {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                top: page.header.bottom
            }

            Map {
                id: map
                anchors.fill: parent
                plugin: Plugin {
                    name: "osm"
                }
                center: curLocation
                zoomLevel: 13

                gesture {
                    onPanFinished: {
                        centerCurrent = false
                    }
                }

                MapCircle {
                    id: mylocation
                    center: positionSource.position.coordinate
                    radius: units.gu(4)
                    color: "yellow"
                }

                MapItemView {
                    id: mapItemView
                    model: searchModel
                    delegate: MapQuickItem {
                        id: mapitem
                        coordinate: place.location.coordinate

                        anchorPoint.x: image.width * 0.5
                        anchorPoint.y: image.height

                        sourceItem: Column {
                            Image {
                                width: units.gu(3)
                                height: width
                                id: image
                                source: "marker.png"
                            }
                            Text { text: title; font.bold: true }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                onClicked: PopupUtils.open(pop, mapitem, { 'model': model })
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    zoomLevel = 15
                }
            }
        }

    }
}

