#!/bin/bash
#Compile bison
bison -d -o compiler.c compiler.y -v

#Compile flex
flex -o scanner.c compiler.fl

#GCC
gcc -o compiler.out compiler.c scanner.c
