#define N 1024*1024*1024 

#include <stdlib.h>
#include <stdio.h>

__global__ void vector_add(float *out, float *a, float *b, long int n) {
    for(long int i = 0; i < n; i++){
        out[i] = a[i] + b[i];
    }
}

int main(){
    float *a, *b, *out; 
	cudaError_t cudaerr;

    printf("%d\n", sizeof(long int));

    // Allocate memory in host memory (CPU)
    a   = (float*)malloc(sizeof(float) * N);
    b   = (float*)malloc(sizeof(float) * N);
    out = (float*)malloc(sizeof(float) * N);

    // Initialize array
    for(long int i = 0; i < N; i++){
        a[i] = 1.0f; b[i] = 2.0f;
    }

	// Allocate memory in device memory (GPU)
	float *d_a, *d_b, *d_out;
    cudaerr = cudaMalloc((void **) &d_a, sizeof(float)*N);
    if (cudaerr != cudaSuccess)
		printf("cudaMalloc failed with error \"%s\".\n", cudaGetErrorString(cudaerr));
	cudaerr = cudaMalloc((void **) &d_b, sizeof(float)*N);
    if (cudaerr != cudaSuccess)
		printf("cudaMalloc failed with error \"%s\".\n", cudaGetErrorString(cudaerr));
	cudaerr = cudaMalloc((void **) &d_out, sizeof(float)*N);
    if (cudaerr != cudaSuccess)
		printf("cudaMalloc failed with error \"%s\".\n", cudaGetErrorString(cudaerr));

	// Copy source data from host to device
	cudaerr = cudaMemcpy (a, d_a, sizeof(float)*N, cudaMemcpyHostToDevice);
    if (cudaerr != cudaSuccess)
		printf("Copying data host to device failed with error \"%s\".\n", cudaGetErrorString(cudaerr));
	
	cudaerr = cudaMemcpy (b, d_b, sizeof(float)*N, cudaMemcpyHostToDevice);
    if (cudaerr != cudaSuccess)
		printf("Copying data host to device failed with error \"%s\".\n", cudaGetErrorString(cudaerr));
    
	// Main function
    vector_add<<<1,1>>>(out, a, b, N);

	// Copy result data from device to host 
	cudaerr = cudaMemcpy (out, d_out, sizeof(float)*N, cudaMemcpyDeviceToHost);
    if (cudaerr != cudaSuccess)
		printf("Copying data Device to host failed with error \"%s\".\n", cudaGetErrorString(cudaerr));

	cudaerr = cudaDeviceSynchronize();
    if (cudaerr != cudaSuccess)
		printf("kernel launch failed with error \"%s\".\n", cudaGetErrorString(cudaerr));

	//Free memory in the device	
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_out);


}