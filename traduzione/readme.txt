Per eseguirlo:

LINUX
bison -d -o compiler.c compiler.y
flex -o scanner.c compiler.fl
gcc -o compiler compiler.c scanner.c
./compiler < input_example.txt

WINDOWS
bison -d -o compiler.c compiler.y
flex compiler.fl
gcc compiler.c lex.yy.c
a < input_example.txt



