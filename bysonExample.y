%{
	#include <ctype.h>
	#include <stdio.h>
	
	int yylex();
	void yyerror(char *s);
%}
%token DIGIT

%%

line	:	expr '\n'	{ printf("%d\n", $1); }
	;	
expr	:	expr '+' term	{ $$ = $1 + $3; }
	|	term		{ $$ = $1; }
	;
term	:	term '*' factor	{ $$ = $1 * $3; }
	|	factor		{ $$ = $1; }
	;
factor	:	'(' expr ')'	{ $$ = $2; }
	|	DIGIT		{ $$ = $1; }
	;

%%

int yylex() {
	int c = getchar();
	if (isdigit(c)) {
		yylval = c-'0';
		return DIGIT;
	}
	return c;
}

int main() {
	if (yyparse() != 0 )
		fprintf(stderr, "Abnormal exit\n");
	return 0;
}

void yyerror(char *s) {
	fprintf(stderr, "Error: %s\n", s);
}
