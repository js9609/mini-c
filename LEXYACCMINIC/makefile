minic : yminic.tab.c lex.yy.c
	gcc -o minic yminic.tab.c lex.yy.c -ly -lfl

yminic.tab.c : yminic.y
	bison -d yminic.y

lex.yy.c : minic.l
	flex minic.l

