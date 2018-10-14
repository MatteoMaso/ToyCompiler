# Toy compiler

The purpose of this project is to learn the bisics of a compiler by implementing a compiler for a new programming language.
You can find the specific of the programming language into the doc folder. 

## How it works in an Linux environment:
- lex -o anayzer.yy.c analyzer.fl
- gcc anayzer anayzer.yy.c -lfl
- ./anayzer.out < your_code_file

