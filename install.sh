#!/bin/bash

SRC_DIR=~/ood/src/test1

 DASHBOARD_VERSION="v1.10.0"
     SHELL_VERSION="v1.1.2"
     FILES_VERSION="v1.3.1"
    EDITOR_VERSION="v1.2.3"
ACTIVEJOBS_VERSION="v1.3.1"
    MYJOBS_VERSION="v2.1.2"

mkdir -p $SRC_DIR
cd $SRC_DIR

build_rails() {
    RAILSOUT="$(scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle | cat)";
    echo "${RAILSOUT}"
    RAILSOUT="$(scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production | cat)";
    echo "${RAILSOUT}"
    RAILSOUT="$(scl enable rh-ruby22 nodejs010 -- bin/rake tmp:clear | cat)";
    echo "${RAILSOUT}"
}

build_node() {
    NODEOUT="$(scl enable git19 nodejs010 -- npm install | cat)";
    echo "${NODEOUT}"
}

git_checkout() {
    if [ "$1" ]
    then
        CHECKOUT="$(scl enable git19 -- git checkout tags/$1 | cat)";
        echo "${CHECKOUT}"
    fi
}

git_clone() {
    cd $SRC_DIR
    if [ "$1" ] && [ "$2" ]
    then
        CLONEOUT="$(scl enable git19 -- git clone $1 $2 | cat)";
        echo "${CLONEOUT}"
    fi
    cd $2
}

copy_app() {
    echo "should we requre sudo to do the copy to deployment?"
}

install_dashboard() {
    git_clone https://github.com/OSC/ood-dashboard.git dashboard;
    git_checkout $DASHBOARD_VERSION;
    build_rails
}

install_shell() {
    git_clone https://github.com/OSC/ood-shell.git shell;
    git_checkout $SHELL_VERSION;
    build_node
}

install_files() {
    git_clone https://github.com/OSC/ood-fileexplorer.git files;
    git_checkout $FILES_VERSION;
    build_node
}

install_editor() {
    git_clone https://github.com/OSC/ood-fileeditor.git file-editor;
    git_checkout $EDITOR_VERSION;
    build_rails
}

install_activejobs() {
    git_clone https://github.com/OSC/ood-activejobs.git activejobs;
    git_checkout $ACTIVEJOBS_VERSION;
    build_rails
}

install_myjobs() {
    git_clone https://github.com/OSC/ood-myjobs.git myjobs;
    git_checkout $MYJOBS_VERSION;
    build_rails
}

show_spinner()
{
  local -r pid="${1}"
  local -r delay='0.75'
  local spinstr='\|/-'
  local temp
  while ps a | awk '{print $1}' | grep -q "${pid}"; do
    temp="${spinstr#?}"
    printf " [%c]  " "${spinstr}"
    spinstr=${temp}${spinstr%"${temp}"}
    sleep "${delay}"
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

(
install_dashboard &
install_shell &
install_editor &
install_activejobs &
install_myjobs &
install_files &
wait
) &
show_spinner "$!"

copy_app
