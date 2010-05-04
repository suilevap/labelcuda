#include "Buffer.h"
#include "stdio.h"
#include <cuda_runtime_api.h>

Buffer::Buffer(size_t size)
{
	_hostMemory = NULL;
	_deviceMemory = NULL;
	_size = size;
}

Buffer::~Buffer(void)
{
	if (_hostMemory != NULL)
	{
		free(_hostMemory);
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
		_hostMemory = malloc(_size);
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
