%{
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include "bison.h"

#define MAX_LENGTH 255

int buffer_position = 0;
char buffer[MAX_LENGTH+1];
int line_number = 1;
int line_position = 1;

void mark_location_start(void) {
	yylloc.first_line = line_number;
	yylloc.first_column = line_position;
}

void mark_location_end(void) {
	yylloc.last_line = line_number;
	yylloc.last_column = line_position;
}

void update_line_position(void) {
	line_position += yyleng;
}

void new_line(void) {
	line_number++;
	line_position = 1;
}
%}

%option never-interactive
%option batch
%option warn
%option nodefault
%option noinput nounput
%option noyywrap

%x BLOCK_COMMENT
%x STRING_CONSTANT

%%

[[:blank:]]+ { update_line_position(); }
\n { new_line(); }
"//".* { update_line_position(); }
"/*" { update_line_position(); BEGIN(BLOCK_COMMENT); }
<BLOCK_COMMENT>\n { new_line(); }
<BLOCK_COMMENT><<EOF>> {
						fprintf(stderr, "scan error: open block comment at %i:%i\n", line_number, line_position);
						exit(1);
                      }
<BLOCK_COMMENT>[^*\n]+ { update_line_position(); }
<BLOCK_COMMENT>"*"+[^*/\n]* { update_line_position(); }
<BLOCK_COMMENT>"*"+"/" { update_line_position(); BEGIN(INITIAL); }
array { mark_location_start(); update_line_position(); mark_location_end(); return ARRAY; }
boolean { mark_location_start(); update_line_position(); mark_location_end(); return BOOLEAN; }
char { mark_location_start(); update_line_position(); mark_location_end(); return CHAR; }
else { mark_location_start(); update_line_position(); mark_location_end(); return ELSE; }
false { mark_location_start(); update_line_position(); mark_location_end(); return FALSE; }
for { mark_location_start(); update_line_position(); mark_location_end(); return FOR; }
function { mark_location_start(); update_line_position(); mark_location_end(); return FUNCTION; }
if { mark_location_start(); update_line_position(); mark_location_end(); return IF; }
integer { mark_location_start(); update_line_position(); mark_location_end(); return INTEGER; }
print { mark_location_start(); update_line_position(); mark_location_end(); return PRINT; }
return { mark_location_start(); update_line_position(); mark_location_end(); return RETURN; }
string { mark_location_start(); update_line_position(); mark_location_end(); return STRING; }
true { mark_location_start(); update_line_position(); mark_location_end(); return TRUE; }
void { mark_location_start(); update_line_position(); mark_location_end(); return VOID; }
while { mark_location_start(); update_line_position(); mark_location_end(); return WHILE; }
, { mark_location_start(); update_line_position(); mark_location_end(); return COMMA; }
: { mark_location_start(); update_line_position(); mark_location_end(); return COLON; }
; { mark_location_start(); update_line_position(); mark_location_end(); return SEMICOLON; }
"(" { mark_location_start(); update_line_position(); mark_location_end(); return LPAREN; }
")" { mark_location_start(); update_line_position(); mark_location_end(); return RPAREN; }
"[" { mark_location_start(); update_line_position(); mark_location_end(); return LBRACK; }
"]" { mark_location_start(); update_line_position(); mark_location_end(); return RBRACK; }
"{" { mark_location_start(); update_line_position(); mark_location_end(); return LBRACE; }
"}" { mark_location_start(); update_line_position(); mark_location_end(); return RBRACE; }
"++" { mark_location_start(); update_line_position(); mark_location_end(); return INCREMENT; }
"--" { mark_location_start(); update_line_position(); mark_location_end(); return DECREMENT; }
"+" { mark_location_start(); update_line_position(); mark_location_end(); return PLUS; }
- { mark_location_start(); update_line_position(); mark_location_end(); return MINUS; }
"*" { mark_location_start(); update_line_position(); mark_location_end(); return TIMES; }
"/" { mark_location_start(); update_line_position(); mark_location_end(); return DIVIDE; }
% { mark_location_start(); update_line_position(); mark_location_end(); return MODULO; }
"^" { mark_location_start(); update_line_position(); mark_location_end(); return RAISE; }
= { mark_location_start(); update_line_position(); mark_location_end(); return ASSIGN; }
== { mark_location_start(); update_line_position(); mark_location_end(); return EQ; }
!= { mark_location_start(); update_line_position(); mark_location_end(); return NEQ; }
"<" { mark_location_start(); update_line_position(); mark_location_end(); return LT; }
"<=" { mark_location_start(); update_line_position(); mark_location_end(); return LE; }
">" { mark_location_start(); update_line_position(); mark_location_end(); return GT; }
">=" { mark_location_start(); update_line_position(); mark_location_end(); return GE; }
&& { mark_location_start(); update_line_position(); mark_location_end(); return AND; }
"||" { mark_location_start(); update_line_position(); mark_location_end(); return OR; }
! { mark_location_start(); update_line_position(); mark_location_end(); return NOT; }
[[:alpha:]_][[:alnum:]_]* { 
							if (yyleng > MAX_LENGTH) {
								fprintf(stderr, "scan error: identifier length longer than %i characters at %i:%i\n", MAX_LENGTH, line_number, line_position);
								exit(1);
							}
							mark_location_start();
							update_line_position();
							mark_location_end();
							yylval.name = strdup(yytext);
							return IDENTIFIER;
	                      }
