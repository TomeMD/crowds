#!/bin/bash

m_echo "Running ${WORKLOAD} tests..."

if [ "${WORKLOAD}" == "npb" ]; then
  . "${BIN_DIR}"/npb-tests.sh
else
  if [ "${SOCKETS}" -eq "1" ]; then
    . "${BIN_DIR}"/tests-singlesocket.sh
  elif [ "${SOCKETS}" -eq "2" ]; then
    . "${BIN_DIR}"/tests-multisocket.sh
  else
    m_echo "Number of sockets (${SOCKETS}) not supported"
    m_echo "Aborting tests..."
  fi
fi