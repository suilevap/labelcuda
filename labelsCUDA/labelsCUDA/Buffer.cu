#include "Buffer.h"
#include "stdio.h"
#include <cuda_runtime_api.h>

Buffer::Buffer(size_t size)
{
	_hostMemory = NULL;
	_deviceMemory = NULL;
	_size = size;
}
Buffer::Buffer(size_t* psize)
{
	_hostMemory = NULL;
	_deviceMemory = NULL;
	cudaMemcpy(&_size, psize, sizeof(size_t), cudaMemcpyDeviceToHost);
}

Buffer::Buffer(size_t* pcount, size_t elemSize)
{
	_hostMemory = NULL;
	_deviceMemory = NULL;
	cudaMemcpy(&_size, pcount, sizeof(size_t), cudaMemcpyDeviceToHost);
	_size *= elemSize;
}

Buffer::~Buffer(void)
{
	if (_hostMemory != NULL)
	{
		delete[](_hostMemory);
	}
	if (_deviceMemory != NULL)
	{
		cudaFree(_deviceMemory);
	}
}

void* Buffer::GetHost()
{
	if (_hostMemory == NULL)
	{
		_hostMemory = new char[_size];
	}
	if (_deviceMemory != NULL)
	{
		cudaMemcpy(_hostMemory, _deviceMemory, _size, cudaMemcpyDeviceToHost);
	}
	return _hostMemory;
}

void* Buffer::GetDevice()
{
	if (_deviceMemory == NULL)
	{
		cudaMalloc(&_deviceMemory, _size);
	}
	if (_hostMemory != NULL)
	{
		cudaMemcpy(_deviceMemory,_hostMemory, _size, cudaMemcpyHostToDevice);
	}
	return _deviceMemory;
}

inline size_t Buffer::GetSize()
{
	return _size;
}
