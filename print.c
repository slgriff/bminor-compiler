#include <stdio.h>
#include "print.h"

void print_indent(int indent) {
    for (int i = 0; i < indent; i++) {
        printf("    ");
    }
}