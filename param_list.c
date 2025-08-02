#include <stdio.h>
#include <stdlib.h>
#include "param_list.h"
#include "scope.h"
#include "symbol.h"
#include "type.h"

struct param_list * param_list_create(char *name, struct type *type, struct param_list *next) {
    struct param_list *param_list = malloc(sizeof(struct param_list));

    if (!param_list) {
        fprintf(stderr, "unable to allocate memory for param_list");
        exit(EXIT_FAILURE);
    }

    param_list->name = name;
    param_list->type = type;
    param_list->next = next;

    return param_list;
}

void param_list_print(struct param_list *param_list) {
    if (!param_list) {
        return;
    }

    printf("%s:", param_list->name);
    type_print(param_list->type);

    if (param_list->next) {
        printf(",");
    }
    
    param_list_print(param_list->next);
}

void param_list_resolve_recur(struct param_list *param_list, int i) {
    if (!param_list) {
        return;
    }

    param_list->symbol = symbol_create(SYMBOL_PARAM, param_list->type, param_list->name);
    param_list->symbol->which = i;

    if (scope_lookup_current(param_list->name)) {
        fprintf(stderr, "resolve error: %s already bound in current scope\n", param_list->name);
        resolve_error = 1;
    } else {
        scope_bind(param_list->name, param_list->symbol);
    }

    param_list_resolve_recur(param_list->next, i+1);
}

void param_list_resolve(struct param_list *param_list) {
    param_list_resolve_recur(param_list, 0);
}