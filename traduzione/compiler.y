%{
	#include <ctype.h>
	#include <stdio.h>
	int yylex();
	void yyerror(char *s);
	char * next_var();
	int counter;

	typedef struct Node
	{ 
		char * addr;
	} Node;
%}


%union {
	Node *node
	double val;
	int bool;      // 1 == true, 0 == false
}

%token	<node>	FRACT
%type	<node>	expr
%type	<node>	comp
%type   <node>	bexpr

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

comp	: expr LT expr		{ 	char *var = next_var();
					Node var.addr = malloc(4);
					if($1 < $3){
					    *var = 1
					} else{
					*var = 0;
					}
				 }

	| expr LE expr		{ 	char *var = next_var();
					Node var.addr = malloc(4);
					if($1 <= $3){
					    *var = 1
					} else{
					*var = 0;
					}
				 }

	| expr GE expr		{ 	char *var = next_var();
					Node var.addr = malloc(4);
					if($1 >= $3){
					    *var = 1
					} else{
					*var = 0;
					}
				 }

	| expr GT expr		{ 	char *var = next_var();
					Node var.addr = malloc(4);
					if($1 > $3){
					    *var = 1
					} else{
					*var = 0;
					}
				 }

	| expr EQ expr		{ 	char *var = next_var();
					Node var.addr = malloc(4);
					if($1 == $3){
					    *var = 1
					} else{
					*var = 0;
					}
				 }

	| '(' comp ')'		{ 	char *var = next_var();
					Node var.addr = malloc(sizeOf($2));  // size of boolean
					*var = $2;
				 }
	;

expr	: expr '+' expr		{ 	char *var = next_var();
					Node var.addr = malloc(sizeOf($1));
					*var = ($1+$3);
				 }
	| expr '-' expr		{ 	char *var = next_var();
					Node var.addr = malloc(sizeOf($1));
					*var = ($1-$3);
				 }
	| expr '/' expr		{ 	char *var = next_var();
					Node var.addr = malloc(sizeOf($1));
					*var = ($1*$3);
				 }
	| expr '*' expr		{ 	char *var = next_var();
					Node var.addr = malloc(sizeOf($1));
					*var = ($1*$3);
				 }
	| '(' expr ')'		{ 	char *var = next_var();
					Node var.addr = malloc(sizeOf($2));
					*var = $2;
				 }
	| '-' expr %prec UMINUS { 	char *var = next_var();
					Node var.addr = malloc(sizeOf($2));
					*var = -$2;
				 }
	| FRACT			{ 	
					char *var = next_var();
					Node var.addr = malloc(sizeOf($1));
					*var = $1;
				
				}
	;

%%



int main() {
	
	counter = 0;

	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit\n");

	return 0; 
}

void yyerror(char *s){
	fprintf(stderr, "Error: %s\n", s);
}

char * next_var(){

	static char buffer[1024];
	snprintf(buffer, sizeof(buffer), "t%d", counter);
	counter++;
	return buffer;
}


