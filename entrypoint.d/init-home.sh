#!/bin/bash

HOME=${HOME:-"/home/coder"}
REPLACE_HOME=(
  "./.local"
)
TAR_ADD_ARGS=()

exec 1>"${HOME}"/init-home.sh.log
exec 2>&1
set -x

echo "${0} - $(date) - start"

# init home dir only if it is a mountpoint
if mountpoint "${HOME}"; then
  echo "${HOME} is a mountpoint"

  # replace .local user directory with new one
  for dir in "${REPLACE_HOME[@]}"
  do
    rm -rf "${HOME}"/"${dir}" >/dev/null 2>&1
    tar -I pigz -xvf /home/coder.tar.gz -C "${HOME}" "${dir}"
    TAR_ADD_ARGS+=("--exclude=\"${dir}\"")
  done

  # make code-server machine/user settings.json persistent
  # by moving and symlinking into ~/.config
  mkdir -p "${HOME}"/.config/code-server \
    "${HOME}"/.local/share/code-server/Machine \
    "${HOME}"/.local/share/code-server/User
  touch "${HOME}"/.config/code-server/machine-settings.json
  ln -s "${HOME}"/.config/code-server/machine-settings.json \
    "${HOME}"/.local/share/code-server/Machine/settings.json
  touch "${HOME}"/.config/code-server/user-settings.json
  ln -s "${HOME}"/.config/code-server/user-settings.json \
    "${HOME}"/.local/share/code-server/User/settings.json

  # create non existing user home files/dirs
  # except files/dirs defined in REPLACE_HOME
  tar -I pigz -xvf /home/coder.tar.gz -C "${HOME}" --skip-old-files \
    "${TAR_ADD_ARGS[@]}"
fi

echo "${0} - $(date) - end"
