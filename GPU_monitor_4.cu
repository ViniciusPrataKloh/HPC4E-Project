#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "nvml.h"
#include <iostream>
#include <sys/time.h>
#include <pthread.h>
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

void *monitora(void *c)
{
   int *tid = (int*)c;


   if(tid[0] == 0)
   {
      sleep(30);
      system(path);
      system("date +%H:%M:%S.%N");
      sleep(30);
      stop = 1;
   }
   else
   {
      FILE *outPtr;
      struct timeval *tvnow;
      tvnow = (struct timeval*)malloc(sizeof(struct timeval)*nvmlDevs);

      sprintf(saveFile, "%s_%04d.dat", save_part, r_count);
      printf("%s\n", saveFile);

      outPtr=fopen(saveFile,"w");
      if(outPtr==NULL)
      {
         printf("Falha na abertura");
         pthread_exit(c);
      }
      fprintf(outPtr, "|      Time       | Device name | Device # | Memory unit |   Free   |   Used   |   Total   | Util. Rate Memory/GPU | Power (W) | Temperature (C) |\n" );
      while(!stop)
      {
         for(int i = 0; i < nvmlDevs; i++)
         {
            gettimeofday(&tvnow[i], NULL);
            mlResult = nvmlDeviceGetName(device[i], name[i], 50);
            mlResult = nvmlDeviceGetMemoryInfo(device[i], &memory[i]);
            mlResult = nvmlDeviceGetPowerUsage(device[i], &power[i]);
/*            if(NVML_SUCCESS != mlResult)
            {
               fprintf(outPtr, "Failed to get Power readings: %s\n", nvmlErrorString(mlResult));
            }
*/
            mlResult = nvmlDeviceGetTemperature(device[i], sensorType, &temperature[i]);
/*            if(NVML_SUCCESS != mlResult)
           {
              fprintf(outPtr, "Failed to get temperture: %s\n", nvmlErrorString(mlResult));
           }
*/
           mlResult =  nvmlDeviceGetUtilizationRates(device[i], &utilization[i]);
           if(NVML_SUCCESS != mlResult)
           {
              fprintf(outPtr, "Failed to get utilization rates: %s\n", nvmlErrorString(mlResult));
           }

        }

//	fprintf(outPtr, "| Time | Device name | Device # | Free memory | Used memory | Total memory | Power (W) | Temperature (C) |\n" );
        for(int i = 0; i < nvmlDevs; i++)
        {
           struct tm* tm = localtime(&tvnow[i].tv_sec);
	   fprintf(outPtr, "|%3d:%02d:%02d.%06ld | %s | %5d    |%8s     |%9.2Lf |%9.2Lf |%10.2Lf |%9i%% |%9i%% |%9.3f  |%10d       |\n", tm->tm_hour, tm->tm_min, tm->tm_sec, tvnow[i].tv_usec, name[i], i, "MB",(long double)memory[i].free/1048576.0,(long double)memory[i].used/1048576.0, (long double)memory[i].total/1048576.0, utilization[i].memory, utilization[i].gpu , (float)power[i]/1000.0f, temperature[i]);


           /*fprintf(outPtr, "%d:%02d:%02d.%06ld\n", tm->tm_hour, tm->tm_min, tm->tm_sec, tvnow[i].tv_usec);
           fprintf(outPtr, "nvml Device Name: %s\n", name[i]);
           fprintf(outPtr, "device %d memory: free %.2LfMB, used %.2LfMB, Total %.2LfMB\n", i, (long double)memory[i].free/1048576.0,(long double)memory[i].used/1048576.0, (long double)memory[i].total/1048576.0);
           fprintf(outPtr, "Power usage: %d watts. Tempereture: %d C\n", power[i], temperature[i]);
           */
        }

     }

     fclose(outPtr);

   }

   pthread_exit(c);
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

   startup(argc, argv);

   nvmlDeviceGetCount(&nvmlDevs);

   printf("cuda devs = %d, nvml devs = %d\n", devs, nvmlDevs);

//   path = (char*)malloc(sizeof(char)*256);
   device = (nvmlDevice_t *)malloc(sizeof(nvmlDevice_t)*nvmlDevs);
   memory = (nvmlMemory_t*)malloc(sizeof(nvmlMemory_t)*nvmlDevs);
   name = (char**)malloc(sizeof(char*)*nvmlDevs);
   power = (unsigned int*)malloc(sizeof(unsigned int)*nvmlDevs);
   temperature = (unsigned int*)malloc(sizeof(unsigned int)*nvmlDevs);
   utilization = (nvmlUtilization_t*)malloc(sizeof(nvmlUtilization_t)*nvmlDevs);

/*   path[0] = '\0';
   strcat(path, "date +%H:%M:%S.%N && ./");
   strcat(path, argv[1]);
   printf("path = %s\n", path);
*/

   for(int i = 0; i < nvmlDevs; i++)
   {
      mlResult = nvmlDeviceGetHandleByIndex(i, &device[i]);
      name[i] = (char*)malloc(sizeof(char)*50);
   } 

   for(int i = 0; i < N_run; i++)
   {
      stop = 0;
      r_count = i+1;
      int tidx[2];
      pthread_t tid[2]; 
      printf("run %d\n", i); 

      for(int i = 0; i < 2; i++)
      {
         tidx[i] = i;
         pthread_create(&tid[i], NULL, &monitora, (void*)&tidx[i]);
      }
      for(int k = 0; k < 2; k++)
      {
         pthread_join(tid[k], NULL);
      }
   }   

   mlResult = nvmlShutdown();
   if(NVML_SUCCESS != mlResult)
   {
      printf("Failed to shutdown NVML: %s\n", nvmlErrorString(mlResult));

      printf("Press ENTER to continue...\n");
      getchar();
   }


   return 0;
}

