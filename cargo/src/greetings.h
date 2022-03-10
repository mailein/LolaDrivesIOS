#include <stdint.h>

//const char* rust_greeting(const char* to);
void rust_string_free(char *);
//int16_t rust_add(int16_t a, int16_t b);
const char* rust_initmonitor(const char* j_recipient, const char* relevant_outputs);
double* rust_sendevent(double* inputs, unsigned int len_in, unsigned int *len_out);
//void rust_array_free(double* arr);