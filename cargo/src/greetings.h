#include <stdint.h>
#include <stdbool.h>

const KotlinMonitor* init(const char* spec, const char* relevant_outputs);
double* receive_single_value(long monitor, int input_ix, double value, double timestamp, unsigned int* len_out);
double* receive_total_event(long monitor, double* inputs, unsigned int *len_out);
double* receive_partial_event(long monitor, double* inputs, bool* active, unsigned int *len_out);
void deallocate_rust_buffer(int* ptr, unsigned int len);
