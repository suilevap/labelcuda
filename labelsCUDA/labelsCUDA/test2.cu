// test2.cpp : Defines the entry point for the console application.
//

//#include "stdafx.h"
//
//
//int _tmain(int argc, _TCHAR* argv[])
//{
//	return 0;
//}

//#include <C:\Program Files\NVIDIA Nexus 1.0\CUDA Toolkit\v3.0\Win32\CUDA\include\thrust/version.h>
//#include <C:\Program Files\NVIDIA Nexus 1.0\CUDA Toolkit\v3.0\Win32\CUDA\include\thrust/device_vector.h>

#include <cuda_runtime_api.h>

//#include <thrust/host_vector.h>
//#include <thrust/device_vector.h>
//
//#include <thrust/copy.h>
//#include <thrust/fill.h>
//#include <thrust/sequence.h>

#include <iostream>
//#include <FileLoader.h>
#include "FileStruct.h"

__global__ void
test(char *a, int len)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < len)
	{
		a[idx] = a[idx]+1;
	}
}

int PrintDevices(int deviceCount, int deviceSelected)
{
    cudaError_t err = cudaSuccess;

    cudaDeviceProp deviceProperty;
    for (int currentDeviceId = 0; currentDeviceId < deviceCount; ++currentDeviceId)
    {
        memset(&deviceProperty, 0, sizeof(cudaDeviceProp));
        err = cudaGetDeviceProperties(&deviceProperty, currentDeviceId);
        //CheckConditionXR_(err == cudaSuccess, err);

        printf("\ndevice name: %s", deviceProperty.name);
        if (currentDeviceId == deviceSelected)
        {
            printf("    <----- creating CUcontext on this");    
        }
        printf("\n");

        printf("device sharedMemPerBlock: %d \n", deviceProperty.sharedMemPerBlock);
        printf("device totalGlobalMem: %d \n", deviceProperty.totalGlobalMem);
        printf("device regsPerBlock: %d \n", deviceProperty.regsPerBlock);
        printf("device warpSize: %d \n", deviceProperty.warpSize);
        printf("device memPitch: %d \n", deviceProperty.memPitch);
        printf("device maxThreadsPerBlock: %d \n", deviceProperty.maxThreadsPerBlock);
        printf("device maxThreadsDim[0]: %d \n", deviceProperty.maxThreadsDim[0]);
        printf("device maxThreadsDim[1]: %d \n", deviceProperty.maxThreadsDim[1]);
        printf("device maxThreadsDim[2]: %d \n", deviceProperty.maxThreadsDim[2]);
        printf("device maxGridSize[0]: %d \n", deviceProperty.maxGridSize[0]);
        printf("device maxGridSize[1]: %d \n", deviceProperty.maxGridSize[1]);
        printf("device maxGridSize[2]: %d \n", deviceProperty.maxGridSize[2]);
        printf("device totalConstMem: %d \n", deviceProperty.totalConstMem);
        printf("device major: %d \n", deviceProperty.major);
        printf("device minor: %d \n", deviceProperty.minor);
        printf("device clockRate: %d \n", deviceProperty.clockRate);
        printf("device textureAlignment: %d \n", deviceProperty.textureAlignment);
        printf("device deviceOverlap: %d \n", deviceProperty.deviceOverlap);
        printf("device multiProcessorCount: %d \n", deviceProperty.multiProcessorCount);

        printf("\n");
    }

    return cudaSuccess;
}

int main(void)
{
	PrintDevices(1,0);



	//char * buf;
	//int size = LoadFile(".\\goog0.txt", buf);
	//if (size < 10)
	//{
	//	std::cout << "error opening file";
	//	return;
	//}
	//printf("size: %d, text: %s \n", size, buf);

	//int len = 320;
	////// allocate device memory
 ////   int* a;
 ////   cudaMalloc((void**) &a, len * sizeof (int));
 ////   int* b;
 ////   cudaMalloc((void**) &b, len * sizeof (int));

	//char* deviceBuf;
 //   cudaMalloc((void**) &deviceBuf, size);
	//cudaMemcpy(deviceBuf, buf, size, cudaMemcpyHostToDevice);
	FileStruct* file = new FileStruct(".\\goog0.txt");
	size_t size = file->GetSize();
	
	char * deviceBuffer = file->GetDeviceBuffer();
	// setup execution parameters
    dim3 threads(512, 1);
    dim3 grid(size/512,1);

    // execute the kernel
    test<<< grid, threads >>>(deviceBuffer, size);
	
	char* buf =(char*) malloc(size + 1);
	cudaMemcpy(buf, deviceBuffer, size, cudaMemcpyDeviceToHost);

	//cudaFree(deviceBuf);
    // print a
	printf("text2: %s", buf);
    //for(int i = 0; i < size; i++)
    //    std::cout << "A[" << i << "] = " << buf[i] << std::endl;
	free(buf);
	getchar();
	delete file;
    return 0;
}

char* Test2(char* text, size_t size)
{
	char * a;
    cudaMalloc((void**) &a, size);

	cudaMemcpy(a, text, size, cudaMemcpyHostToDevice);
	
	return a;
}