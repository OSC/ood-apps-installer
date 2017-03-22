#!/bin/bash

SRC_DIR=~/ood/src/test

 DASHBOARD_VERSION="v1.10.0"
     SHELL_VERSION="v1.1.2"
     FILES_VERSION="v1.3.1"
    EDITOR_VERSION="v1.2.3"
ACTIVEJOBS_VERSION="v1.3.1"
    MYJOBS_VERSION="v2.1.2"

mkdir -p $SRC_DIR
cd $SRC_DIR

build_rails() {
    scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle > /dev/null
    scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production > /dev/null
    scl enable rh-ruby22 nodejs010 -- bin/rake tmp:clear > /dev/null
}

build_node() {
    scl enable git19 nodejs010 -- npm install > /dev/null
}

copy_app() {
    echo "should we requre sudo to do the copy to deployment?"
}

install_dashboard() {
    cd $SRC_DIR
    scl enable git19 -- git clone https://github.com/OSC/ood-dashboard.git dashboard
    cd dashboard
    scl enable git19 -- git checkout tags/$DASHBOARD_VERSION
    build_rails
}

install_shell() {
    cd $SRC_DIR
    scl enable git19 -- git clone https://github.com/OSC/ood-shell.git shell
    cd shell
    scl enable git19 -- git checkout tags/$SHELL_VERSION
    build_node
}

install_files() {
    cd $SRC_DIR
    scl enable git19 -- git clone https://github.com/OSC/ood-fileexplorer.git files
    cd files
    scl enable git19 -- git checkout tags/$FILES_VERSION
    build_node
}

install_editor() {
    cd $SRC_DIR
    scl enable git19 -- git clone https://github.com/OSC/ood-fileeditor.git file-editor
    cd file-editor
    scl enable git19 -- git checkout tags/$EDITOR_VERSION
    build_rails
}

install_activejobs() {
    cd $SRC_DIR
    scl enable git19 -- git clone https://github.com/OSC/ood-activejobs.git activejobs
    cd activejobs
    scl enable git19 -- git checkout tags/$ACTIVEJOBS_VERSION
    build_rails
}

install_myjobs() {
    cd $SRC_DIR
    scl enable git19 -- git clone https://github.com/OSC/ood-myjobs.git myjobs
    cd myjobs
    scl enable git19 -- git checkout tags/$MYJOBS_VERSION
    build_rails
}

install_dashboard &
install_shell &
install_editor &
install_activejobs &
install_myjobs &
install_files
wait

copy_app
