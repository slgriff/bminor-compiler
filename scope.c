#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol.h"
#include "scope.h"
#include "hash_table.h"

int resolve_error = 0;

struct scope {
    int level;
    int param_ord;
    int local_ord;
    struct hash_table *symbol_table;
    struct scope *next;
};

struct scope *scope_top = NULL;

struct scope * scope_create(struct scope *next);
struct scope * scope_delete(struct scope *scope);

void scope_enter() {
    struct scope *scope = scope_create(scope_top);
    scope->level = scope_top ? scope_top->level + 1: 1;
    scope->local_ord = 0;
    scope_top = scope;
}

void scope_exit() {
    struct scope *next = scope_delete(scope_top);
    scope_top = next;
}

int scope_level() {
    if (!scope_top) {
        return 0;
    }

    return scope_top->level;
}

void scope_bind(const char *name, struct symbol *s) {
    if (!scope_top) {
        return;
    }

    if (!hash_table_insert(scope_top->symbol_table, name, s)) {
        fprintf(stderr, "resolve error: unable to bind %s", name);
        resolve_error = 1;
    }
}

struct symbol * scope_lookup(const char *name) {
    struct scope *scope_iter = scope_top;
    while (scope_iter) {
        struct symbol *sym = hash_table_lookup(scope_iter->symbol_table, name);
        if (sym) {
            return sym;
        }

        scope_iter = scope_iter->next;
    }

    return NULL;
}

struct symbol * scope_lookup_current(const char *name) {
    if (!scope_top) {
        return NULL;
    }

    return hash_table_lookup(scope_top->symbol_table, name);
}

struct scope * scope_create(struct scope *next) {
    struct scope *scope = malloc(sizeof(struct scope));

    if (!scope) {
        fprintf(stderr, "unable to allocate memory for scope");
        exit(EXIT_FAILURE);
    }

    scope->symbol_table = hash_table_create(0, 0);

    if (!scope->symbol_table) {
        fprintf(stderr, "unable to allocate memory for scope symbol table");
        exit(EXIT_FAILURE);
    }

    scope->next = next;
    return scope;
}

struct scope * scope_delete(struct scope *scope) {
    if (!scope) {
        return NULL;
    }

    struct scope *tmp = scope->next;

    hash_table_delete(scope->symbol_table);
    free(scope);

    return tmp;
}

int scope_next_local_ord() {
    return scope_top->local_ord++;
}

