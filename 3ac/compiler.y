%{
	#include <ctype.h> 
	#include <stdio.h>
	#include <string.h>
	int yylex();
	void yyerror(char *s);
	char * next_var();
	char * next_doubleVar();
	char * next_boolVar();        
	char * next_label();
	int counter_t;
        int counter_l;
	struct Node * mkLeaf(double n1);
	struct Node * mkExpNode(char * tipo, struct Node * n1, struct Node * n2);
	struct Node * mknodeB(char * tipo, struct Node * n1, struct Node * n2);
	struct Node * mkVarNode(char * name, double value);
	struct Node * mknodeNotB(struct Node * n1);
	
	struct Node{
		char * addr;
		double value;
		int boolean;

	};

        struct StatementNode * mkStatement(char * next);
        struct StatementNode * mkStat();
        struct StatementNode{
                char * next;
                int assegnato;
        };

        struct BoolNode * mkBoolNode(char * temp, char * t, char * f);
        struct BoolNode{
		char * addr;
                char * t;
                char * f; 
        };

        struct WhileNode * mkWhileNode();
        struct WhileNode{
                char * begin;
                char * t; 
                char * f;
        };

%}

%union {
	struct Node * node;
        struct BoolNode * boolNode;
        struct StatementNode * sNode;
        struct WhileNode * wNode;
	double val;
	int bool; 	// 1 == true, 0 == false
	char * string;
}

%token	<val>	   DOUBLE
%token  <string>   ID
%token	IF ELSE WHILE PRINT

%type 	<node>	 expr comp var
%type   <boolNode> bexpr
%type   <sNode> s s1 if_statement if_bool if_else
%type   <wNode>  whileB while

%left	'+' '-'
%left	'*' '/'
%right  UMINUS
%left	OR
%left	AND
%right	NOT

%nonassoc NEQ EQ LT GT LE GE 

%%
prog	: s1                       { /*printf("fine\n");*/}
        | prog '\n'                { printf("match empty prog e n \n"); }
        | /*empty*/                { printf("match empty program\n"); } 
        | while
        ;

s1      : s1 s                     { /*$$ = mkStatement($2->next);*/ }
        | s                        { /*$$ = $1;*/ }
        ;

s       : var '=' expr ';'             { $$ = mkStat(); printf("%s = %s;\n", $1->addr, $3->addr); }
        | DOUBLE var ';'               { $$ = mkStat(); printf("double %s;\n", $2->addr ); }
        | if_statement                 { $$ = $1; printf("%s: ;\n", $1->next); }
        | whileB corpo                 { $$ = mkStat(); printf("goto %s;\n%s:\n", $1->begin, $1->f); }
	| printf ';'		       { $$ = mkStat(); }
        ;

while   : WHILE         { $$ = mkWhileNode(); $$->begin = next_label(); printf("%s: ;\n", $$->begin); }
        ;

whileB  : while bexpr   { $$=$1; $$->t = next_label(); $$->f = next_label(); printf("if( %s == 1 ) goto %s;\ngoto %s;\n%s: ;\n", $2->addr, $$->t, $$->f, $$->t); }


if_statement : if_else corpo { $$ = $1; }
             | if_bool  { $$ = $1; } 
             ;

if_else : if_bool ELSE          { $$ = mkStatement(next_label()); printf("goto %s;\n", $$->next); printf("%s: ;\n", $1->next); } 
               
        ;

if_bool  : IF '(' bexpr ')'     { printf("if ( %s == 1 ) goto %s;\ngoto: %s;\n", $3->addr, $3->t, $3->f); printf("%s: ;\n", $3->t); } 
                corpo           { $$ = mkStatement($3->f); }
        ;

corpo   : '{' s1 '}'                //{ $$ = mkStatement($3->f); printf("%s: ;\n", $$->next);}
        | '{'    '}'                //{ $$ = mkStatement($3->f); printf("%s: ;\n", $$->next);} //regola per matchare l'if con stato vuoto
        ;

var 	:  ID			 { 
				     $$ = mkVarNode($1, 0); 
				 }
	;

