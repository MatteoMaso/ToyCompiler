%{
#include <ctype.h>
#include <stdio.h>
#define YYSTYPE double
%}
%token NUMBER
%left '+' '-'
%left '*' '/'
%right UMINUS

%%

lines 	: 	lines expr '\n' 	{ printf(“%g\n”, $2); }
	|	lines '\n'
	|	/* empty */
	;

expr	:	expr '+' expr		{ $$ = $1 + $3; }
	|	expr '-' expr		{ $$ = $1 - $3; }
	|	expr '*' expr		{ $$ = $1 * $3; }
	|	expr '/' expr		{ $$ = $1 / $3; }
	|	'(' expr ')'		{ $$ = $2; }
	| 	'-' expr %prec UMINUS	{ $$ = -$2; }
	| NUMBER
	;

%% 

int main(){
	if ( yyparse() != 0)
		fprintf(stderr, "Abnormal exit\n");
	return 0;
}

void yyerror(char *s){
	fprintf(stderr, "Error: %s\n", s);
}
