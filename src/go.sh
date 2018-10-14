#!/bin/bash
#Compile bison
bison -d -o tmp1.c compiler.y -v

#Compile flex
flex -o tmp2.c compiler.fl

#GCC
gcc -o compiler tmp1.c tmp2.c
