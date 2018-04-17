# Compilatori

Dentro alla cartella DOC sono presenti le specifiche del linguaggio

#Compilazione ed esecuzione in ambiente linux:
- lex -o anayzer.yy.c anayzer.fl
- gcc anayzer anayzer.yy.c -lfl
- ./anayzer.out < file_prova

#Compilazione ed esecuzione in ambienti microsoft:
- so che bisogna linkare le librarie con -L "C:\MinGw\lib"... 

#Byson
bysonExample.y è un file di esempio che spiega come usare byson ...
si fa partire con:
- byson bysonExample.y
- gcc bysonExample.tab.c
- ./a.out


