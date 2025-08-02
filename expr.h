#ifndef EXPR_H
#define EXPR_H

typedef enum {
    EXPR_INTEGER_LITERAL,
    EXPR_STRING_LITERAL,
    EXPR_CHAR_LITERAL,
    EXPR_BOOLEAN_LITERAL,
    EXPR_NAME,
	EXPR_CALL,
	EXPR_ASSIGN,
	EXPR_INCREMENT,
	EXPR_DECREMENT,
    EXPR_ADD,
    EXPR_SUB,
    EXPR_MUL,
    EXPR_DIV,
	EXPR_MOD,
	EXPR_RAISE,
	EXPR_LT,
	EXPR_LE,
	EXPR_GT,
	EXPR_GE,
	EXPR_EQ,
	EXPR_NEQ,
	EXPR_AND,
	EXPR_OR,
	EXPR_NOT,
	EXPR_NEG,
    EXPR_ARG,
	EXPR_ARRAY_SUBSCRIPT,
	EXPR_SUBSCRIPT,
	EXPR_ARRAY_LITERAL,
	EXPR_ARRAY_ELEMENT
} expr_t;

struct expr {
	/* used by all kinds of exprs */
	expr_t kind;
	struct expr *left;
	struct expr *right;

	/* used by various leaf exprs */
	const char *name;
	int literal_value;
	const char *string_literal;
	struct symbol *symbol;
};

struct expr * expr_create(expr_t kind, struct expr *left, struct expr *right);

struct expr * expr_create_name(const char *name);
struct expr * expr_create_integer_literal(int val);
struct expr * expr_create_boolean_literal(int val);
struct expr * expr_create_char_literal(char c);
struct expr * expr_create_string_literal(const char *str);

void expr_print(struct expr *expr);

void expr_resolve(struct expr *expr);

#endif
