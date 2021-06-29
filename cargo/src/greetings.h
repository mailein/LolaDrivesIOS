#include <stdint.h>

const char* rust_greeting(const char* to);
void rust_greeting_free(char *);
int16_t rust_add(int16_t a, int16_t b);
const char* rust_initmonitor(const char* s);
double* rust_sendevent(double* inputs, unsigned int *len);
void rust_array_free(double* arr);