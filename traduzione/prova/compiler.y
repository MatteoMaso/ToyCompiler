%{
	#include <ctype.h>
	#include <stdio.h>
	#include <string.h>
	int yylex();
	void yyerror(char *s);
	char * next_var();
	int counter;
	struct Node * mkLeaf(double n1);
	struct Node* mkExpNode(char * tipo, struct Node * n1, struct Node * n2);
	struct Node * mknodeB(char * tipo, struct Node * n1, struct Node * n2);
	struct Node * mkVarNode(char * name, double value);
	struct Node * mknodeNotB(struct Node * n1);
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
	char * string;
}

%token	<val>	   FRACT
%token  <string>   ID

%type 	<node>	bexpr  expr comp var


%left	'+' '-'
%left	'*' '/'
%right  UMINUS
%left	OR
%left	AND
%right	NOT

%nonassoc NEQ EQ LT GT LE GE INT

%%
lines	: lines bexpr '\n'	{ printf("Boolean Expression: %s = %d\n", $2->addr, $2->boolean); }
	| lines expr '\n'	{ /*printf("Lines expr aritmetica: %f\n", $2->value); */}
	| lines '\n'		{ printf(""); }
//	| var '=' expr '\n'	{ printf("%s = %s;\n", $1->addr, $3->addr); }
	| /* empty */		{ }
//	| lines ';' '\n'	{ printf("");}
//	| INT var 		{ printf("int %s;\n", $2->addr ); }
	;

var 	:  ID			{ 					
				  $$ = mkVarNode($1, 0); 
				}
	;


bexpr	: bexpr OR bexpr	{ $$ = mknodeB("OR", $1, $3); 
					printf("%s = %s || %s;\n", $$->addr, $1->addr, $3->addr); }
	| bexpr AND bexpr	{ $$ = mknodeB("AND", $1, $3); 
					printf("%s = %s && %s;\n", $$->addr, $1->addr, $3->addr); }
	| NOT bexpr		{ 	if ($2->boolean == 1){ $2->boolean = 0; } 
					else { $2->boolean = 1; }
					$$ = mknodeNotB($2);
					printf("%s = NOT %s;\n", $$->addr, $2->addr); }
	| '(' bexpr ')'		{ $$ = $2; }
	| comp			{ $$ = $1; }
	;

comp	: expr LT expr		{ $$ = mknodeB("LT", $1, $3); 
					printf("%s = %s < %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr LE expr		{ $$ = mknodeB("LE", $1, $3); 
					printf("%s = %s <= %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr GE expr		{ $$ = mknodeB("GE", $1, $3); 
					printf("%s = %s >= %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr GT expr		{ $$ = mknodeB("GT", $1, $3); 
					printf("%s = %s > %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr EQ expr		{ $$ = mknodeB("EQ", $1, $3); 
					printf("%s = %s == %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr NEQ expr		{ $$ = mknodeB("NEQ", $1, $3); 
					printf("%s = %s != %s;\n", $$->addr, $1->addr, $3->addr); }
	| '(' comp ')'		{ $$ = $2; }

	;

expr	: expr '+' expr		{ $$ =  mkExpNode("+", $1, $3); 
					printf("%s = %s + %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr '-' expr		{ $$ =  mkExpNode("-", $1, $3); 
					printf("%s = %s - %s;\n", $$->addr, $1->addr, $3->addr); } 
	| expr '/' expr		{ $$ =  mkExpNode("/", $1, $3); 
					printf("%s = %s / %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr '*' expr		{ $$ = mkExpNode("*", $1, $3); 
					printf("%s = %s * %s;\n", $$->addr, $1->addr, $3->addr); }
	| '(' expr ')'		{ $$ = $2;
					 }
	| '-' expr %prec UMINUS { char * temp = next_var();
					struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
					n->addr = temp;
					n->value = -($2->value);
					$$ = n; 
					printf("%s = -%s\n", $$->addr, $2->addr); 
				}

	| FRACT			{ 	
					$$ = mkLeaf($1);
//					printf("%s = %f\n", $$->addr, $1 );
				}
	| var			{ printf("match var: %s\n", $1); }
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

struct Node * mkVarNode(char * name, double value){
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	n->addr = name;
	n->value = value;
	return n;
}

struct Node * mkLeaf(double n1){
//	char * temp = next_var();
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
//	n->addr = temp;
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	sprintf(buffer, "%.2f", n1);
	n->addr = buffer;
	n->value = n1;
	return n;

}


//function to create an expression node
struct Node * mkExpNode(char * tipo, struct Node * n1, struct Node * n2){
	
	char * temp = next_var();
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	n->addr = temp;
	if(strcmp(tipo, "+") == 0){
		n->value = (n1->value) + (n2->value);
		
	} else if(strcmp(tipo, "-") == 0){
		n->value = (n1->value) - (n2->value);
	} else if(strcmp(tipo, "*") == 0){
		n->value = (n1->value) * (n2->value);
	} else if(strcmp(tipo, "/") == 0){
		n->value = (n1->value) / (n2->value);
	}else {
		printf("Error match in mkExpNode");
	}
	return n;
}

struct Node * mknodeNotB(struct Node * n1){
	char * temp = next_var();
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	n->addr = temp;
	n->boolean = n1->value;
	return n;
}

struct Node * mknodeB(char * tipo, struct Node * n1, struct Node * n2){ 
	char * temp = next_var();
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	n->addr = temp;

	if(strcmp(tipo, "LT") == 0){
		n->boolean = n1->value < n2->value;
	} else if(strcmp(tipo, "LE") == 0){
		n->boolean = n1->value <= n2->value;
	} else if(strcmp(tipo, "GT") == 0){
		n->boolean = n1->value > n2->value;
	} else if(strcmp(tipo, "GE") == 0){
		n->boolean = n1->value >= n2->value;
	} else if(strcmp(tipo, "EQ") == 0){
		n->boolean = n1->value == n2->value;
	} else if(strcmp(tipo, "NEQ") == 0){
		n->boolean = n1->value != n2->value;
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



