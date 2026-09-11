#!/bin/bash
# Syncs the Version field in amd64/DEBIAN/* from invidious_update.sh.
# Run from deb/build/.

# Returns the version number of invidious_update.sh file on line 14
NEW_VERSION=$(echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "../../invidious_update.sh"))
# Returns the version number in control file
OLD_VERSION=$(echo $(grep -Poh "(?<=Version: )([0-9]|\.)*(?=\s|$)" ./amd64/DEBIAN/*))
# Only update number if version in invidious_update.sh is newer than control file
# (plain string `<` misorders e.g. 2.2.5 vs 2.10.0 — always compare properly)
if dpkg --compare-versions "${OLD_VERSION}" lt "${NEW_VERSION}"; then
  sed -i "s/$OLD_VERSION/$NEW_VERSION/g" ./amd64/DEBIAN/* || { echo -e "Error: Unable to update files."; exit 1; }
  echo -e "Updated control file from $OLD_VERSION > $NEW_VERSION"
else
  echo -e "Versions are matching (or control is newer), nothing to do..."
  exit 0;
fi
