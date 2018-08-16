%{
	#include <ctype.h>
	#include <stdio.h>
	#include <string.h>
	int yylex();
	void yyerror(char *s);
	char * next_var();
	int counter;
	struct Node * mknodeB(char * tipo, struct Node * n1, struct Node * n2);

	struct Node{
		char * addr;
		double value;
		int boolean;
	};
%}

%union {
	struct Node * node;
	double val;
	int bool; 	// 1 == true, 0 == false
}

%token	<val>	FRACT
%type	<node>	expr
%type	<node>	comp
%type 	<node>	bexpr

%left	'+' '-'
%left	'*' '/'
%right  UMINUS
%left	OR
%left	AND
%right	NOT

%nonassoc EQ LT GT LE GE

%%
lines	: lines bexpr '\n'	{ printf("Boolean Expression: %s = %d\n", $2->addr, $2->boolean); }
	| lines expr '\n'	{ printf("Lines expr aritmetica: %f\n", $2->value); }
	| lines '\n'
	| /* empty */
	;

bexpr	: bexpr OR bexpr	{ $$ = mknodeB("OR", $1, $3); 
					printf("%s = %s || %s\n", $$->addr, $1->addr, $3->addr); }
	| bexpr AND bexpr	{ $$ = mknodeB("AND", $1, $3); 
					printf("%s = %s && %s\n", $$->addr, $1->addr, $3->addr); }
	| NOT bexpr		{ 	if ($2->boolean == 1){ $2->boolean = 0; } 
					else { $2->boolean = 1; }
					$$ = $2; 
					printf("%s = NOT %s\n", $$->addr, $2->addr); } //non so se devo creare un nuovo nodo?
	| '(' bexpr ')'		{ $$ = $2; }
	| comp			{ $$ = $1; }
	;

comp	: expr LT expr		{ $$ = mknodeB("LT", $1, $3); 
					printf("%s = %s < %s\n", $$->addr, $1->addr, $3->addr); }
	| expr LE expr		{ $$ = mknodeB("LE", $1, $3); 
					printf("%s = %s <= %s\n", $$->addr, $1->addr, $3->addr); }
	| expr GE expr		{ $$ = mknodeB("GE", $1, $3); 
					printf("%s = %s >= %s\n", $$->addr, $1->addr, $3->addr); }
	| expr GT expr		{ $$ = mknodeB("GT", $1, $3); 
					printf("%s = %s > %s\n", $$->addr, $1->addr, $3->addr); }
	| expr EQ expr		{ $$ = mknodeB("EQ", $1, $3); 
					printf("%s = %s == %s\n", $$->addr, $1->addr, $3->addr); }
	| '(' comp ')'		{ $$ = $2; }
	;

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

struct Node * mknodeB(char * tipo, struct Node * n1, struct Node * n2){ //boolean expression
	char * temp = next_var();
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	n->addr = temp;

	if(strcmp(tipo, "LT") == 0){
		n->boolean = n1->value < n2->value;
		//printf("Match LT");
	} else if(strcmp(tipo, "LE") == 0){
		n->boolean = n1->value <= n2->value;
	} else if(strcmp(tipo, "GT") == 0){
		n->boolean = n1->value > n2->value;
	} else if(strcmp(tipo, "GE") == 0){
		n->boolean = n1->value >= n2->value;
	} else if(strcmp(tipo, "EQ") == 0){
		n->boolean = n1->value == n2->value;
	} else if(strcmp(tipo, "OR") == 0){
		n->boolean = n1->boolean || n2->boolean;
	} else if(strcmp(tipo, "AND") == 0){
		n->boolean = n1->boolean && n2->boolean;
	} else {
		printf("Error match in mkNodeB");
	}
		
	return n;
}

char * next_var(){
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	snprintf(buffer, sizeof(buffer), "t%d", counter);
	counter++;
	return buffer;
}