[[:digit:]]+ { 
				mark_location_start();
				update_line_position();
				mark_location_end(); 
				yylval.integer_literal = atoi(yytext);
				return INTEGER_LITERAL;
		 	 }
'\\n' {
		mark_location_start();
		update_line_position();
		mark_location_end();
		yylval.char_literal = '\n';
		return CHAR_LITERAL;
      }
'\\0' {
		mark_location_start();
		update_line_position();
		mark_location_end();
		yylval.char_literal = '\0';
		return CHAR_LITERAL;
      }
'\\[[:print:]]' {
					mark_location_start();
					update_line_position();
					mark_location_end();
					yylval.char_literal = *(yytext+2);
					return CHAR_LITERAL;
      			}
'\\' {
		fprintf(stderr, "scan error: open char literal at %i:%i\n", line_number, line_position);
		exit(1);
     }
'[[:print:]]' {
		mark_location_start();
		update_line_position();
		mark_location_end();
		yylval.char_literal = *(yytext+1);
		return CHAR_LITERAL;
    }
'.' {
		fprintf(stderr, "scan error: invalid char literal at %i:%i\n", line_number, line_position);
		exit(1);
	}
\" {
	mark_location_start();
	update_line_position();
	buffer_position = 0;
	BEGIN(STRING_CONSTANT);
   }
<STRING_CONSTANT>\\n {
						update_line_position();
						if (buffer_position == MAX_LENGTH) {
							fprintf(stderr, "scan error: string literal length longer than %i characters at %i:%i\n", MAX_LENGTH, line_number, line_position);
							exit(1);
						}
						buffer[buffer_position++] = '\n';
                     }
<STRING_CONSTANT>\\0 {
						update_line_position();
						if (buffer_position == MAX_LENGTH) {
							fprintf(stderr, "scan error: string literal length longer than %i characters at %i:%i\n", MAX_LENGTH, line_number, line_position);
							exit(1);
						}
						buffer[buffer_position++] = '\0';
                     }
<STRING_CONSTANT>\\. {
						update_line_position();
						if (buffer_position == MAX_LENGTH) {
							fprintf(stderr, "scan error: string literal length longer than %i characters at %i:%i\n", MAX_LENGTH, line_number, line_position);
							exit(1);
						}
						buffer[buffer_position++] = *(yytext+1);
                     }
<STRING_CONSTANT>\n      |
<STRING_CONSTANT><<EOF>> {
							fprintf(stderr, "scan error: open string literal at %i:%i\n", line_number, line_position);
							exit(1);
           		         }
<STRING_CONSTANT>\" {
						update_line_position();
						mark_location_end();
						if (buffer_position == MAX_LENGTH) {
							fprintf(stderr, "scan error: string literal length longer than %i characters at %i:%i\n", MAX_LENGTH, line_number, line_position);
							exit(1);
						}
						buffer[buffer_position++] = '\0';
						yylval.string_literal = strdup(buffer);
						BEGIN(INITIAL);
						return STRING_LITERAL;
                    }
<STRING_CONSTANT>. {
						update_line_position();
						if (buffer_position == MAX_LENGTH) {
							fprintf(stderr, "scan error: string literal length longer than %i characters at %i:%i\n", MAX_LENGTH, line_number, line_position);
							exit(1);
						}
						buffer[buffer_position++] = *yytext;
                   }

<*>. {
	 	fprintf(stderr, "scan error: unexpected input %s at %i:%i\n", yytext, line_number, line_position);
	 	exit(1);
     }
%%