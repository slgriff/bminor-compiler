#include <stdlib.h>
#include <stdio.h>
#include "stmt.h"
#include "decl.h"
#include "expr.h"
#include "print.h"


struct stmt * stmt_create(stmt_t kind, struct decl *decl, struct expr *init_expr, struct expr *expr, struct expr *next_expr, struct stmt *body, struct stmt *else_body, struct stmt *next) {
    struct stmt *stmt = malloc(sizeof(struct stmt));

    if (!stmt) {
        fprintf(stderr, "unable to allocate memory for stmt");
        exit(EXIT_FAILURE);
    }

    stmt->kind = kind;
    stmt->decl = decl;
    stmt->init_expr = init_expr;
    stmt->expr = expr;
    stmt->next_expr = next_expr;
    stmt->body = body;
    stmt->else_body = else_body;
    stmt->next = next;

    return stmt;
}

void stmt_print(struct stmt *stmt, int indent) {
    if (!stmt) {
        return;
    }

    switch (stmt->kind) {
        case STMT_BLOCK:
            print_indent(indent);
            printf("{\n");

            stmt_print(stmt->body, indent+1);

            print_indent(indent);
            printf("}\n");
            break;
        case STMT_DECL:
            print_indent(indent);
            decl_print(stmt->decl, indent);
            break;
        case STMT_EXPR:
            print_indent(indent);
            expr_print(stmt->expr);
            printf(";\n");
            break;
        case STMT_RETURN:
            print_indent(indent);
            printf("return");
            if (stmt->expr) {
                printf(" ");
                expr_print(stmt->expr);
            }
            printf(";\n");
            break;
        case STMT_PRINT:
            print_indent(indent);
            printf("print");
            if (stmt->expr) {
                printf(" ");
                expr_print(stmt->expr);
            }
            printf(";\n");
            break;
        case STMT_FOR:
            print_indent(indent);
            printf("for(");
            expr_print(stmt->init_expr);
            printf(";");
            expr_print(stmt->expr);
            printf(";");
            expr_print(stmt->next_expr);
            printf(")\n");
            if (stmt->body->kind == STMT_BLOCK) {
                stmt_print(stmt->body, indent);
            } else {
                stmt_print(stmt->body, indent+1);
            }
            break;
        case STMT_IF_ELSE:
            print_indent(indent);
            printf("if(");
            expr_print(stmt->expr);
            printf(")\n");
            if (stmt->body->kind == STMT_BLOCK) {
                stmt_print(stmt->body, indent);
            } else {
                stmt_print(stmt->body, indent+1);
            }
            if (stmt->else_body) {
                print_indent(indent);
                printf("else\n");
                if (stmt->else_body->kind == STMT_BLOCK) {
                    stmt_print(stmt->else_body, indent);
                } else {
                    stmt_print(stmt->else_body, indent+1);
                }
            }
            break;
        case STMT_WHILE:
            print_indent(indent);
            printf("while(");
            expr_print(stmt->expr);
            printf(")\n");
            if (stmt->body->kind == STMT_BLOCK) {
                stmt_print(stmt->body, indent);
            } else {
                stmt_print(stmt->body, indent+1);
            }
            break;
    }

    stmt_print(stmt->next, indent);

}