void startup(int argc, char **argv)
{
   int i;

   for(i = 0; i < argc; i++)
   {    
      printf("%s\n", argv[i]);
   } 

   if(argc > 1)
   {
      for(i = 1; i < argc; i++)
      {
         if ((!strcmp(argv[i], "-p")) || (!strcmp(argv[i], "-P")))
         {  
            if(argv[i+1][0] != '-')
            {
               //path[0] = '\0';
               strcpy(path, "date +%H:%M:%S.%N && ./");
               strcat(path, argv[i+1]);
               printf("path = %s\n", path);
               i++;
            }
            else
            {
               printf("Parameter \"-p\"/\"-P\" must be followed by the path of the application to be evaluated\n");
               printf("current line %d, path = %s\n", __LINE__, path);
               exit(0);
            }
         }
         else if((!strcmp(argv[i], "-f")) || (!strcmp(argv[i], "--file")))
         {
            if(argv[i+1][0] != '-')
            {
               strcpy(save_part, argv[i+1]);
               printf("save_part = %s\n", save_part);
               i++;
            }
            else
            {
               printf("Parameter \"--file\"/\"-f\" must be followed by the result output file name!\n");
               printf("current line %d, save_part = %s\n", __LINE__, save_part);
               exit(0);
            }
         }
         else if((!strcmp(argv[i], "--round")) || (!strcmp(argv[i], "-r")) )
         {
            if(atoi(argv[i+1]) >= 1)
            {
               N_run = atoi(argv[i+1]);
               i = i+1;
            }
            else
            {
               printf("Parameter \"--round\"/\"-r\" must be followed by a positive integer !\n");
               exit(0);
            }
         }
         else
         {
            printf("TSPd_GA : Invalid option! \"%s\", try \'TSPd_GA --help\' for more information.\n", argv[i]);
            exit(0);
         }
      }
   }

   for(i = 1; i <= N_run; i++)
   {
      //strcpy(saveFile, save_part);
      sprintf(saveFile, "%s_%04d.dat", save_part, i);
      printf("%s\n", saveFile);
   }

}

