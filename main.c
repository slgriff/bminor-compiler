#include <stdlib.h>
#include <stdio.h>
#include "bison.h"
#include "decl.h"
#include "flex.h"

extern struct decl *parser_result;

void print_token(const int t) {
	if (t == CHAR_LITERAL) {
		printf("CHAR_LITERAL %c\n", yylval.char_literal);
	} else if (t == INTEGER_LITERAL) {
		printf("INTEGER_LITERAL %i\n", yylval.integer_literal);
	} else if (t == STRING_LITERAL) {
		printf("STRING_LITERAL %s\n", yylval.string_literal);
	} else if (t == IDENTIFIER) {
		printf("IDENTIFIER %s\n", yylval.name);
	} else if (t == ARRAY) {
		printf("ARRAY\n");
	} else if (t == BOOLEAN) {
		printf("BOOLEAN\n");
	} else if (t == CHAR) {
		printf("CHAR\n");
	} else if (t == ELSE) {
		printf("ELSE\n");
	} else if (t == FALSE) {
		printf("FALSE\n");
	} else if (t == FOR) {
		printf("FOR\n");
	} else if (t == FUNCTION) {
		printf("FUNCTION\n");
	} else if (t == IF) {
		printf("IF\n");
	} else if (t == INTEGER) {
		printf("INTEGER\n");
	} else if (t == PRINT) {
		printf("PRINT\n");
	} else if (t == RETURN) {
		printf("RETURN\n");
	} else if (t == STRING) {
		printf("STRING\n");
	} else if (t == TRUE) {
		printf("TRUE\n");
	} else if (t == VOID) {
		printf("VOID\n");
	} else if (t == WHILE) {
		printf("WHILE\n");
	} else if (t == COLON) {
		printf("COLON\n");
	} else if (t == SEMICOLON) {
		printf("SEMICOLON\n");
	} else if (t == COMMA) {
		printf("COMMA\n");
	} else if (t == LBRACK) {
		printf("LBRACK\n");
	} else if (t == RBRACK) {
		printf("RBRACK\n");
	} else if (t == LBRACE) {
		printf("LBRACE\n");
	} else if (t == RBRACE) {
		printf("RBRACE\n");
	} else if (t == LPAREN) {
		printf("LPAREN\n");
	} else if (t == RPAREN) {
		printf("RPAREN\n");
	} else if (t == ASSIGN) {
		printf("ASSIGN\n");
	} else if (t == RAISE) {
		printf("RAISE\n");
	} else if (t == PLUS) {
		printf("PLUS\n");
	} else if (t == MINUS) {
		printf("MINUS\n");
	} else if (t == TIMES) {
		printf("TIMES\n");
	} else if (t == DIVIDE) {
		printf("DIVIDE\n");
	} else if (t == MODULO) {
		printf("MODULO\n");
	} else if (t == INCREMENT) {
		printf("INCREMENT\n");
	} else if (t == DECREMENT) {
		printf("DECREMENT\n");
	} else if (t == EQ) {
		printf("EQ\n");
	} else if (t == NEQ) {
		printf("NEQ\n");
	} else if (t == LT) {
		printf("LT\n");
	} else if (t == GT) {
		printf("GT\n");
	} else if (t == LE) {
		printf("LE\n");
	} else if (t == GE) {
		printf("GE\n");
	} else if (t == AND) {
		printf("AND\n");
	} else if (t == OR) {
		printf("OR\n");
	} else if (t == NOT) {
		printf("NOT\n");
	} else {
		printf("unknown token type: %i\n", t);
	}
}

void pretty_print(void) {
	return;
}

int main(int argc, char **argv) {
	if (argc < 3) {
		fprintf(stderr, "run error: missing required arguments\n");
		return EXIT_FAILURE;
	}

	const char *filename = argv[2];

	yyin = fopen(filename, "r");

	if (yyin) {

		const char *command = argv[1];

		if (strcmp(command, "-scan") == 0) {
			while (1) {
				int t = yylex();
				if (t <= 0) {
					break;
				}

				print_token(t);
			}
		} else {
			yydebug = 1;

			if (yyparse() != 0) {
				fprintf(stderr, "parse failed\n");
				fclose(yyin);
				return EXIT_FAILURE;
			}

			if (strcmp(command, "-parse") == 0) {
				printf("parse successful\n");
			} else if (strcmp(command, "-print") == 0) {
				decl_print(parser_result, 0);
			}
		}
		
		fclose(yyin);
	} else {
		fprintf(stderr, "run error: unable to open %s\n", filename);
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
