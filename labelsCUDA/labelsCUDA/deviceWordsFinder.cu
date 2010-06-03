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

void deviceFindAllWordsPrepare(TransitionsTable * transTable)
{
	cudaMalloc((void**)&table, transTable->FullSize);
	
	cudaMemcpy(table, transTable->Table, transTable->FullSize, cudaMemcpyHostToDevice);
	
}

void deviceFindAllWords( char* text, int len, Word* words, int* count, int * allWords, int* allCount)
{
	// setup execution parameters
	int threadsNum = 512;
    dim3 threads(threadsNum, 1);
    dim3 grid((len-1)/threadsNum+1,1);
	int* terminatedSymbols;
	int num_elements = len;
	int mem_size = sizeof( int) * num_elements;
	int sharedMemSize = threadsNum * sizeof(int);

	cudaMalloc(&terminatedSymbols, mem_size);
	device_MarkAllWords<<< grid, threads, sharedMemSize >>>(text, len, terminatedSymbols);
	

	// allocate device memory output arrays
    int* d_odata = NULL;

    cudaMalloc( (void**) &d_odata, mem_size);

	CUDPPConfiguration config;	
	config.datatype = CUDPP_INT;
	config.algorithm = CUDPP_COMPACT;
	config.options = CUDPP_OPTION_FORWARD | CUDPP_OPTION_INCLUSIVE |CUDPP_OPTION_INDEX;
    
    CUDPPHandle scanplan = 0;
    CUDPPResult result = cudppPlan(&scanplan, config, len, 1, 0); 
	//Buffer wordsCountBuf(sizeof(size_t));
	size_t* pwordsCount;
    cudaMalloc( (void**) &pwordsCount, sizeof(size_t));

	cudppCompact(scanplan, d_odata, pwordsCount, text,(unsigned int*) terminatedSymbols, len);
	
	//printf("Words count: %d \n", *(int*)(wordsCountBuf.GetHost()) );
	//device_WatchDebug<<< 1, 1 >>>((char*)wordsCountBuf.GetDevice());

	Buffer wordsId(pwordsCount, sizeof(int));
	Buffer valid(pwordsCount, sizeof(int));
	Buffer keyWordsId(pwordsCount, sizeof(int));
	cudppDestroyPlan(scanplan);
		
	device_FindAllWords<<< grid, threads, sharedMemSize >>>(table, text, len, d_odata, pwordsCount, (int*) wordsId.GetDevice() );
	
	scanplan = 0;
	config.datatype = CUDPP_INT;
	config.algorithm = CUDPP_COMPACT;
	config.options = CUDPP_OPTION_FORWARD | CUDPP_OPTION_INCLUSIVE ;	
	int countWords;
	cudaMemcpy( &countWords, pwordsCount, sizeof(int), cudaMemcpyDeviceToHost);
	result = cudppPlan(&scanplan, config, (size_t)(countWords), 1, 0); 
	unsigned int* w = (unsigned int*) wordsId.GetDevice();
	
	cudaMemcpy( valid.GetDevice(), wordsId.GetDevice(), countWords*sizeof(int), cudaMemcpyDeviceToDevice);
	device_NormalizeAllWords<<< grid, threads >>>((unsigned int *)valid.GetDevice(), countWords);

	cudppCompact(scanplan,( void*) keyWordsId.GetDevice(), pwordsCount, wordsId.GetDevice(), (unsigned int *)valid.GetDevice(), (size_t)(countWords));
	cudppDestroyPlan(scanplan);
	
	cudaFree(d_odata);
	cudaMemcpy(count, pwordsCount, sizeof(int), cudaMemcpyDeviceToDevice);
	
	//cudaFree(pwordsCount);

}

