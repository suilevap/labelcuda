#include <cuda_runtime_api.h>
//#include "CudaUtil.h"

#include <iostream>
//#include <FileLoader.h>
#include "FileStruct.h"
#include "Word.h"

#include "..\WordFinder\WordFinderLib.h"
#include "..\cudpp\include\cudpp.h"

#include "Buffer.h"
#include "deviceWordsFinder.h"


__global__ void
device_MarkAllWords(char* text, int len, int* terminatedSymbols)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	extern __shared__ int sData[];
	
	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	int r;
	char c = 0; 
	
	if (idx < len-1)
	{
		c = text[idx];
	}
	r = ((
		(c == ' ')||
		(c == '.')||
		(c == ',')||
		(c == '!')||
		(c == '?')) 
		|| (idx==0));	
	sData[tx] = r;
	

	__syncthreads();

	if (idx < len-1)
	{
		if (tx!=0)
		{
			int r0 = sData[tx-1];
			r = (r0) && (!r);
		}
		else
			if (idx!=0)
			{
				c = text[idx-1];
				int rprev = (
					(c == ' ')||
					(c == '.')||
					(c == ',')||
					(c == '!')||
					(c == '?'));	
				r = (rprev) && (!r);
			}
		terminatedSymbols[idx] = r;
	}	

}

__device__ Transition* table;

__global__ void
device_FindAllWords( Transition* table, char* text, int len, int* position, size_t* count, int* words)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < *count)
	{
		int state = 0;
		int pos = position[idx];
		int output;
		//pos++;
		Transition trans;
		do
		{
			trans = GetTransaction(table, state, text[pos]);
			pos++;
			state = trans.NextState;
		}
		while((state != 0) && (pos < len));
		words[idx]	= trans.Output;			
	}
}

__global__ void
device_NormalizeAllWords( unsigned int* words, size_t count)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < count)
	{
		unsigned int r = (words[idx])?1:0;
		words[idx] = r;
	}
}

CUDPPHandle scanplan1 = 0;
CUDPPHandle scanplan2 = 0;
int mem_size2 = sizeof( int) * 10240 * 1024;
Buffer terminatedSymbolsBuf(mem_size2);
Buffer d_odataBuf(mem_size2);
Buffer pwordsCountBuf(sizeof(size_t)*2);

Buffer wordsId(mem_size2);
Buffer valid(mem_size2);
Buffer keyWordsId(mem_size2);

void deviceFindAllWordsPrepare(TransitionsTable * transTable, size_t len)
{
	cudaMalloc((void**)&table, transTable->FullSize);
	
	cudaMemcpy(table, transTable->Table, transTable->FullSize, cudaMemcpyHostToDevice);

	CUDPPConfiguration config;	
	config.datatype = CUDPP_INT;
	config.algorithm = CUDPP_COMPACT;
	config.options = CUDPP_OPTION_FORWARD | CUDPP_OPTION_INCLUSIVE |CUDPP_OPTION_INDEX;
    
    CUDPPResult result = cudppPlan(&scanplan1, config, len, 1, 0); 

	CUDPPConfiguration config2;	

	config2.datatype = CUDPP_INT;
	config2.algorithm = CUDPP_COMPACT;
	config2.options = CUDPP_OPTION_FORWARD | CUDPP_OPTION_INCLUSIVE ;	

	result = cudppPlan(&scanplan2, config2, len, 1, 0); 
	
}

void deviceFindAllWords( char* text, int len, Word* words, int* count, int * allWords, int* allCount)
{
	// setup execution parameters
	int threadsNum = 128;
    dim3 threads(threadsNum, 1);
    dim3 grid((len-1)/threadsNum+1,1);
	int* terminatedSymbols;
	int num_elements = len;
	int mem_size = sizeof( int) * num_elements;
	int sharedMemSize = threadsNum * sizeof(int);
//	Buffer terminatedSymbolsBuf(mem_size);
	terminatedSymbols = (int*)terminatedSymbolsBuf.GetDevice();
	
	device_MarkAllWords<<< grid, threads, sharedMemSize >>>(text, len, terminatedSymbols);
	

	// allocate device memory output arrays
	//Buffer d_odataBuf(mem_size);
	int* d_odata = (int*)d_odataBuf.GetDevice();
	
	//Buffer pwordsCountBuf(sizeof(size_t));
	size_t* pwordsCount = (size_t*)pwordsCountBuf.GetDevice();

	cudppCompact(scanplan1, d_odata, pwordsCount, text,(unsigned int*) terminatedSymbols, len);
	


	//Buffer wordsId(pwordsCount, sizeof(int));
	//Buffer valid(pwordsCount, sizeof(int));
	//Buffer keyWordsId(pwordsCount, sizeof(int));

		
	device_FindAllWords<<< grid, threads, sharedMemSize >>>(table, text, len, d_odata, pwordsCount, (int*) wordsId.GetDevice() );
		
	unsigned int* w = (unsigned int*) wordsId.GetDevice();
	int countWords;
	cudaMemcpy( &countWords, pwordsCount, sizeof(int), cudaMemcpyDeviceToHost);

	cudaMemcpy( valid.GetDevice(), wordsId.GetDevice(), countWords*sizeof(int), cudaMemcpyDeviceToDevice);
	device_NormalizeAllWords<<< grid, threads >>>((unsigned int *)valid.GetDevice(), countWords);
	
	
	cudppCompact(scanplan2,( void*) keyWordsId.GetDevice(), pwordsCount, wordsId.GetDevice(), (unsigned int *)valid.GetDevice(), (size_t)(countWords));	
	
	cudaMemcpy(count, pwordsCount, sizeof(int), cudaMemcpyDeviceToDevice);
	
	//cudaFree(pwordsCount);

}

