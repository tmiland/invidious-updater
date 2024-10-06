#!/usr/bin/env bash
if [[ $1 == "release" ]]
then
  curl -sSL https://github.com/tmiland/Invidious-Updater/releases/latest/download/invidious_update.sh > invidious_update.sh && \
  chmod +x invidious_update.sh && \
  /invidious_update.sh -i
else
  curl -sSL https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh > invidious_update.sh && \
  chmod +x invidious_update.sh && \
  ./invidious_update.sh -i
fi
