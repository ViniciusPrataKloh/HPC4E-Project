# Summary

* [1] Performance and Power Profiling Tool - CPU Module
* [2] Performance and Power Profiling Tool - GPU Module
* [3] Nagios plugin


# [1],[2] Performance and Power Profiling Tool - CPU and GPU Module

## Description
The form to collect the data from the internal sensors and the hardware parameters, for each computational architecture, differ from each other. For this reason, it was developed a performance and power profiling tool based on different modules to collect these parameters, so that the hardware parameters and the internal sensors were collected in a more homogeneous way as possible. The tool was designed to address the need for fine-grained power profiling on parallel and distributed system and the need to correlate with performance profiling. The approach to monitor performance of applications consists of online monitoring and directly method. The tool was developed based on two different modules that enable profile both CPUs and GPUs using the internal sensors. It has very low overhead and high sampling rate.

## Goals

* Collect the hardware parammeters (CPU and Memory usage, I/O disk and network)
* Collect the sensors reading (Power and Temperature)
* Analyze data

## Dependencies:

```shell
sudo apt-get install gcc python3-psutil freeipmi
```

## Usage

The process_monitor.py file has a function that can be selected the auxiliar script to collect the sensors reading. Other scripts can be developed according the sensors available in the system and called in this function.

* To collect the power, use:
	- `os.system("/usr/sbin/ipmi-dcmi --get-system-power-statistics | grep Current | awk '{print $4}' >> power.dat")`
	or
	- `os.system("./power_jetson.sh")`

* To collect the temperature, use:
	- `os.system("./temp_sgi.sh")`
	or
	- `os.system("./temp_jetson.sh")`

The launcher is responsable to run the application.

The output files are:
* [PROCESS_NAME.dat]
* power.dat
* temperature.dat

## Running

```shell
sudo python3 process_monitor.py [PROCESS_NAME] [LAUNCHER_NAME]
```


# [3] Nagios check_proc_performance plugin

## Goals

* Collect the hardware parammeters (CPU and Memory usage)
* Alert the Nagios server with four states:
	* 0 - "OK"
	* 1 - "WARNING"
	* 2 - "CRITICAL"
	* 3 - "UNKNOWN"
* Analyze data

## Dependencies

* top programm - https://linux.die.net/man/1/top
* iotop programm - https://linux.die.net/man/1/iotop

## Usage

Configure the Nagios server to use this plugin as a service.

Options to be used 
	`-p The process name`
	`-w The warning for CPU percentage`
	`-c The critical for CPU percentage`
	`-x The warning for Memory percentage`
	`-y The critical for Memory percentage`

## Example

Defining the command:
	`define command{
		command_name	check_proc_performance
		command_line	$USER1$/check_proc_performance -p [PROCESS_NAME] -w 80 -c 90 -x 80 -y 90
	}`

Defining the service:
	`define service
		use			local-service
		service_description	Service Info
		host_name		localhost
		check_command		check_proc_performance
	}`
