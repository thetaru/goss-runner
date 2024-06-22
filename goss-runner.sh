#!/bin/bash
set -u

# Goss execution hostname
GOSS_HOSTNAME="$(hostname -s)"

# Goss binary path
GOSS_PATH="./bin"

# Variables for test scenario cases
GOSS_SCENARIO_DIR="./scenarios"
GOSS_SCENARIO_HOST_DIR="${GOSS_SCENARIO_DIR}/${GOSS_HOSTNAME}"
GOSS_SCENARIO_COMMON_DIR="${GOSS_SCENARIO_DIR}/common"

# Variables referenced by the test scenario
GOSS_VAR_DIR="./vars"
GOSS_VAR_HOST_DIR="${GOSS_VAR_DIR}/${GOSS_HOSTNAME}"
GOSS_VAR_COMMON_DIR="${GOSS_VAR_DIR}/common"
GOSS_VAR_MERGE_FILE="$(mktemp --suffix=.yaml)"

# Command Line Arguments
GOSS_CMDLINE_ARG_SCENARIO=""

# Output format
GOSS_OUTPUT_FORMAT="tap"

# Depend on following commands
GOSS_DEPENDENCIES=(
  "echo"
  "egrep"
  "find"
  "grep"
  "hostname"
  "ls"
  "mktemp"
  "which"
)

# Regexp patterns
REGEXP_YAML_EXTENTION="\.(yml|yaml)$"

function usage() {
    cat 1>&2 <<EOF
Usage:
    $(basename $0) -s "scenario_name"

Options:
    -f              Specify the name of the output format(rspecish, documentation, json, tap, junit, nagios, prometheus, silent).
    -s              Specify the name of the scenario file you want to run.
EOF
    exit 1
}

function gossCheckDependency() {
  COMMAND_NAME_ARG="$1"

  if ! which "${COMMAND_NAME_ARG}" > /dev/null 2>&1; then
    echo "command not found: ${COMMAND_NAME_ARG}"
    exit 1
  fi
}

function gossMergeVarFiles() {
  if [ -d "${GOSS_VAR_COMMON_DIR}" ]; then
    for i in $(find "${GOSS_VAR_COMMON_DIR}" -type f | egrep "${REGEXP_YAML_EXTENTION}"); do
      echo "$(cat $i)" >> ${GOSS_VAR_MERGE_FILE}
    done
  fi

  if [ -d "${GOSS_VAR_HOST_DIR}" ]; then
    for i in $(find "${GOSS_VAR_HOST_DIR}"   -type f | egrep "${REGEXP_YAML_EXTENTION}"); do
      echo "$(cat $i)" >> ${GOSS_VAR_MERGE_FILE}
    done
  fi
}

function gossRemoveMergedVarFile() {
  if [ -f "${GOSS_VAR_MERGE_FILE}" ]; then
    rm -f "${GOSS_VAR_MERGE_FILE}"
  fi
}
trap gossRemoveMergedVarFile EXIT
trap 'trap - EXIT; gossRemoveMergedVarFile; exit -1' INT PIPE TERM

function gossRun() {
  SCENARIO_DIR_ARG="$1"

  for GOSS_SCENARIO_FILE in $(ls -pR ${SCENARIO_DIR_ARG} | egrep "${REGEXP_YAML_EXTENTION}" | grep -v /); do
    # If a scenario argument is given, skip all other scenarios
    if [ ! -z "${GOSS_CMDLINE_ARG_SCENARIO}" ] && \
       [ "${GOSS_CMDLINE_ARG_SCENARIO}" != "${GOSS_SCENARIO_FILE}" ]; then
      continue
    fi

    echo "SCENARIO [${GOSS_SCENARIO_FILE}]"
    ./bin/goss \
      --gossfile "${SCENARIO_DIR_ARG}/${GOSS_SCENARIO_FILE}" \
      --vars "${GOSS_VAR_MERGE_FILE}"  \
      validate \
      --format "${GOSS_OUTPUT_FORMAT}"
    echo -e ""
  done
}

# Parse command line options
while getopts "f:s:h" opt; do
    case "${opt}" in
        s) GOSS_CMDLINE_ARG_SCENARIO=${OPTARG};;
        f) GOSS_OUTPUT_FORMAT=${OPTARG};;
        h) usage;;
        ?) usage;;
    esac
done

# Check dependencies
for i in "${GOSS_DEPENDENCIES[@]}"; do
  gossCheckDependency "$i"
done

# goss binary should be exist
if [ ! -f "${GOSS_PATH}/goss" ]; then
  echo "goss binary is not found at ${GOSS_PATH}."
  exit 1
fi

# Merge variable files
gossMergeVarFiles

# Test scenarios
echo "PLAY [${GOSS_HOSTNAME}]"
## common
if [ -d "${GOSS_SCENARIO_COMMON_DIR}" ]; then
  gossRun "${GOSS_SCENARIO_COMMON_DIR}"
fi
## host
if [ -d "${GOSS_SCENARIO_HOST_DIR}" ]; then
  gossRun "${GOSS_SCENARIO_HOST_DIR}"
fi
