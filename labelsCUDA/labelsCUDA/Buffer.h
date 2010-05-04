#pragma once


class Buffer
{
	void* _hostMemory;
	void* _deviceMemory;
	size_t _size;

public:

	Buffer(size_t size);
	~Buffer(void);

	size_t GetSize();
	void* GetHost();
	void* GetDevice();
};
