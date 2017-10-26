#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "includes/nvml.h"
#include <iostream>
#include <sys/time.h>
#include <unistd.h>

using namespace std;

int stop = 0;
nvmlReturn_t mlResult;
nvmlDevice_t *device;
nvmlMemory_t *memory;
nvmlUtilization_t *utilization;
nvmlTemperatureSensors_t sensorType;
char **name, path[256], save_part[128], saveFile[256];
unsigned int *power, *temperature;
int devs, N_run = 1, r_count = 1;
unsigned int nvmlDevs;


void getDate();
void getTime();
void startup(int argc, char **argv);

void monitora()
{
   struct timeval *tvnow;
   tvnow = (struct timeval*)malloc(sizeof(struct timeval)*nvmlDevs);

//   printf("|      Time       | Device name | Device # | Memory unit |   Free   |   Used   |   Total   | Util. Rate Memory/GPU | Power (W) | Temperature (C) |\n" );
    
   for(int i = 0; i < nvmlDevs; i++)
   {
      gettimeofday(&tvnow[i], NULL);
      mlResult = nvmlDeviceGetName(device[i], name[i], 50);
      mlResult = nvmlDeviceGetMemoryInfo(device[i], &memory[i]);

      mlResult =  nvmlDeviceGetUtilizationRates(device[i], &utilization[i]);
      if(NVML_SUCCESS != mlResult)
      {
         printf("Failed to get utilization rates: %s\n", nvmlErrorString(mlResult));
      }
   }
   for(int i = 0; i < nvmlDevs; i++)
   {
      struct tm* tm = localtime(&tvnow[i].tv_sec);
      printf("%3d:%02d:%02d.%06ld  %s  %5d %9.2Lf %9.2Lf %10.2Lf %9i %9i \n", tm->tm_hour, tm->tm_min, tm->tm_sec, tvnow[i].tv_usec, name[i], i,(long double)memory[i].free/1048576.0,(long double)memory[i].used/1048576.0, (long double)memory[i].total/1048576.0, utilization[i].memory, utilization[i].gpu);

   }
}


void getTime()
{
   struct timeval tvnow;
   gettimeofday(&tvnow, NULL);
   struct tm* tm = localtime(&tvnow.tv_sec);

   printf("%d:%02d:%02d.%06ld\n", tm->tm_hour, tm->tm_min, tm->tm_sec, tvnow.tv_usec);

}

int main(int argc, char **argv)
{
   mlResult = nvmlInit();
   if(NVML_SUCCESS != mlResult)
      printf("Failed to Initialize NVML: %s\n", nvmlErrorString(mlResult));

   nvmlDeviceGetCount(&nvmlDevs);
   device = (nvmlDevice_t *)malloc(sizeof(nvmlDevice_t)*nvmlDevs);
   memory = (nvmlMemory_t*)malloc(sizeof(nvmlMemory_t)*nvmlDevs);
   name = (char**)malloc(sizeof(char*)*nvmlDevs);
   utilization = (nvmlUtilization_t*)malloc(sizeof(nvmlUtilization_t)*nvmlDevs);

   for(int i = 0; i < nvmlDevs; i++)
   {
      mlResult = nvmlDeviceGetHandleByIndex(i, &device[i]);
      name[i] = (char*)malloc(sizeof(char)*50);
   }
   monitora(); 

   mlResult = nvmlShutdown();
   if(NVML_SUCCESS != mlResult)
   {
      printf("Failed to shutdown NVML: %s\n", nvmlErrorString(mlResult));

      printf("Press ENTER to continue...\n");
      getchar();
   }


   return 0;
}
