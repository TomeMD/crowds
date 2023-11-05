#!/bin/bash

CORES_PER_CPU=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
SOCKETS=$(lscpu | grep "Socket(s):" | awk '{print $2}')
export THREADS=$((CORES_PER_CPU * SOCKETS * 2))

START=$(date +%s%N)

sleep 30 # Initial wait

NAME="IS"
TIMESTAMPS_FILE=${LOG_DIR}/IS.timestamps
run_npb_omp_kernel "bin/is.C.x"

sleep 10

NAME="FT"
TIMESTAMPS_FILE=${LOG_DIR}/FT.timestamps
run_npb_omp_kernel "bin/ft.C.x"

sleep 10

NAME="MG"
TIMESTAMPS_FILE=${LOG_DIR}/MG.timestamps
run_npb_omp_kernel "bin/mg.C.x"

sleep 10

NAME="CG"
TIMESTAMPS_FILE=${LOG_DIR}/CG.timestamps
run_npb_omp_kernel "bin/cg.C.x"

sleep 10

NAME="BT"
TIMESTAMPS_FILE=${LOG_DIR}/BT.timestamps
run_npb_omp_kernel "bin/bt.C.x"

sleep 10

NAME="BT_IO"
TIMESTAMPS_FILE=${LOG_DIR}/BT_IO.timestamps
run_npb_mpi_kernel "bin/bt.C.x.ep_io"

END=$(date +%s%N)
NAME="TOTAL"
print_time START END