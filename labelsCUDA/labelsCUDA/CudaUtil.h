#include "stdio.h"
#include <cuda_runtime_api.h>

#include "Buffer.h"

struct event_pair
{
	cudaEvent_t start;
	cudaEvent_t end;
};


inline void check_launch(char * kernel_name)
{
	cudaThreadSynchronize();
	if(cudaGetLastError() == cudaSuccess)
	{
		printf("done with %s kernel\n",kernel_name);
	}
	else
	{
		printf("error on %s kernel\n",kernel_name);
		exit(1);
	}
}
inline void check_cuda_error(char *message)
{
	cudaThreadSynchronize();
	cudaError_t error = cudaGetLastError();
	if(error != cudaSuccess)
	{
		printf("CUDA error after %s: %s\n", message, cudaGetErrorString(error));
	}
}
inline void check_cuda_error(const char *message, const char *filename, const int lineno)
{
	cudaThreadSynchronize();
	cudaError_t error = cudaGetLastError();
	if(error != cudaSuccess)
	{
		printf("CUDA error after %s at %s:%d: %s\n", message, filename, lineno, cudaGetErrorString(error));
		exit(-1);
	}
}

inline void start_timer(event_pair * p)
{
	cudaEventCreate(&p->start);
	cudaEventCreate(&p->end);
	cudaEventRecord(p->start, 0);
}


inline float stop_timer(event_pair * p, char * kernel_name)
{
	cudaEventRecord(p->end, 0);
	cudaEventSynchronize(p->end);

	float elapsed_time;
	cudaEventElapsedTime(&elapsed_time, p->start, p->end);
	printf("%s took %.1f ms\n",kernel_name, elapsed_time);
	cudaEventDestroy(p->start);
	cudaEventDestroy(p->end);
	return elapsed_time;
}

bool AlmostEqual2sComplement(float A, float B, int maxUlps)
{
	// Make sure maxUlps is non-negative and small enough that the
	// default NAN won't compare as equal to anything.
	// assert(maxUlps > 0 && maxUlps < 4 * 1024 * 1024);
	int aInt = *(int*)&A;
	// Make aInt lexicographically ordered as a twos-complement int
	if (aInt < 0)
		aInt = 0x80000000 - aInt;
	// Make bInt lexicographically ordered as a twos-complement int
	int bInt = *(int*)&B;
	if (bInt < 0)
		bInt = 0x80000000 - bInt;
	int intDiff = abs(aInt - bInt);
	if (intDiff <= maxUlps)
		return true;
	return false;
}

inline void * GetDeviceMemory(void* buf, size_t  size)
{
	void* deviceBuffer;
	cudaMalloc((void**) &deviceBuffer, size);
	cudaMemcpy(deviceBuffer, buf, size, cudaMemcpyHostToDevice);
	return deviceBuffer;
}
inline void * GetHostMemory(void* buf, size_t  size)
{
	void* hostBuffer;
	hostBuffer = new char[size];
	cudaMemcpy(hostBuffer, buf, size, cudaMemcpyDeviceToHost);
	return hostBuffer;
}