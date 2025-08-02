#include <stdlib.h>
#include <stdio.h>
#include "decl.h"
#include "param_list.h"
#include "type.h"
#include "expr.h"
#include "stmt.h"
#include "symbol.h"
#include "scope.h"
#include "hash_table.h"

struct hash_table *function_definition;


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

void decl_resolve(struct decl *decl) {
    if (!decl) {
        return;
    }

    expr_resolve(decl->value);

    symbol_t kind = scope_level() > 1 ? SYMBOL_LOCAL : SYMBOL_GLOBAL;
    decl->symbol = symbol_create(kind, decl->type, decl->name);

    if (kind == SYMBOL_LOCAL) {
        decl->symbol->which = scope_next_local_ord();
    }

    if (scope_lookup_current(decl->name)) {
        if (decl->type->kind != TYPE_FUNCTION) {
            fprintf(stderr, "resolve error: %s already bound in current scope\n", decl->name);
            resolve_error = 1;
        } else {
            if (hash_table_lookup(function_definition, decl->name)) {
                fprintf(stderr, "resolve error: function %s already defined\n", decl->name);
                resolve_error = 1;
            } else if (!decl->code) {
                fprintf(stderr, "resolve error: function %s prototype already declared\n", decl->name);
                resolve_error = 1;
            }
        }
    } else {
        scope_bind(decl->name, decl->symbol);
    }

    if (decl->code) {
        if (!hash_table_lookup(function_definition, decl->name)) {
            hash_table_insert(function_definition, decl->name, (const void *) 1);
        }
        scope_enter();
        param_list_resolve(decl->type->params);
        stmt_resolve(decl->code);
        scope_exit();
    }

    decl_resolve(decl->next);
}