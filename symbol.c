#include <stdlib.h>
#include <stdio.h>
#include "type.h"
#include "symbol.h"


struct symbol * symbol_create(symbol_t kind, struct type *type, char *name) {
    struct symbol *symbol = malloc(sizeof(struct symbol));

    if (!symbol) {
        fprintf(stderr, "unable to allocate memory for symbol");
        exit(EXIT_FAILURE);
    }

    symbol->kind = kind;
    symbol->type = type;
    symbol->name = name;

    return symbol;
}

void symbol_print(struct symbol *symbol) {
    switch (symbol->kind) {
        case SYMBOL_GLOBAL:
            printf("global %s", symbol->name);
            break;
        case SYMBOL_LOCAL:
            printf("local %i", symbol->which);
            break;
        case SYMBOL_PARAM:
            printf("param %i", symbol->which);
            break;
        default:
            printf("unknown");
            break;
    }
}