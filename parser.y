%{
#include <stdio.h>
#include <stdlib.h>
#include "flex.h"
#include "decl.h"
#include "expr.h"
#include "stmt.h"
#include "type.h"
#include "param_list.h"

void yyerror(const char *msg);

struct decl *ast_root = NULL;
%}

%verbose
%locations
%define parse.error detailed
%define parse.lac full

%union {
      struct decl *decl;
      struct stmt *stmt;
      struct expr *expr;
      struct type *type;
      struct param_list *param_list;
      char *name;
      int integer_literal;
      char char_literal;
      char *string_literal;
}

%token <name> IDENTIFIER
%token <integer_literal> INTEGER_LITERAL
%token <string_literal> STRING_LITERAL
%token <char_literal> CHAR_LITERAL
%token ARRAY
%token BOOLEAN
%token CHAR
%token ELSE
%token FALSE
%token FOR
%token FUNCTION
%token IF
%token INTEGER
%token PRINT
%token RETURN
%token STRING
%token TRUE
%token VOID
%token WHILE
%token COMMA ","
%token COLON ":"
%token SEMICOLON ";"
%token LPAREN "("
%token RPAREN ")"
%token LBRACK "["
%token RBRACK "]"
%token LBRACE "{"
%token RBRACE "}"
%token INCREMENT "++"
%token DECREMENT "--"
%token MINUS "-"
%token PLUS "+"
%token TIMES "*"
%token DIVIDE "/"
%token RAISE "^"
%token MODULO "%"
%token NOT "!"
%token AND "&&"
%token OR "||"
%token LT "<"
%token LE "<="
%token GT ">"
%token GE ">="
%token EQ "=="
%token NEQ "!="
%token ASSIGN "="

%printer { fprintf(yyo, "%s", $$); } IDENTIFIER STRING_LITERAL
%printer { fprintf(yyo, "%i", $$); } INTEGER_LITERAL
%printer { fprintf(yyo, "%c", $$); } CHAR_LITERAL

%type <decl> program decl_list decl function_decl variable_decl array_decl
%type <expr> expr return_val arg_list arg name assignment_expr atomic_expr lvalue logical_or_expr logical_and_expr deref_expr postfix_expr array_subscript array_subscript_list unary_expr exponent_expr mult_expr add_expr comparison_expr optional_expr optional_length array_literal array_elements array_element optional_args
%type <type> atomic_type function_return_type function_header parameter_type array_type array_parameter_type array_type_dimension array_type_dimensions array_parameter_type_dimension array_parameter_type_dimensions
%type <param_list> function_parameters parameter_list parameter
%type <stmt> function_body stmts stmt closed_stmt open_stmt stmt_block

%start program

%%

program: %empty    { ast_root = NULL; }
       | decl_list { 
                       struct decl *prev = NULL;
                       struct decl *curr = $1;
                       while (curr) {
                           struct decl *tmp = curr->next;
                           curr->next = prev;
                           prev = curr;
                           curr = tmp; 
                       }
                       ast_root = prev;
                   }
       ;

decl_list: decl           { $$ = $1; }
         | decl_list decl { $2->next = $1; $$ = $2; }
         ;

decl: variable_decl { $$ = $1; }
    | function_decl { $$ = $1; }
    | array_decl    { $$ = $1; }
    ;

variable_decl: IDENTIFIER COLON atomic_type SEMICOLON             { $$ = decl_create($1, $3, NULL, NULL, NULL); }
             | IDENTIFIER COLON atomic_type ASSIGN expr SEMICOLON { $$ = decl_create($1, $3, $5, NULL, NULL); }
             ;

function_decl: IDENTIFIER COLON function_header SEMICOLON            { $$ = decl_create($1, $3, NULL, NULL, NULL); }
             | IDENTIFIER COLON function_header ASSIGN function_body { $$ = decl_create($1, $3, NULL, $5, NULL); }
             ;

array_decl: IDENTIFIER COLON array_type SEMICOLON                      { $$ = decl_create($1, $3, NULL, NULL, NULL); }
          | IDENTIFIER COLON array_type ASSIGN array_literal SEMICOLON { $$ = decl_create($1, $3, $5, NULL, NULL); }
          ;

