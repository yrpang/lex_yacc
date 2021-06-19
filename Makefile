all: sql

sql.tab.c sql.tab.h:	sql.y
	bison -t -v -d sql.y

lex.yy.c: sql.l sql.tab.h
	flex sql.l

sql: lex.yy.c sql.tab.c sql.tab.h sql.cpp
	g++ -o sql sql.tab.c lex.yy.c sql.cpp -ll -w -I/usr/local/Cellar/boost/1.76.0/include -L/usr/local/Cellar/boost/1.76.0/lib -lboost_serialization

clean:
	rm sql sql.tab.c lex.yy.c sql.tab.h sql.output