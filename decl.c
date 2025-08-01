#include <stdlib.h>
#include <stdio.h>
#include "decl.h"
#include "type.h"
#include "expr.h"
#include "stmt.h"

struct decl * decl_create(char *name, struct type *type, struct expr *value, struct stmt *code, struct decl *next) {
    struct decl *decl = malloc(sizeof(struct decl));

    if (!decl) {
        fprintf(stderr, "unable to allocate memory for decl");
        exit(EXIT_FAILURE);
    }

    decl->name = name;
    decl->type = type;
    decl->value = value;
    decl->code = code;
    decl->next = next;

    return decl;
}

void decl_print(struct decl *decl, int indent) {
    if (!decl) {
        return;
    }

    printf("%s:", decl->name);
    type_print(decl->type);

    if (decl->type->kind == TYPE_FUNCTION) {
        if (decl->code) {
            printf("=\n");
            stmt_print(decl->code, indent);
        } else {
            printf(";\n");
        }

    } else {
        if (decl->value) {
            printf("=");
            expr_print(decl->value);
        }
        printf(";\n");
    }

    decl_print(decl->next, indent);
}