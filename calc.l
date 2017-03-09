%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "calc.tab.h"

%}

%%

[ \t]	; // ignore all whitespace
[0-9]+\.[0-9]+ 	{yylval.fval = atof(yytext); return T_FLOAT;}
[0-9]+		{yylval.ival = atoi(yytext); return T_INT;}
[a-f0-9]+"h" {yylval.ival = strtol(yytext, 0, 16); return T_INT;}
"$r"+[A-Z]   {yylval.id = yytext[2]; return T_IDEN;}
"$acc"  {return T_ACC;}
"$top"	{return T_TOP;}
"$size" {return T_SIZE;}
"push"  {return T_PUSH;}
"pop"	{return T_POP;}
"show"	{return T_SHOW;}
"load"	{return T_LOAD;}
\n		{return T_NEWLINE;}
"="		{return T_ASSIGN;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
"^"     {return T_EXP;}
"%"     {return T_MOD;}
"and"    {return T_AND;}
"or"     {return T_OR;}
"!"      {return T_NOT;}
"exit"		{return T_QUIT;}
"quit"		{return T_QUIT;}

%%
