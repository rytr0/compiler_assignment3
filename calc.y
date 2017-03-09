%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

int stack_size = 100;
int reg[26] = {0};
int top = -1;
int stack[100];
int size = 0;
int answer = 0;

int checkreg(char);
void pop_reg(char);
void pop_acc(int);
void push_reg(char);
void push_acc(int);
void load_reg(char,char);
void load_acc(char);

void yyerror(const char* s);
%}

%union {
	int ival;
	float fval;
	char id;
}

%token<ival> T_INT
%token<fval> T_FLOAT
%token<ival> T_IDEN
%token<id> T_ACC
%token<id> T_PUSH T_POP T_LOAD T_SHOW T_TOP T_SIZE
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT
%token T_NEWLINE T_QUIT
%left T_AND T_OR T_NOT T_ASSIGN
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE T_MOD
%right T_EXP

%type<ival> expression
%type<fval> mixed_expression
%type<ival> register

%start calculation

%%

calculation: 
	   | calculation line
;

line: T_NEWLINE
    | mixed_expression T_NEWLINE { printf("\tResult: %f\n", $1);}
    | expression T_NEWLINE { printf("\tResult: %i\n", $1); }
    | register T_NEWLINE { printf( "\tResult: %i\n", $1);}
    | T_PUSH T_IDEN T_NEWLINE { push_reg(checkreg($2));}
    | T_PUSH T_ACC T_NEWLINE { push_acc(answer);}
    | T_POP T_IDEN T_NEWLINE{pop_reg($2);}
    | T_POP T_ACC T_NEWLINE{pop_acc(answer);}
    | T_LOAD T_IDEN T_IDEN T_NEWLINE{load_reg($2,$3);}
    | T_LOAD T_IDEN T_ACC T_NEWLINE{load_acc($2);}
    | T_QUIT T_NEWLINE { printf("bye!\n"); exit(0); }
;

mixed_expression: T_FLOAT                 		 { $$ = answer =$1; }
	  | mixed_expression T_PLUS mixed_expression	 { $$ = answer = $1 + $3; }
	  | mixed_expression T_MINUS mixed_expression	 { $$ = answer = $1 - $3; }
	  | mixed_expression T_MULTIPLY mixed_expression { $$ = answer = $1 * $3; }
	  | mixed_expression T_DIVIDE mixed_expression	 { $$ = answer = $1 / $3; }
	  | mixed_expression T_MOD mixed_expression	 { $$ = answer = fmod($1,$3); }
	  | mixed_expression T_EXP mixed_expression	 { $$ = answer = pow($1,$3); }
	  | T_LEFT mixed_expression T_RIGHT		 { $$ = answer = $2; }
	  | expression T_PLUS mixed_expression	 	 { $$ = answer = $1 + $3; }
	  | expression T_MINUS mixed_expression	 	 { $$ = answer = $1 - $3; }
	  | expression T_MULTIPLY mixed_expression 	 { $$ = answer = $1 * $3; }
	  | expression T_DIVIDE mixed_expression	 { $$ = answer = $1 / $3; }
	  | expression T_MOD mixed_expression	 { $$ = answer = fmod($1,$3); }
	  | expression T_EXP mixed_expression	 { $$ = answer = pow($1,$3); }
	  | mixed_expression T_PLUS expression	 	 { $$ = answer = $1 + $3; }
	  | mixed_expression T_MINUS expression	 	 { $$ = answer = $1 - $3; }
	  | mixed_expression T_MULTIPLY expression 	 { $$ = answer = $1 * $3; }
	  | mixed_expression T_DIVIDE expression	 { $$ = answer = $1 / $3; }
	  | mixed_expression T_MOD expression	 { $$ = answer = fmod($1,$3); }
	  | mixed_expression T_EXP expression	 { $$ = answer = pow($1,$3); }
	  | register T_PLUS mixed_expression	 	 { $$ = answer = checkreg($1) + $3; }
	  | register T_MINUS mixed_expression	 	 { $$ = answer = checkreg($1) - $3; }
	  | register T_MULTIPLY mixed_expression 	 { $$ = answer = checkreg($1) * $3; }
	  | register T_DIVIDE mixed_expression	 { $$ = answer = checkreg($1) / $3; }
	  | register T_MOD mixed_expression	 { $$ = answer = fmod(checkreg($1),$3); }
	  | register T_EXP mixed_expression	 { $$ = answer = pow(checkreg($1),$3); }
	  | mixed_expression T_PLUS register	 	 { $$ = answer = $1 + checkreg($3); }
	  | mixed_expression T_MINUS register 	 { $$ = answer = $1 - checkreg($3); }
	  | mixed_expression T_MULTIPLY register 	 { $$ = answer = $1 * checkreg($3); }
	  | mixed_expression T_DIVIDE register	 { $$ = answer = $1 / checkreg($3); }
	  | mixed_expression T_MOD register	 { $$ = answer = fmod($1,checkreg($3)); }
	  | mixed_expression T_EXP register	 { $$ = answer = pow($1,checkreg($3)); }
	  | expression T_DIVIDE register		 { $$ = answer = $1 / (float)$3; }
