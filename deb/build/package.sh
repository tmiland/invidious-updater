#!/bin/bash
# Builds the amd64 .deb from deb/build/ and optionally copies it into a
# local APT repo checkout. Override the target with DEB_REPO_DIR.
# Example: DEB_REPO_DIR=/path/to/deb.tmiland.com/debian ./package.sh
version=$(echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "../../invidious_update.sh"))
arch=$(uname -m)
if [ "$arch" == "x86_64" ]; then
    arch="amd64"
else
    echo "Unsupported arch for packaging: $arch (amd64 only)" >&2
    exit 1
fi

dpkg-deb -Zxz --build $arch ./invidious-updater_$arch-$version.deb
DEB_REPO_DIR=${DEB_REPO_DIR:-$HOME/.github/deb.tmiland.com/debian}
if [ -d "$DEB_REPO_DIR" ]; then
  cp -rp ./invidious-updater_$arch-$version.deb "$DEB_REPO_DIR/"
else
  echo "Built ./invidious-updater_$arch-$version.deb (repo dir $DEB_REPO_DIR not found, skipping copy)"
fi
