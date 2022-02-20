#include <stdint.h>
#include <stdbool.h>

/// Represents the monitor, should only be an opaque pointer in Kotlin.
///https://users.rust-lang.org/t/defining-structs-enums-based-on-h-file-input/41240/9
typedef struct {
    Monitor<Incremental> monitor;
    int* relevant_ixs;
    int num_inputs;
} Rust_Bridge_Monitor;

const Rust_Bridge_Monitor* rust_init(const char* spec, const char* relevant_outputs);
double* rust_receive_single_value(long monitor, int input_ix, double value, double timestamp, unsigned int* len_out);
double* rust_receive_total_event(long monitor, double* inputs, unsigned int *len_out);
double* rust_receive_partial_event(long monitor, double* inputs, bool* active, unsigned int *len_out);
void deallocate_rust_buffer(int* ptr, unsigned int len);
