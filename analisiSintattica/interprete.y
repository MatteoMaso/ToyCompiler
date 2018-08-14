%{
	#include <ctype.h>
	#include <stdio.h>
	int yylex();
	void yyerror(char *s);
%}

%union {
	double val;
	int bool; 	// 1 == true, 0 == false
}

%token	<val>	FRACT
%type	<val>	expr
%type	<bool>	comp
%type 	<bool>	bexpr

%left	'+' '-'
%left	'*' '/'
%right  UMINUS
%left	OR
%left	AND
%right	NOT

%nonassoc EQ LT GT LE GE

%%
lines	: lines bexpr '\n'	{ printf("%d\n", $2); }
	| lines expr '\n'	{ printf("Lines expr aritmetica: %f\n", $2); }
	| lines '\n'
	| /* empty */
	;

bexpr	: bexpr OR bexpr	{ if ($1 == 1 || $3 == 1) $$ = 1; else $$ = 0; }
	| bexpr AND bexpr	{ if ($1 == 1 && $3 == 1) $$ = 1; else $$ = 0; }
	| NOT bexpr		{ if ($2 == 1) $$ = 0; else $$ = 1; }
	| '(' bexpr ')'		{ $$ = $2; }
	| comp			{ $$ = $1; }
	;

comp	: expr LT expr		{ if ($1 < $3) $$ = 1; else $$ = 0; }
	| expr LE expr		{ if ($1 <= $3) $$ = 1; else $$ = 0; }
	| expr GE expr		{ if ($1 >= $3) $$ = 1; else $$ = 0; }
	| expr GT expr		{ if ($1 > $3) $$ = 1; else $$ = 0; }
	| expr EQ expr		{ if ($1 == $3) $$ = 1; else $$ = 0; }
//	| '(' comp ')'		{ $$ = $2; }
	;

expr	: expr '+' expr		{ $$ = $1 + $3; }
	| expr '-' expr		{ $$ = $1 - $3; }
	| expr '/' expr		{ $$ = $1 / $3; }
	| expr '*' expr		{ $$ = $1 * $3; }
	| '(' expr ')'		{ $$ = $2; }
	| '-' expr %prec UMINUS { $$ = -$2; }
	| FRACT
	;

%%

int main() {
	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit\n");
	return 0; 
}

void yyerror(char *s){
	fprintf(stderr, "Error: %s\n", s);
}
