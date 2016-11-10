#!/bin/bash
#
# Installation script for docker container
# Copyright (C) 2016-2017 Cypriot Free Software Community Ellak
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#

#Path where all the files will be executed

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"/..
DOCKER_COMPOSE_YML_PATH="${SCRIPT_PATH}/docker-compose.yml"

# Printing functions
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'


cecho ()                     # Color-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
local default_msg="No message passed."
                             # Doesn't really need to be a local variable.

message=${1:-$default_msg}   # Defaults to default message.
color=${2:-$black}           # Defaults to black, if not specified.

  echo -e "$color"
  echo "$message"
  tput sgr0                      # Reset to normal.

  return
}

cecho "Setting Up" $magenta

cecho "Configuring mysql database settings" $cyan

read -p "Database user: " MYSQL_USER
read -p "Database password: " MYSQL_PASSWORD
read -p "Database name: " MYSQL_DATABASE

cecho "Configuring moodle's admin user settings" $cyan

read -p "Admin username: " MOODLE_ADMIN
read -p "Admin password: " MOODLE_ADMIN_PASSWORD
read -p "Admin Email: " MOODLE_ADMIN_EMAIL

cecho "Moodle's admin user settings" $cyan
cecho "Note:If running on localhost set the asked value as http://0.0.0.0:8082 otherwise
if running behind an http reverse proxy set the asked value with the PUBLIC FACING URL" $yellow

read -p "Moodle's Public Url: " MOODLE_URL

cecho "Generate deployment Directory: " $magenta

PATH_URL=$(echo "${MOODLE_URL}" |  sed -r -e 's/^https?\:\/\/([a-zA-Z0-9.:-]*)\/*/\1/')

echo ${PATH_URL}

SCRIPT_PATH="${SCRIPT_PATH}/${PATH_URL}"

echo ${SCRIPT_PATH}
if [ ! -f ${SCRIPT_PATH} ]; then
  mkdir -p ${SCRIPT_PATH}
fi

cecho "Generate startup and stop scripts" $magenta

DOCKER_COMPOSE=$(whereis docker-compose | awk '{print $2}')
COMMAND="env
            MOODLE_MYSQL_DATABASE=\"${MYSQL_DATABASE}\"
            MOODLE_MYSQL_USER=\"${MYSQL_USER}\"
            MOODLE_MYSQL_PASSWORD=\"${MYSQL_PASSWORD}\"
            MOODLE_ADMIN=\"${MOODLE_ADMIN}\"
            MOODLE_ADMIN_PASSWORD=\"${MOODLE_ADMIN_PASSWORD}\"
            MOODLE_ADMIN_EMAIL=\"${MOODLE_ADMIN_EMAIL}\"
            MOODLE_URL=\"${MOODLE_URL}\"
            ${DOCKER_COMPOSE} -f ${DOCKER_COMPOSE_YML_PATH}"

STARTUP_SCRIPT_PATH="${SCRIPT_PATH}/start.sh"
STOP_SCRIPT_PATH="${SCRIPT_PATH}/stop.sh"

echo $COMMAND" up -d" > ${STARTUP_SCRIPT_PATH}
chmod u+x ${STARTUP_SCRIPT_PATH}

cecho "Startup script generated" $green

echo $COMMAND" stop " > ${STOP_SCRIPT_PATH}
chmod u+x ${STOP_SCRIPT_PATH}

cecho "Stop script generated" $green

echo "In order to start up the service run: "
cecho "${STARTUP_SCRIPT_PATH}" $green

echo "You can stop the services via:"
cecho "${STOP_SCRIPT_PATH}" $green

cecho "" $white
