#include <stdint.h>

struct RustTuple{
    int32_t rust_count;
    double* rust_array;
};

const char* rust_greeting(const char* to);
void rust_greeting_free(char *);
int16_t rust_add(int16_t a, int16_t b);
const char* rust_initmonitor(const char* s);
struct RustTuple rust_sendevent(double* inputs);
