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
	char * doubleToString(double n1);
	
        struct StatementNode * mkStat();
        struct StatementNode{
                char * next;
                //int assegnato;
        };

        struct BoolNode * mkBoolNode(char * temp);
        struct BoolNode{
		char * addr;
                char * t;
                char * f; 
        };

%}

%union {
        struct BoolNode * boolNode;
        struct StatementNode * sNode;
	double val;
	int bool; 	// 1 == true, 0 == false
	char * string;
}

%token	<val>	   DOUBLE
%token  <string>   ID
%token	IF ELSE WHILE PRINT 

%type   <string> var expr comp M1
%type   <boolNode> bexpr  while W1 W2
%type   <sNode> s s1 if_statement if_bool if_else M2 corpo


%left	'+' '-'
%left	'*' '/'
%right  UMINUS
%left	OR
%left	AND
%right	NOT

%nonassoc NEQ EQ LT GT LE GE

%%
prog	: s1                    { }
        | prog '\n'             { }
        | /*empty*/             { } 
        ;

s1      : s1 s                  { }
        | s                     { }
        ;

s       : var '=' expr ';'        { printf("%s = %s;\n", $1, $3); 		free($1); free($3);  }
        | DOUBLE var ';'          { printf("double %s;\n", $2);   		free($2);            }
	| DOUBLE var '=' expr ';' { printf("double %s = %s;\n", $2, $4); 	free($2), free($4);  }
        | if_statement            { printf("%s: ;\n", $1->next);  		free($1);            }
        | while  	          { }
	| printf ';'		  { }
        ;



while  	: WHILE W1 bexpr W2 corpo { printf("goto %s;\n%s: ;\n", $4->addr, $4->f); free($3); free($4); }
	;

W2	:			{ 
				  $$=$<boolNode>-1; $$->t = next_label(); $$->f = next_label(); 
				  printf("if( %s == 1 ) goto %s;\ngoto %s;\n%s: ;\n", $<boolNode>0->addr, $$->t, $$->f, $$->t);  
				}
	;

W1	: 			{ $$ = mkBoolNode(next_label()); printf("%s: ;\n", $$->addr); }
	;


if_statement : if_else  	{ $$ = $1; }
             | if_bool  	{ $$ = $1; } 
             ;

if_else : if_bool M2 corpo { $$ = $2; free($1); }  
        ;

M2	: ELSE			{ $$ = mkStat(); $$->next = next_label(); printf("goto %s;\n", $$->next); printf("%s: ;\n", $<sNode>0->next); } 
	;

if_bool : IF '(' bexpr ')' M1  corpo  { $$ = mkStat(); $$->next = $3->f; } //bisognerebbe mettere il free sul bexpr ma nn si può perchè $3->f
        ;

M1	: 			{  printf("if ( %s == 1 ) goto %s;\ngoto %s;\n", $<boolNode>-1->addr, $<boolNode>-1->t, $<boolNode>-1->f); 					   printf("%s: ;\n", $<boolNode>-1->t);
				} 
	;

corpo   : '{' s1 '}'            { }   
        | '{'    '}'            { }    
        ;

bexpr	: bexpr OR  bexpr 	{ $$ = mkBoolNode(next_boolVar()); $$->t = $1->t, $$->f = $1->f;
					printf("%s = %s || %s;\n", $$->addr, $1->addr, $3->addr);  }
	| bexpr AND bexpr	{ $$ = mkBoolNode(next_boolVar()); $$->t = $1->t, $$->f = $1->f;
					printf("%s = %s && %s;\n", $$->addr, $1->addr, $3->addr);  }
	| NOT bexpr		{ $$ = mkBoolNode(next_boolVar()); $$->t = $2->t, $$->f = $2->f; 
					printf("%s = !%s;\n", $$->addr, $2->addr); }
	| '(' bexpr ')'		{ $$ = $2; }
	| comp			{ $$ = mkBoolNode($1); $$->t = next_label(), $$->f = next_label(); }
	;

comp	: expr LT  expr		{ $$ = next_boolVar(); printf("%s = %s < %s;\n",  $$, $1, $3); free($1);  free($3); }
	| expr LE  expr		{ $$ = next_boolVar(); printf("%s = %s <= %s;\n", $$, $1, $3); free($1);  free($3); }
	| expr GE  expr		{ $$ = next_boolVar(); printf("%s = %s >= %s;\n", $$, $1, $3); free($1);  free($3); }
	| expr GT  expr		{ $$ = next_boolVar(); printf("%s = %s > %s;\n",  $$, $1, $3); free($1);  free($3); }
	| expr EQ  expr		{ $$ = next_boolVar(); printf("%s = %s == %s;\n", $$, $1, $3); free($1);  free($3); }
	| expr NEQ expr		{ $$ = next_boolVar(); printf("%s = %s != %s;\n", $$, $1, $3); free($1);  free($3); }
	;

expr	: expr '+' expr		{ $$ = next_doubleVar(); printf("%s = %s + %s;\n", $$, $1, $3); free($1);  free($3); }
	| expr '-' expr		{ $$ = next_doubleVar(); printf("%s = %s - %s;\n", $$, $1, $3); free($1);  free($3); }
	| expr '/' expr		{ $$ = next_doubleVar(); printf("%s = %s / %s;\n", $$, $1, $3); free($1);  free($3); }
	| expr '*' expr		{ $$ = next_doubleVar(); printf("%s = %s * %s;\n", $$, $1, $3); free($1);  free($3); }
	| '(' expr ')'		{ $$ = $2; }
	| '-' expr %prec UMINUS { $$ = next_doubleVar(); printf("%s = -%s;\n", $$, $2); free($2); }
	| DOUBLE		{ $$ = doubleToString($1); }
	| var			{ $$ = $1; }
	;

var 	:  ID			{ $$ = $1; }
	;

printf  : PRINT '(' var ')'	{ printf("printf(\"var: %s = %sf \\n\", %s);\n", $3, "%", $3); free($3); }
	;

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


char * doubleToString(double n1){
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	sprintf(buffer, "%.2f", n1);
	return buffer;
}

//todo comment
struct StatementNode * mkStat(){
        
	struct StatementNode * n = (struct StatementNode * ) malloc(sizeof(struct StatementNode) * 1);
        return n;
}

//todo add comment
struct BoolNode * mkBoolNode(char * temp){

        struct BoolNode * n = (struct BoolNode * ) malloc(sizeof(struct BoolNode) * 1);
        n->addr = temp;      
        return n;
}

/*
 *	This function initialize a new boolean temporary variable
 */
char * next_boolVar(){
	char *  temp = next_var();
	printf("bool %s;\n", temp);
	return temp;
}

/*
 *	This function initialize a new double temporary variable
 */
char * next_doubleVar(){
	char *  temp = next_var();
	printf("double %s;\n", temp);
	return temp;
}

/*
 *	This function return a new temporary variable string in the form "ti" with i an incremental integer number
 *	Only for internal use!
 */
char * next_var(){
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	snprintf(buffer, sizeof(buffer), "t%d", counter_t);
	counter_t++;
	return buffer;
}

/*
 *	This function return a new label string in the form "Li" with i an incremental integer number
 */
char * next_label(){
	char *  buffer = (char * ) malloc(sizeof(char) * 100);
	snprintf(buffer, sizeof(buffer), "L%d", counter_l);
	counter_l++;
	return buffer;
}



