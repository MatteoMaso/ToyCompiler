%option noyywrap
%{
#include "example.tab.h"
extern YYSTYPE yylval;
%}
number [0-9]+\.?|[0-9]*\.[0-9]+

%%

[ \t]		{ /* skip blanks */ }
{number}	{ sscanf(yytext, "%lf", &yylval); return NUMBER; }
\n|.		{ return yytext[0]; }

