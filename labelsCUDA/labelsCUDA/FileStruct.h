#pragma once

class FileStruct
{
private:
	char * _buffer;
	char * _deviceBuffer;
	size_t _size;

	size_t LoadFile(char * path, char * & buffer);

public:
	char * Name;

	size_t GetSize();
	char * GetHostBuffer();
	char * GetDeviceBuffer();

	FileStruct(char * fileName);
	~FileStruct(void);
};