array_type: array_type_dimensions atomic_type { 
                                                  struct type *curr = $1;
                                                  while (curr->subtype) {
                                                      curr = curr->subtype;
                                                  }
                                                  curr->subtype = $2;
                                                  $$ = $1;
                                              }
          ;

array_type_dimensions: array_type_dimension                       { $$ = $1; }
                     | array_type_dimensions array_type_dimension { $2->subtype = $1; $$ = $2; }
                     ;

array_type_dimension: ARRAY LBRACK optional_length RBRACK { $$ = type_create(TYPE_ARRAY, NULL, NULL); }
                    ;

optional_length: %empty          { $$ = NULL; }
               | INTEGER_LITERAL { $$ = expr_create_integer_literal($1); }
               ;

array_literal: LBRACE array_elements RBRACE { 
                                                struct expr *prev = NULL;
                                                struct expr *curr = $2;
                                                while (curr) {
                                                    struct expr *tmp = curr->right;
                                                    curr->right = prev;
                                                    prev = curr;
                                                    curr = tmp;
                                                }
                                                $$ = expr_create(EXPR_ARRAY_LITERAL, prev, NULL);
                                            }
             ;

array_element: expr          { $$ = expr_create(EXPR_ARRAY_ELEMENT, $1, NULL); }
             | array_literal { $$ = expr_create(EXPR_ARRAY_ELEMENT, $1, NULL);}
             ;

array_elements: array_element                      { $$ = $1; }
              | array_elements COMMA array_element { $3->right = $1; $$ = $3; }
              ;

function_header: FUNCTION function_return_type function_parameters { $$ = type_create(TYPE_FUNCTION, $2, $3); }
               ;

function_return_type: atomic_type { $$ = $1; }
                    | VOID        { $$ = type_create(TYPE_VOID, NULL, NULL); }
                    ;

