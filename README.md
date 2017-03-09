# compiler_assignment3 @ KMITL

calc.l is flex file (token list seperator)
calc.y is bison file (grammar checker)

-flex
when you edit something in the code you have to run command
flex calc.l
for complie it then it will generate lex.yy.c automatically

-bison
when you edit something in the code you have to run command
bison -d calc.y
for complie it then it will generate calc.tab.c & calc.tab.h(not shown @ repo) automatically

when you want to run express evaluator(flex+bison) you have to run this command

-linux & windows
gcc lex.yy.c calc.tab.c [-o <FILE_NAME.exe>] -lm 
./FILE_NAME.exe or 
./a.out (if you didn't set -o option)

-mac
clang lex.yy.c calc.tab.c [-o <FILE_NAME.exe>] 
./FILE_NAME.exe or 
./a.out (if you didn't set -o option)