;

expression: T_INT				{ $$ = answer = $1; }
	  | T_ACC					{ $$ = answer;}
	  | T_TOP					{ $$ = stack[top];}
	  | T_SIZE					{ $$ = size;}
	  | expression T_PLUS expression	{ $$ = answer = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = answer = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = answer = $1 * $3; }
	  | expression T_DIVIDE expression	{ $$ = answer = $1 / $3; }
	  | expression T_MOD expression	{ $$ = answer = $1 % $3; }
	  | expression T_AND expression { $$ = answer = $1 & $3;}
	  | expression T_OR expression { $$ = answer = $1 | $3;}
	  | expression T_PLUS register	{ $$ = answer = $1 + checkreg($3); }
	  | expression T_MINUS register	{ $$ = answer = $1 - checkreg($3); }
	  | expression T_MULTIPLY register	{ $$ = answer = $1 * checkreg($3); }
	  | expression T_DIVIDE register	{ $$ = answer = $1 / checkreg($3); }
	  | expression T_MOD register	{ $$ = answer = $1 % checkreg($3); }
	  | expression T_AND register { $$ = answer = $1 & checkreg($3);}
	  | expression T_OR register { $$ = answer = $1 | checkreg($3);}
	  | register T_PLUS expression	{ $$ = answer = $1 + $3; }
	  | register T_MINUS expression	{ $$ = answer = $1 - $3; }
	  | register T_MULTIPLY expression	{ $$ = answer = $1 * $3; }
	  | register T_DIVIDE expression	{ $$ = answer = $1 / $3; }
	  | register T_MOD expression	{ $$ = answer = $1 % $3; }
	  | register T_AND expression { $$ = answer = $1 & $3;}
	  | register T_OR expression { $$ = answer = $1 | $3;}
	  | T_NOT expression { $$ = answer = !$2;}
	  | expression T_EXP expression { $$ = answer = pow($1,$3);}
	  | expression T_EXP register { $$ = answer = pow($1,checkreg($3));}
	  | register T_EXP expression { $$ = answer = pow(checkreg($1),$3);}
	  | T_LEFT expression T_RIGHT		{ $$ = answer = $2; }
;

register: T_IDEN					{$$ = answer  = checkreg($1);}	
		| register T_PLUS register		{$$ = answer = checkreg($1)+checkreg($3);}
		| register T_MINUS register		{$$ = answer = checkreg($1)-checkreg($3);}
		| register T_MULTIPLY register		{$$ = answer = checkreg($1)*checkreg($3);}
		| register T_DIVIDE register		{$$ = answer = checkreg($1)/checkreg($3);}
		| register T_MOD register		{$$ = answer = checkreg($1)% checkreg($3);}
		| register T_AND register		{$$ = answer = checkreg($1)&checkreg($3);}
		| register T_OR register		{$$ = answer = checkreg($1)|checkreg($3);}
		| T_NOT register				{$$ = answer = !checkreg($2);}
		| register T_EXP register      {$$ = answer = pow(checkreg($1),checkreg($3));}
		| T_LEFT register T_RIGHT		{$$ = answer = $2;}
		| T_SHOW T_ACC				{$$ = answer;}
		| T_SHOW T_TOP				{$$ = stack[top];}
		| T_SHOW T_SIZE				{$$ = size;}
%%

int main() {
	yyin = stdin;

	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
int checkreg(char c){
	return reg['Z'-c];
}
void push_reg(char c){
	if(top==stack_size-1){
		printf("stack full\n");
		return;
	}
	else{
		stack[++top] = reg['Z'-c];
		size++;
	}
}
void push_acc(int n){
	if(top==stack_size-1){
		printf("stack full\n");
		return;
	}
	else{
		stack[++top] = n;
		size++;
	}
}
void pop_reg(char c1){
	if(top==-1){
		printf("stack empty\n");
	}else{
		size--;
		reg['Z'-c1] = stack[top--];
	}
}
void pop_acc(int n){
	if(top==-1){
		printf("stack empty\n");
	}else{
		size--;
		answer = stack[top--];
	}
}
void load_reg(char c1,char c2){
	reg['Z'-c1] = reg['Z'-c2];
}
void load_acc(char c1){
	reg['Z'-c1] = answer;
}