bexpr	: bexpr OR comp 	{ $$ = mkBoolNode(next_boolVar(), $1->t, $1->f);
					printf("%s = %s || %s;\n", $$->addr, $1->addr, $3->addr); }
	| bexpr AND comp	{ $$ = mkBoolNode(next_boolVar(), $1->t, $1->f);
					printf("%s = %s && %s;\n", $$->addr, $1->addr, $3->addr); }
	| NOT bexpr		{       $$ = mkBoolNode(next_boolVar(), $2->t, $2->f);
					printf("%s = NOT %s;\n", $$->addr, $2->addr); }
	| '(' bexpr ')'		{ $$ = $2; }
	| comp			{ 
                                        //$$ = $1; 
                                        $$ = mkBoolNode($1->addr, next_label(), next_label());
                                }
	;

printf  : PRINT '(' var ')'	{ printf("printf(\"var: %s = %f\");", $3->addr, $3->value); }
	;

//todo bisogna modificare mknodeB semplicemente creando una nuova variabile temporanea ma nn serve salvare tutte le operazioni
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
	;

expr	: expr '+' expr		{ $$ =  mkExpNode("+", $1, $3); 
					printf("%s = %s + %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr '-' expr		{ $$ =  mkExpNode("-", $1, $3); 
					printf("%s = %s - %s;\n", $$->addr, $1->addr, $3->addr); } 
	| expr '/' expr		{ $$ =  mkExpNode("/", $1, $3); 
					printf("%s = %s / %s;\n", $$->addr, $1->addr, $3->addr); }
	| expr '*' expr		{ $$ = mkExpNode("*", $1, $3); 
					printf("%s = %s * %s;\n", $$->addr, $1->addr, $3->addr); }
	| '(' expr ')'		{ $$ = $2; }
	| '-' expr %prec UMINUS { char * temp = next_doubleVar();
					struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
					n->addr = temp;
					n->value = -($2->value);
					$$ = n; 
					printf("%s = -%s\n", $$->addr, $2->addr); 
				}

	| DOUBLE		{ 	
					$$ = mkLeaf($1);
					//printf("%s = %f\n", $$->addr, $1 );
				}
	| var			{ $$ = $1; }
	;

//todo add printf instruction .. prevedere un'istruzione di print



%%

int main() {
	
	counter_t = 0;  //temp variable
	counter_l = 0;  //label

	printf("#include <stdio.h>\n#include <stdbool.h>\n\nint main() {\n\n");
	
	if (yyparse() != 0)
		fprintf(stderr, "Abnormal exit\n");

	printf("\n\n}\n");	

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
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	sprintf(buffer, "%.2f", n1);
	n->addr = buffer;
	n->value = n1;
	return n;

}

//todo comment
struct StatementNode * mkStatement(char * next){
        struct StatementNode * n = (struct StatementNode * ) malloc(sizeof(struct StatementNode) * 1);
        n->next = next;    
        n->assegnato = 1;    
        return n;
}

//todo comment
struct StatementNode * mkStat(){
        struct StatementNode * n = (struct StatementNode * ) malloc(sizeof(struct StatementNode) * 1);
        n->assegnato = 0;    
        return n;
}


//todo add comment
struct BoolNode * mkBoolNode(char * temp, char * t, char * f){

        struct BoolNode * n = (struct BoolNode * ) malloc(sizeof(struct BoolNode) * 1);
        n->addr = temp;        
        n->t = t;
        n->f = f;

        return n;
}

struct WhileNode * mkWhileNode(){

        struct WhileNode * n = (struct WhileNode * ) malloc(sizeof(struct WhileNode) * 1);
                
        return n;
}

//function to create an expression node
struct Node * mkExpNode(char * tipo, struct Node * n1, struct Node * n2){
	
	char * temp = next_doubleVar();
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
	} else {
		printf("Error match in mkExpNode");
	}
	return n;
}

struct Node * mknodeNotB(struct Node * n1){
	char * temp = next_boolVar();
	struct Node * n = (struct Node * ) malloc(sizeof(struct Node) * 1);
	n->addr = temp;
	n->boolean = n1->value;
	return n;
}

struct Node * mknodeB(char * tipo, struct Node * n1, struct Node * n2){ 
	char * temp = next_boolVar();
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

char * next_boolVar(){
	char *  temp = next_var();
	printf("bool %s;\n", temp);
	return temp;
}

char * next_doubleVar(){
	char *  temp = next_var();
	printf("double %s;\n", temp);
	return temp;
}

char * next_var(){
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	snprintf(buffer, sizeof(buffer), "t%d", counter_t);
	counter_t++;
	return buffer;
}

char * next_label(){
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	snprintf(buffer, sizeof(buffer), "L%d", counter_l);
	counter_l++;
	return buffer;
}



