#include "FileStruct.h"
#include <iostream>
#include <stdio.h>


FileStruct::FileStruct(char* fileName)
{
	_deviceBuffer = NULL;
	_buffer = NULL;
	_size = 0;
	Name = fileName;
}

FileStruct::~FileStruct(void)
{
	if (_buffer != NULL)
	{
		free(_buffer);
	}

	if (_deviceBuffer != NULL)
	{
		cudaFree(_deviceBuffer);
	}
}


size_t FileStruct::LoadFile(char* path, char* &buffer)
{
	FILE *file;
	
	size_t fileLen;
	
	//Open file
	file = fopen(path, "rt");
	if (!file)
	{
		fprintf(stderr, "Unable to open file %s", path);
		return 0;
	}
	
	//Get file length
	fseek(file, 0, SEEK_END);
	fileLen=ftell(file);
	fseek(file, 0, SEEK_SET);

	//Allocate memory
	buffer=(char *)malloc(fileLen+1);
	if (!buffer)
	{
		fprintf(stderr, "Memory error!");
                                fclose(file);
		return 0;
	}

	//Read file contents into buffer
	fread(buffer, fileLen, 1, file);
	fclose(file);

	return fileLen;
}

char * FileStruct::GetHostBuffer()
{
	if (_buffer == NULL)
	{
		_size = this->LoadFile(Name, _buffer);
	}
	return _buffer;
}

size_t FileStruct::GetSize()
{
	if (_buffer == NULL)
	{
		_size = this->LoadFile(Name, _buffer);
	}
	return _size;
}

char * FileStruct::GetDeviceBuffer()
{
	if (_deviceBuffer == NULL)
	{
		char* buf = this->GetHostBuffer();
		size_t size = this->GetSize();
		cudaMalloc((void**) &_deviceBuffer, size);
		cudaMemcpy(_deviceBuffer, buf, size, cudaMemcpyHostToDevice);
	}
	return _deviceBuffer;
}