#include <stdio.h>
#include <stdlib.h>
#include "expr.h"

struct expr * expr_create(expr_t kind, struct expr *left, struct expr *right) {
    struct expr *expr = malloc(sizeof(struct expr));

    if (!expr) {
        fprintf(stderr, "unable to allocate memory for expr");
        exit(EXIT_FAILURE);
    }

    expr->kind = kind;
    expr->left = left;
    expr->right = right;

    return expr;
}

void expr_print(struct expr *expr) {
    if (!expr) {
        return;
    }

    switch (expr->kind) {
        case EXPR_NAME:
            printf("%s", expr->name);
            break;
        case EXPR_INTEGER_LITERAL:
            printf("%d", expr->literal_value);
            break;
        case EXPR_STRING_LITERAL:
            printf("\"");
            const char *ptr = expr->string_literal;
            while (*ptr) {
                if (*ptr == '\n') {
                    printf("\\n");
                } else if (*ptr == '\r') {
                    printf("\\r");
                } else if (*ptr == '\t') {
                    printf("\\t");
                } else if (*ptr == '\\') {
                    printf("\\\\");
                } else if (*ptr == '"') {
                    printf("\\\"");                    
                } else {
                    printf("%c", *ptr);
                }
                ptr++;
            }
            printf("\"");
            break;
        case EXPR_CHAR_LITERAL:
            printf("'");
            if (expr->literal_value == '\n') {
                printf("\\n");
            } else if (expr->literal_value == '\r') {
                printf("\\r");
            } else if (expr->literal_value == '\t') {
                printf("\\t");
            } else if (expr->literal_value == '\0') {
                printf("\\0");
            } else if (expr->literal_value == '\'') {
                printf("\\'");
            } else if (expr->literal_value == '\\') {
                printf("\\\\");
            } else {
                printf("%c", expr->literal_value);
            }
            printf("'");
            break;
        case EXPR_BOOLEAN_LITERAL:
            if (expr->literal_value) {
                printf("true");
            } else {
                printf("false");
            }
            break;
        case EXPR_INCREMENT:
            expr_print(expr->left);
            printf("++");
            break;
        case EXPR_DECREMENT:
            expr_print(expr->left);
            printf("--");
            break;
        case EXPR_NEG:
            printf("-");
            expr_print(expr->left);
            break;
        case EXPR_NOT:
            printf("!");
            expr_print(expr->left);
            break;
        case EXPR_AND:
            printf("(");
            expr_print(expr->left);
            printf("&&");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_OR:
            printf("(");
            expr_print(expr->left);
            printf("||");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_CALL:
            expr_print(expr->left);
            printf("(");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_ASSIGN:
            expr_print(expr->left);
            printf("=");
            expr_print(expr->right);
            break;
        case EXPR_ARG:
            expr_print(expr->left);
            if (expr->right) {
                printf(",");
                expr_print(expr->right);
            }
            break;
        case EXPR_ARRAY_SUBSCRIPT:
            expr_print(expr->left);
            expr_print(expr->right);
            break;
        case EXPR_SUBSCRIPT:
            printf("[");
            expr_print(expr->left);
            printf("]");
            expr_print(expr->right);
            break;
        case EXPR_ADD:
            printf("(");
            expr_print(expr->left);
            printf("+");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_SUB:
            printf("(");
            expr_print(expr->left);
            printf("-");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_DIV:
            printf("(");
            expr_print(expr->left);
            printf("/");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_MUL:
            printf("(");
            expr_print(expr->left);
            printf("*");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_MOD:
            printf("(");
            expr_print(expr->left);
            printf("%%");
            expr_print(expr->right);
            printf(")");
            break;;
        case EXPR_RAISE:
            printf("(");
            expr_print(expr->left);
            printf("^");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_LT:
            printf("(");
            expr_print(expr->left);
            printf("<");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_LE:
            printf("(");
            expr_print(expr->left);
            printf("<=");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_GT:
            printf("(");
            expr_print(expr->left);
            printf(">");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_GE:
            printf("(");
            expr_print(expr->left);
            printf(">=");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_EQ:
            printf("(");
            expr_print(expr->left);
            printf("==");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_NEQ:
            printf("(");
            expr_print(expr->left);
            printf("!=");
            expr_print(expr->right);
            printf(")");
            break;
        case EXPR_ARRAY_LITERAL:
            printf("{");
            expr_print(expr->left);
            printf("}");
            break;
        case EXPR_ARRAY_ELEMENT:
            expr_print(expr->left);
            if (expr->right) {
                printf(",");
                expr_print(expr->right);
            }
            break;
    }

    
}

struct expr * expr_create_integer_literal(int val) {
    struct expr *expr = expr_create(EXPR_INTEGER_LITERAL, NULL, NULL);
    expr->literal_value = val;
    return expr;
}

struct expr * expr_create_string_literal(const char *str) {
    struct expr *expr = expr_create(EXPR_STRING_LITERAL, NULL, NULL);
    expr->string_literal = str;
    return expr;
}

struct expr * expr_create_char_literal(char c) {
    struct expr *expr = expr_create(EXPR_CHAR_LITERAL, NULL, NULL);
    expr->literal_value = c;
    return expr;
}

struct expr * expr_create_boolean_literal(int val) {
    struct expr *expr = expr_create(EXPR_BOOLEAN_LITERAL, NULL, NULL);
    expr->literal_value = val;
    return expr;    
}

struct expr * expr_create_name(const char *name) {
    struct expr *expr = expr_create(EXPR_NAME, NULL, NULL);
    expr->name = name;
    return expr;
}