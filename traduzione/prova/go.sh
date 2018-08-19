#!/bin/bash
#Compile bison
bison -d -o compiler.c compiler.y

#Compile flex
flex -o scanner.c compiler.fl

#GCC
gcc -o compiler compiler.c scanner.c
