#!/bin/sh

HOME=${HOME:-"/home/coder"}

exec 1>"${HOME}"/init-home.sh.log
exec 2>&1
set -x

echo "$(date) - ${0} - start"

# init home dir only if it is a mountpoint
if mountpoint "${HOME}"; then
  echo "${HOME} is a mountpoint"

  # replace .local user directory with new one
  rm -rf "${HOME}"/.local >/dev/null 2>&1
  tar -xvf /opt/home.local.tar.gz -C "${HOME}"

  # create non existing user home files like .profile, .bashrc, ...
  tar -xvf /opt/home.tar.gz --skip-old-files -C "${HOME}"
fi

echo "$(date) - ${0} - end"
