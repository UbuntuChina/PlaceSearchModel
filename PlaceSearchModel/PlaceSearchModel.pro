TEMPLATE = aux
TARGET = PlaceSearchModel

RESOURCES += PlaceSearchModel.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true) \
             $$files(*.png,true)

CONF_FILES +=  PlaceSearchModel.apparmor \
               PlaceSearchModel.png

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)               

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               PlaceSearchModel.desktop

#specify where the qml/js files are installed to
qml_files.path = /PlaceSearchModel
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /PlaceSearchModel
config_files.files += $${CONF_FILES}

#install the desktop file, a translated version is 
#automatically created in the build directory
desktop_file.path = /PlaceSearchModel
desktop_file.files = $$OUT_PWD/PlaceSearchModel.desktop
desktop_file.CONFIG += no_check_exist

INSTALLS+=config_files qml_files desktop_file