function_body: LBRACE RBRACE       { $$ = stmt_create(STMT_BLOCK, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
             | stmt_block          { $$ = $1; }
              ;

stmt_block: LBRACE stmts RBRACE {
                                    struct stmt *prev = NULL;
                                    struct stmt *curr = $2;
                                    while (curr) {
                                        struct stmt *tmp = curr->next;
                                        curr->next = prev;
                                        prev = curr;
                                        curr = tmp;
                                    } 
                                    $$ = stmt_create(STMT_BLOCK, NULL, NULL, NULL, NULL, prev, NULL, NULL); 
                                   }
             ;

stmts: stmt       { $$ = $1; }
     | stmts stmt { $2->next = $1; $$ = $2; }
     ;

stmt: closed_stmt { $$ = $1; }
    | open_stmt   { $$ = $1; }
    ;

optional_expr: %empty { $$ = NULL; }
             | expr   { $$ = $1; }
             ;

open_stmt: IF LPAREN expr RPAREN stmt                                                                { $$ = stmt_create(STMT_IF_ELSE, NULL, NULL, $3, NULL, $5, NULL, NULL); }
         | IF LPAREN expr RPAREN closed_stmt ELSE open_stmt                                          { $$ = stmt_create(STMT_IF_ELSE, NULL, NULL, $3, NULL, $5, $7, NULL); }
         | WHILE LPAREN expr RPAREN open_stmt                                                        { $$ = stmt_create(STMT_WHILE, NULL, NULL, $3, NULL, $5, NULL, NULL); }
         | FOR LPAREN optional_expr SEMICOLON optional_expr SEMICOLON optional_expr RPAREN open_stmt { $$ = stmt_create(STMT_FOR, NULL, $3, $5, $7, $9, NULL, NULL); }
         ;

closed_stmt: variable_decl                                                                               { $$ = stmt_create(STMT_DECL, $1, NULL, NULL, NULL, NULL, NULL, NULL); }
           | array_decl                                                                                  { $$ = stmt_create(STMT_DECL, $1, NULL, NULL, NULL, NULL, NULL, NULL); }
           | expr SEMICOLON                                                                              { $$ = stmt_create(STMT_EXPR, NULL, NULL, $1, NULL, NULL, NULL, NULL); }
           | RETURN return_val SEMICOLON                                                                 { $$ = stmt_create(STMT_RETURN, NULL, NULL, $2, NULL, NULL, NULL, NULL); }
           | PRINT SEMICOLON                                                                             { $$ = stmt_create(STMT_PRINT, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
           | PRINT arg_list SEMICOLON                                                                    { 
                                                                                                             struct expr *prev = NULL;
                                                                                                             struct expr *curr = $2;
                                                                                                             while (curr) {
                                                                                                                 struct expr *tmp = curr->right;
                                                                                                                 curr->right = prev;
                                                                                                                 prev = curr;
                                                                                                                 curr = tmp;
                                                                                                             }
                                                                                                             $$ = stmt_create(STMT_PRINT, NULL, NULL, prev, NULL, NULL, NULL, NULL); 
                                                                                                         }
           | LBRACE RBRACE                                                                               { $$ = stmt_create(STMT_BLOCK, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
           | stmt_block                                                                                  { $$ = $1; }
           | IF LPAREN expr RPAREN closed_stmt ELSE closed_stmt                                          { $$ = stmt_create(STMT_IF_ELSE, NULL, NULL, $3, NULL, $5, $7, NULL); }
           | FOR LPAREN optional_expr SEMICOLON optional_expr SEMICOLON optional_expr RPAREN closed_stmt { $$ = stmt_create(STMT_FOR, NULL, $3, $5, $7, $9, NULL, NULL); }
           | WHILE LPAREN expr RPAREN closed_stmt                                                        { $$ = stmt_create(STMT_WHILE, NULL, NULL, $3, NULL, $5, NULL, NULL); }
           ;

optional_args: %empty   { $$ = NULL; }
             | arg_list { 
                            struct expr *prev = NULL;
                            struct expr *curr = $1;
                            while (curr) {
                                struct expr *tmp = curr->right;
                                curr->right = prev;
                                prev = curr;
                                curr = tmp;
                            }
                            $$ = prev;
                        }
             ;

arg_list: arg                { $$ = $1; }
        | arg_list COMMA arg { $3->right = $1; $$ = $3; }
        ;

arg : expr { $$ = expr_create(EXPR_ARG, $1, NULL); }
    ;

return_val: %empty { $$ = NULL; }
          | expr   { $$ = $1; }
          ;

function_parameters: LPAREN RPAREN                { $$ = NULL; }
                   | LPAREN parameter_list RPAREN { 
                                                      struct param_list *prev = NULL;
                                                      struct param_list *curr = $2;
                                                      while (curr) {
                                                          struct param_list *tmp = curr->next;
                                                          curr->next = prev;
                                                          prev = curr;
                                                          curr = tmp;
                                                      }
                                                      $$ = prev; 
                                                  }
                   ;

parameter_list: parameter                      { $$ = $1; }                     
              | parameter_list COMMA parameter { $3->next = $1; $$ = $3; }
              ;

parameter: IDENTIFIER COLON parameter_type { $$ = param_list_create($1, $3, NULL); }
         ;

parameter_type: atomic_type          { $$ = $1; }
              | array_parameter_type { $$ = $1; }
              ;

array_parameter_type: array_parameter_type_dimensions atomic_type {
                                                                      struct type *curr = $1;
                                                                      while (curr->subtype) {
                                                                          curr = curr->subtype;
                                                                      }
                                                                      curr->subtype = $2;
                                                                      $$ = $1;   
                                                                  }
                    ;

array_parameter_type_dimensions: array_parameter_type_dimension                                 { $$ = $1; }
                               | array_parameter_type_dimensions array_parameter_type_dimension { $2->subtype = $1; $$ = $2; }
                               ;

array_parameter_type_dimension: ARRAY LBRACK RBRACK { $$ = type_create(TYPE_ARRAY, NULL, NULL); }
                              ;

atomic_type: INTEGER { $$ = type_create(TYPE_INTEGER, NULL, NULL); }
           | BOOLEAN { $$ = type_create(TYPE_BOOLEAN, NULL, NULL); }
           | CHAR    { $$ = type_create(TYPE_CHARACTER, NULL, NULL); }
           | STRING  { $$ = type_create(TYPE_STRING, NULL, NULL); }
           ;

expr: assignment_expr { $$ = $1; }
    ;

assignment_expr: lvalue ASSIGN expr { $$ = expr_create(EXPR_ASSIGN, $1, $3); }
               | logical_or_expr    { $$ = $1; }
               ;

logical_or_expr: logical_or_expr OR logical_and_expr { $$ = expr_create(EXPR_OR, $1, $3); }
               | logical_and_expr                    { $$ = $1; } 
               ;

logical_and_expr: logical_and_expr AND comparison_expr { $$ = expr_create(EXPR_AND, $1, $3); }
                | comparison_expr                      { $$ = $1; }
                ;

comparison_expr: comparison_expr LT add_expr  { $$ = expr_create(EXPR_LT, $1, $3); }
               | comparison_expr LE add_expr  { $$ = expr_create(EXPR_LE, $1, $3); }
               | comparison_expr GT add_expr  { $$ = expr_create(EXPR_GT, $1, $3); }
               | comparison_expr GE add_expr  { $$ = expr_create(EXPR_GE, $1, $3); }
               | comparison_expr EQ add_expr  { $$ = expr_create(EXPR_EQ, $1, $3); }
               | comparison_expr NEQ add_expr { $$ = expr_create(EXPR_NEQ, $1, $3); }
               | add_expr                     { $$ = $1;}
               ;

add_expr: add_expr PLUS mult_expr  { $$ = expr_create(EXPR_ADD, $1, $3); }
        | add_expr MINUS mult_expr { $$ = expr_create(EXPR_SUB, $1, $3); }
        | mult_expr                { $$ = $1; }
        ;

mult_expr: mult_expr TIMES exponent_expr  { $$ = expr_create(EXPR_MUL, $1, $3); }
         | mult_expr DIVIDE exponent_expr { $$ = expr_create(EXPR_DIV, $1, $3); }
         | mult_expr MODULO exponent_expr { $$ = expr_create(EXPR_MOD, $1, $3); }
         | exponent_expr                  { $$ = $1; }
         ;

exponent_expr: unary_expr RAISE exponent_expr { $$ = expr_create(EXPR_RAISE, $1, $3); }
             | unary_expr                     { $$ = $1; }
             ;

unary_expr: MINUS unary_expr { $$ = expr_create(EXPR_NEG, $2, NULL); }
          | NOT unary_expr   { $$ = expr_create(EXPR_NOT, $2, NULL); }
          | postfix_expr { $$ = $1; }
          ;

postfix_expr: deref_expr INCREMENT { $$ = expr_create(EXPR_INCREMENT, $1, NULL); }
            | deref_expr DECREMENT { $$ = expr_create(EXPR_DECREMENT, $1, NULL); }
            | deref_expr           { $$ = $1; }
            ;

deref_expr: name LPAREN optional_args RPAREN { $$ = expr_create(EXPR_CALL, $1, $3); }
          | name array_subscript_list        {
                                                 struct expr *prev = NULL;
                                                 struct expr *curr = $2;
                                                 while (curr) {
                                                     struct expr *tmp = curr->right;
                                                     curr->right = prev;
                                                     prev = curr;
                                                     curr = tmp;
                                                 }
                                                 $$ = expr_create(EXPR_ARRAY_SUBSCRIPT, $1, prev);
                                             }
          | LPAREN expr RPAREN               { $$ = $2; }
          | atomic_expr                      { $$ = $1; }
          ;

array_subscript: LBRACK expr RBRACK { $$ = expr_create(EXPR_SUBSCRIPT, $2, NULL); }
               ;

array_subscript_list: array_subscript                      { $$ = $1; }
                    | array_subscript_list array_subscript { $2->right = $1; $$ = $2; }
                    ;

lvalue: name                      { $$ = $1; }
      | name array_subscript_list { 
                                      struct expr *prev = NULL;
                                      struct expr *curr = $2;
                                      while (curr) {
                                          struct expr *tmp = curr->right;
                                          curr->right = prev;
                                          prev = curr;
                                          curr = tmp;
                                      }
                                      $$ = expr_create(EXPR_ARRAY_SUBSCRIPT, $1, prev);
                                  }
      ;

atomic_expr: INTEGER_LITERAL             { $$ = expr_create_integer_literal($1); }
           | CHAR_LITERAL                { $$ = expr_create_char_literal($1); }
           | STRING_LITERAL              { $$ = expr_create_string_literal($1); }
           | TRUE                        { $$ = expr_create_boolean_literal(1); }
           | FALSE                       { $$ = expr_create_boolean_literal(0); }
           | name                        { $$ = $1; }
           ;

name: IDENTIFIER { $$ = expr_create_name($1); }
    ;

%%

void yyerror(const char *msg) {
      fprintf(stderr, "parse error: %s\n", msg);
}
