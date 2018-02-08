#!/usr/bin/env bash

chgrp docker /var/run/docker.sock
exec /docker-entrypoint.sh
