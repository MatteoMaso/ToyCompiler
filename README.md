# Toy compiler

The purpose of this project is to learn the bisics of a compiler by implementing a compiler for a new programming language.
You can find the specific of the programming language into the doc folder. 
Also, our compiler is able to convert our code into a C code.

## How it works in an Linux environment:
'go.sh' is a useful script to compile the code for produce the compiler
### Script to produce our compiler 
- ./go.sh
### Use our compiler to convert a piece of code in our programming language to a C code
- ./compiler < prog_our_language > prog_c_language.c
### Compile the C code produced with our compiler
gcc -o our_executable_prog  prog_c_language.c
### Execute the produced software
./our_executable_prog

