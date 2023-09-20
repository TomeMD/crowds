#!/bin/bash

export OS_VIRT="docker"
export WORKLOAD="stress-system"
export STRESSORS="cpu"
export LOAD_TYPES="all"
export GEEKBENCH_VERSION="5.4.1"

export GLOBAL_HOME=$(pwd)
export LOG_DIR="${GLOBAL_HOME}"/log/
export GLANCES_HOME="${GLOBAL_HOME}"/cpu_power_monitor/glances
export CPUFREQ_HOME="${GLOBAL_HOME}"/cpu_power_monitor/cpufreq
export CPUFREQ_PID=0
export RAPL_HOME="${GLOBAL_HOME}"/cpu_power_monitor/rapl
export STRESS_HOME="${GLOBAL_HOME}"/stress-system
export BIN_DIR="${GLOBAL_HOME}"/bin

export STRESS_CONTAINER_DIR="${STRESS_HOME}"/container
export NPB_HOME="${BIN_DIR}"/NPB3.4.2/NPB3.4-OMP
export GEEKBENCH_HOME="${BIN_DIR}"/Geekbench-"${GEEKBENCH_VERSION}"-Linux
export PHY_CORES_PER_CPU=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
export SOCKETS=$(lscpu | grep "Socket(s):" | awk '{print $2}')

. ./bin/parse-arguments.sh

# Build environment
echo "Building and initializing environment"
. ./bin/build.sh
. ./bin/init.sh
echo "Environment is ready"

# Run workload
if [ "${WORKLOAD}" == "npb" ]; then
  echo "Running NPB tests..."
  . ./bin/npb-tests.sh
else
  echo "Running ${WORKLOAD} tests..."
  if [ "${SOCKETS}" -eq "1" ]; then
    . ./bin/tests-singlesocket.sh
  elif [ "${SOCKETS}" -eq "2" ]; then
    . ./bin/tests-multisocket.sh
  else
    echo "Number of sockets (${SOCKETS}) not supported"
    echo "Aborting tests..."
  fi
fi

# Close environment
echo "Closing environment"
. ./bin/finish.sh
echo "Environment closed"
