Non completo, sistemare la grammatica
Per ora esegue solo operazioni logiche come output

per eseguirlo:

bison -d -o interprete.c interprete.y
flex -o scanner.c interprete.fl
gcc -o interprete interprete.c scanner.c
./parser < input_example.txt


