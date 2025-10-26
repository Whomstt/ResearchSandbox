// References: https://developer.nvidia.com/blog/even-easier-introduction-cuda/


#include <iostream>
#include <math.h>


__global__
void add(int n, float *x, float *y) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i+=stride) {
        y[i] = x[i] + y[i];
    }
}

int main(void) {
    int N = 1 << 20;

    float *x = new float[N];
    float *y = new float[N];

    cudaMallocManaged(&x, N * sizeof(float));
    cudaMallocManaged(&y, N * sizeof(float));

    for (int i = 0; i < N; i++) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    cudaMemPrefetchAsync(&x, N * sizeof(float), 0, 0);
    cudaMemPrefetchAsync(&y, N * sizeof(float), 0, 0);

    int blockSize = 256;
    int numBlocks = (N + blockSize - 1) / blockSize;
    add<<<numBlocks, blockSize>>>(N, x, y);

    cudaDeviceSynchronize();

    float maxError = 0.0f;

    for (int i = 0; i < N; i++) {
        maxError = fmax(maxError, fabs(y[i] - 3.0f));
    }
    std::cout << "Max error: " << maxError << std::endl;

    cudaFree(x);
    cudaFree(y);
}