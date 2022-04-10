#!/usr/bin/env bash
#set -x
if [ ! -z "${DDEV_PROJECT+x}" ]; then
  echo "This script needs to be executed on the HOST. Aborting"
  exit
fi

VALID_ARGS=$(getopt -o fsd --long force,skip-snapshot,debug -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -f | --force)
        echo "Recreating database"
        shift
        RECREATE_DB=1;
        ;;
    -s | --skip-test)
        SKIP_TEST=1
        shift
        ;;
    -d | --debug)
        echo "Running with debug output"
        DEBUG=1
        shift
        ;;
    --) shift;
        break
        ;;
  esac
done

SQL_PATH=tests/_data/dump.sql
DDEV_STATUS=$(ddev describe -j | jq -r '.raw.status')
[[ -z "${DEBUG+x}" ]] && OUTPUT=/dev/null || OUTPUT=/dev/tty

if [[ "${DDEV_STATUS}" == "stopped" ]]; then
  echo "Starting DDEV using the test database..."
  DB_NAME=db_test ddev start &>"${OUTPUT}"
else
  DDEV_CURRENT_DB=$(ddev exec printenv | grep DB_NAME | awk -F= '{print $2}')
  if [[ "${DDEV_CURRENT_DB}" != "db_test" ]]; then
      echo "Restarting DDEV using the test database..."
      DB_NAME=db_test ddev restart &>"${OUTPUT}"
  fi
fi

if [ ! -f "${SQL_PATH}" ] || [ ! -z "${RECREATE_DB+x}"  ]; then
  echo 'Preparing test environment database...'
  ddev orchestrate 1>"${OUTPUT}"
  echo 'Dumping database...'
  ddev export-db -f "${SQL_PATH}"
fi


if [ -z "${SKIP_TEST+x}" ]; then
  ddev composer test:acceptance
  TEST_RESULT=$?
fi

# CLEANUP

if [[ "${DDEV_STATUS}" == "stopped" ]]; then
  echo 'Stopping DDEV again...'
  ddev stop &>"${OUTPUT}"
else
  if [[ "${DDEV_CURRENT_DB}" != "db_test" ]]; then
      echo "Restarting DDEV using the ${DDEV_CURRENT_DB} database..."
      DB_NAME="${DDEV_CURRENT_DB}" ddev restart &>"${OUTPUT}"
  fi
fi

exit "${TEST_RESULT}"


