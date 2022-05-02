#!/bin/sh

if [ ! -e /home/coder/.initialized_home ]; then
  tar xf /opt/home.tar.gz -C /home/coder
fi

. /usr/bin/entrypoint.sh "$@"
