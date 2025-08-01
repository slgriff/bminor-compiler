#include <stdio.h>
#include <stdlib.h>
#include "param_list.h"
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