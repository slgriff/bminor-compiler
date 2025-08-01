#include <stdio.h>
#include <stdlib.h>
#include "type.h"
#include "param_list.h"


struct type * type_create(type_t kind, struct type *subtype, struct param_list *params) {
    struct type *type = malloc(sizeof(struct type));

    if (!type) {
        fprintf(stderr, "unable to allocate memory for type");
        exit(EXIT_FAILURE);
    }

    type->kind = kind;
    type->subtype = subtype;
    type->params = params;

    return type;
}


void type_print(struct type *type) {
    if (!type) {
        return;
    }

    switch (type->kind) {
        case TYPE_VOID:
            printf("void");
            break;
        case TYPE_BOOLEAN:
            printf("boolean");
            break;
        case TYPE_CHARACTER:
            printf("char");
            break;
        case TYPE_INTEGER:
            printf("integer");
            break;
        case TYPE_STRING:
            printf("string");
            break;
        case TYPE_ARRAY:
            printf("array[]");
            type_print(type->subtype);
            break;
        case TYPE_FUNCTION:
            printf("function ");
            type_print(type->subtype);
            printf("(");
            param_list_print(type->params);
            printf(")");
            break;
    }
}