#!/bin/bash
# Loosely based on:
# https://github.com/sclorg/s2i-python-container/blob/master/3.6/s2i/bin/run

source /opt/app-root/etc/generate_container_user

set -e

# Guess the number of workers according to the number of cores
function get_default_web_concurrency() {
  limit_vars=$(cgroup-limits)
  local $limit_vars
  if [ -z "${NUMBER_OF_CORES:-}" ]; then
    echo 1
    return
  fi

  local max=$((NUMBER_OF_CORES*2))
  # Require at least 43 MiB and additional 40 MiB for every worker
  local default=$(((${MEMORY_LIMIT_IN_BYTES:-MAX_MEMORY_LIMIT_IN_BYTES}/1024/1024 - 43) / 40))
  default=$((default > max ? max : default))
  default=$((default < 1 ? 1 : default))
  # According to http://docs.gunicorn.org/en/stable/design.html#how-many-workers,
  # 12 workers should be enough to handle hundreds or thousands requests per second
  default=$((default > 12 ? 12 : default))
  echo $default
}

APP_HOME=$(readlink -f "${APP_HOME:-.}")
# Change the working directory to APP_HOME
PYTHONPATH="$(pwd)${PYTHONPATH:+:$PYTHONPATH}"
cd "$APP_HOME"

# Look for 'manage.py' in the current directory
manage_file=./manage.py

if [[ -f "$manage_file" ]]; then
  echo "---> Migrating database ..."
  python "$manage_file" migrate --noinput
else
  echo "WARNING: seems that you're using Django, but we could not find a 'manage.py' file."
  echo "Skipped 'python manage.py migrate'."
fi

# settings.py needs to be importable for collectstatic to work, so we either need to
# import the netbox-config ConfigMap during build or run collectstatic at runtime.
echo "---> Collecting Django static files ..."
python3 ${manage_file} collectstatic --noinput

export WEB_CONCURRENCY=${WEB_CONCURRENCY:-$(get_default_web_concurrency)}

echo "---> Serving application with gunicorn ($APP_MODULE) ..."
exec gunicorn "$APP_MODULE" --bind=0.0.0.0:8080 --access-logfile=- --config "$APP_CONFIG"
