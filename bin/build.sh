#!/bin/bash

# Set monitoring environment
sed -i '/\[influxdb2\]/,/\[/{s/^host=localhost$/host=montoxo.des.udc.es/}' "${GLANCES_HOME}"/etc/glances.conf
sed -i '/ic_influx_database/s/localhost/montoxo.des.udc.es/' "${RAPL_HOME}"/src/rapl_plot/rapl_plot.c
if [ "${OS_VIRT}" == "docker" ]; then
  echo "Building Glances..."
  docker build -t glances "${GLANCES_HOME}"
  echo "Building RAPL..."
  docker build -t rapl "${RAPL_HOME}"
else
  echo "Building Glances..."
  cd "${GLANCES_HOME}" && apptainer build -F glances.sif glances.def > /dev/null
  echo "Building RAPL..."
  cd "${RAPL_HOME}" && apptainer build -F rapl.sif rapl.def > /dev/null
fi
cd "${GLOBAL_HOME}"
chmod +x "${CPUFREQ_HOME}"/get-freq.sh

# Compile corresponding workload
if [ "${WORKLOAD}" == "stress-system" ]; then
	chmod +x "${STRESS_HOME}"/run.sh
	echo "Building stress-system..."
	if [ "$OS_VIRT" == "docker" ]; then
	  docker build -t stress-system -f "${STRESS_CONTAINER_DIR}"/Dockerfile .
	else
	  cd "${STRESS_CONTAINER_DIR}" && apptainer build -F stress.sif stress.def > /dev/null
	fi

elif [ "${WORKLOAD}" == "npb" ]; then
	if [ ! -d "${NPB_HOME}" ]; then
		echo "Downloading NPB kernels..."
		wget https://www.nas.nasa.gov/assets/npb/NPB3.4.2.tar.gz
		tar -xf NPB3.4.2.tar.gz -C "${BIN_DIR}"
		rm NPB3.4.2.tar.gz
		cd "${NPB_HOME}"
		cp config/make.def.template config/make.def
		make clean
		make is CLASS=C
		make ft CLASS=C
		make mg CLASS=C
		make cg CLASS=C
		make bt CLASS=C
	else
		echo "NPB kernels were already downloaded"
	fi

elif [ "${WORKLOAD}" == "geekbench" ]; then
	if [ ! -d "Geekbench-${GEEKBENCH_VERSION}-Linux" ]; then
		echo "Downloading Geekbench..."
		wget https://cdn.geekbench.com/Geekbench-"${GEEKBENCH_VERSION}"-Linux.tar.gz
		tar -xf Geekbench-"${GEEKBENCH_VERSION}"-Linux.tar.gz -C "${BIN_DIR}"
		rm Geekbench-"${GEEKBENCH_VERSION}"-Linux.tar.gz
	else
		echo "Geekbench was already downloaded"
	fi
fi

cd "${GLOBAL_HOME}"
