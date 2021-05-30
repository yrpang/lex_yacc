all: sql

sql.tab.c sql.tab.h:	sql.y
	bison -t -v -d sql.y

lex.yy.c: sql.l sql.tab.h
	flex sql.l

sql: lex.yy.c sql.tab.c sql.tab.h
	gcc -o sql sql.tab.c lex.yy.c -ll -w

clean:
	rm sql sql.tab.c lex.yy.c sql.tab.h sql.output