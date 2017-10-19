import os
import sys
import psutil
import time
import datetime

#
# CPU rate collector
#
def cpu_rate_collector(p):
    try:
         return p.cpu_percent()
    except Exception as e:
         return 0.00

#
# Memory usage collector
#
def memory_usage_collector(p):
    try:
         return p.memory_percent()
    except Exception as e:
         return 0.00

#
# IO Disk and Network rate collector
#
def io_rate_collector(p):
    '''
     Collect before and after to calculate the io rate of disk and network
    '''
    try:
         collected_disk_before = p.io_counters() if p else psutil.disk_io_counters()
         collected_net_before = psutil.net_io_counters(pernic=True)
         time.sleep(0.2)
         collected_disk_after = p.io_counters() if p else psutil.disk_io_counters()
         collected_net_after = psutil.net_io_counters(pernic=True)

         read_per_sec = collected_disk_after.read_bytes - collected_disk_before.read_bytes
         write_per_sec = collected_disk_after.write_bytes - collected_disk_before.write_bytes

         sent_per_sec = collected_net_after['enp4s0f0'].bytes_sent - collected_net_before['enp4s0f0'].bytes_sent
         recv_per_sec = collected_net_after['enp4s0f0'].bytes_recv - collected_net_before['enp4s0f0'].bytes_recv

         return {'disk': (read_per_sec, write_per_sec, read_per_sec + write_per_sec), 'net': (sent_per_sec, recv_per_sec, sent_per_sec + recv_per_sec)}
    except Exception as e:
         return {'disk': (0, 0, 0), 'net': (0, 0, 0)}

#
# Instantaneous power collector
#
def power_collector():
    os.system("/usr/sbin/ipmi-dcmi --get-system-power-statistics | grep Current | awk '{print $4}' >> power.dat")
    os.system("./temp_sgi.sh")
#
# Writer output file
#
def output(procname, timestamp, pid, cpu, mem, io):
    out_file = open(procname+".dat", 'a')

    line = []
    line.append(str(timestamp) + "\t")
    line.append(str(pid) + "\t")
    line.append(str(cpu) + "\t")
    line.append(str(mem) + "\t")
    line.append(str(io['disk'][0]) + "\t")
    line.append(str(io['disk'][1]) + "\t")
    line.append(str(io['disk'][2]) + "\t")
    line.append(str(io['net'][0]) + "\t")
    line.append(str(io['net'][1]) + "\t")
    line.append(str(io['net'][2]) + "\n")

    out_file.writelines(line)
    out_file.close()

#
#  Main function
#
def main():
    PROCNAME = sys.argv[1]
    LAUNCHER = sys.argv[2]

    for id in psutil.pids():
         pid = psutil.Process(id)
         if ( pid.name() == LAUNCHER ):
             pid_launcher = pid

    print("Launcher is running with: " + str(pid_launcher))
    while pid_launcher.is_running():
        for pid in psutil.pids():
             proc = psutil.Process(pid)
             if ( proc.name() == PROCNAME ):
                  pid_process = proc
        try:
             print("Monitoring application: " + str(pid_process.name()))
             while pid_process.is_running():
                  cpu = '{:.2f}'.format(cpu_rate_collector(pid_process) / psutil.cpu_count())
                  mem = '{:.2f}'.format(memory_usage_collector(pid_process))
                  io = io_rate_collector(pid_process)
                  power_collector()
                  output(PROCNAME, datetime.datetime.now(), pid_process.pid, cpu, mem, io)
        except Exception as e:
             power_collector()
             output(PROCNAME, datetime.datetime.now(), 0,0.00, 0.00, {'disk': (0, 0, 0), 'net': (0, 0, 0)})
             time.sleep(0.2)

if __name__ == "__main__":
    main()

