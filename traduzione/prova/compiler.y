%{
	#include <ctype.h>
	#include <stdio.h>
	int yylex();
	void yyerror(char *s);
	char * next_var();
	int counter;

	struct Node{
		char * addr;
		double value;
	};
%}

%union {
	struct Node * node;
	double val;
	int bool; 	// 1 == true, 0 == false
}

%token	<val>	FRACT
%type	<node>	expr
//%type	<bool>	comp
//%type 	<bool>	bexpr

%left	'+' '-'
%left	'*' '/'
%right  UMINUS
%left	OR
%left	AND
%right	NOT

%nonassoc EQ LT GT LE GE

%%
lines	//: lines bexpr '\n'	{ printf("%d\n", $2); }
	: lines expr '\n'	{ printf("Lines expr aritmetica: %f\n", $2->value); }
	| lines '\n'
	| /* empty */
	;

//bexpr	: bexpr OR bexpr	{ if ($1 == 1 || $3 == 1) $$ = 1; else $$ = 0; }
//	| bexpr AND bexpr	{ if ($1 == 1 && $3 == 1) $$ = 1; else $$ = 0; }
//	| NOT bexpr		{ if ($2 == 1) $$ = 0; else $$ = 1; }
//	| '(' bexpr ')'		{ $$ = $2; }
//	| comp			{ $$ = $1; }
//	;

//comp	: expr LT expr		{ if ($1 < $3) $$ = 1; else $$ = 0; }
//	| expr LE expr		{ if ($1 <= $3) $$ = 1; else $$ = 0; }
//	| expr GE expr		{ if ($1 >= $3) $$ = 1; else $$ = 0; }
//	| expr GT expr		{ if ($1 > $3) $$ = 1; else $$ = 0; }
//	| expr EQ expr		{ if ($1 == $3) $$ = 1; else $$ = 0; }
//	| '(' comp ')'		{ $$ = $2; }
//	;

expr	: expr '+' expr		{ 	char * temp = next_var();
					printf("prova: %f + %f\n", $1->value, $3->value);
					struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
					n->value = ($1->value)+($3->value);
					n->addr = temp;
					$$ = n;
					printf("%s = %s + %s\n", temp, $1->addr, $3->addr);
 	//				struct node n;
					//n.val = 2;
					//n.addr = temp;
					//$$ = &n;
				 }
	//| expr '-' expr		{ $$ = $1 - $3; }
	//| expr '/' expr		{ $$ = $1 / $3; }
	//| expr '*' expr		{ $$ = $1 * $3; }
	//| '(' expr ')'		{ $$ = $2; }
	//| '-' expr %prec UMINUS { $$ = -$2; }
	| FRACT			{ 	
					char * temp = next_var();
					printf("%s = %f\n", temp, $1);
 					struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
					n->addr = temp;
					n->value = $1;
					$$ = n;
					//$$ = &n;
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

	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	snprintf(buffer, sizeof(buffer), "t%d", counter);
	counter++;
	return buffer;
}



