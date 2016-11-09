#!/bin/bash

#Path where all the files will be executed

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"/..

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
read -p "Moodle's Url: " MOODLE_URL

cecho "Generate deployment Directory: " $magenta

PATH_URL=$(echo "${MOODLE_URL}" |  sed -r -e 's/^https?\:\/\/([a-zA-Z0-9.:-]*)\/*/\1/')

echo ${PATH_URL}

SCRIPT_PATH="${SCRIPT_PATH}/${PATH_URL}"

echo ${SCRIPT_PATH}
if [ ! -f ${SCRIPT_PATH} ]; then
  mkdir -p ${SCRIPT_PATH}
fi

cecho "Generate startup and stop scripts" $magenta

COMMAND="env
            MOODLE_MYSQL_DATABASE=\"${MYSQL_DATABASE}\"
            MOODLE_MYSQL_USER=\"${MYSQL_USER}\"
            MOODLE_MYSQL_PASSWORD=\"${MYSQL_PASSWORD}\"
            MOODLE_ADMIN=\"${MOODLE_ADMIN}\"
            MOODLE_ADMIN_PASSWORD=\"${MOODLE_ADMIN_PASSWORD}\"
            MOODLE_ADMIN_EMAIL=\"${MOODLE_ADMIN_EMAIL}\"
            MOODLE_URL=\"${MOODLE_URL}\"
            docker-compose"

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
