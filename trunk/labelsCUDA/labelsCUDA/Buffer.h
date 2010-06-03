#pragma once

class Buffer
{
	void* _hostMemory;
	void* _deviceMemory;
	size_t _size;

public:

	Buffer(size_t size);
	Buffer(size_t* size);

	Buffer(size_t* pcount, size_t elemSize);

	~Buffer(void);

	size_t GetSize();
	void* GetHost();
	void* GetDevice();
};
