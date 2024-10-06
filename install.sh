#!/usr/bin/env bash
if [[ $1 == "release" ]]
then
  mkdir -p /opt/invidious_update && \
    curl -sSL https://github.com/tmiland/Invidious-Updater/releases/latest/download/invidious_update.sh > /opt/invidious_update/invidious_update.sh && \
    chmod +x /opt/invidious_update/invidious_update.sh && \
    ln -s /opt/invidious_update/invidious_update.sh /usr/local/bin/invidious_update
else
  mkdir -p /opt/invidious_update && \
    curl -sSL https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh > /opt/invidious_update/invidious_update.sh && \
    chmod +x /opt/invidious_update/invidious_update.sh && \
    ln -s /opt/invidious_update/invidious_update.sh /usr/local/bin/invidious_update
fi

invidious_update "$@"
