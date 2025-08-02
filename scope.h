#ifndef SCOPE_H
#define SCOPE_H

extern int resolve_error;

void scope_enter();
void scope_exit();
int scope_level();
void scope_bind(const char *name, struct symbol *s);
struct symbol * scope_lookup(const char *name);
struct symbol * scope_lookup_current(const char *name);

int scope_next_local_ord();

#endif