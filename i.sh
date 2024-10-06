#!/usr/bin/env bash
# Detect absolute and full path as well as filename of this script
cd "$(dirname "$0")" || exit
CURRDIR=$(pwd)
SCRIPT_FILENAME=$(basename "$0")
cd - > /dev/null || exit
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
SCRIPT_DIR=$(dirname "${sfp}")
if [[ $1 == "release" ]]
then
  curl -sSL https://github.com/tmiland/Invidious-Updater/releases/latest/download/invidious_update.sh > "${SCRIPT_DIR}/${SCRIPT_FILENAME}" && \
  chmod +x "${SCRIPT_DIR}/${SCRIPT_FILENAME}"
  . "${SCRIPT_DIR}/${SCRIPT_FILENAME}" -i
else
  curl -sSL https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh > "${SCRIPT_DIR}/${SCRIPT_FILENAME}" && \
  chmod +x "${SCRIPT_DIR}/${SCRIPT_FILENAME}"
  . "${SCRIPT_DIR}/${SCRIPT_FILENAME}" -i
fi
