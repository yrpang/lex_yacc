%{
#include <ctype.h>
#include <stdio.h>
#include "sql.tab.h"
extern int yylex(void);
int yyerror(char * msg);
%}

%token EXIT
%token CREATE TABLE DATABASE USE SELECT INSERT DELETE UPDATE FROM WHERE INTO VALUES SET 
%token INT DOUBLE CHAR
%token INTNUM FLOATNUM STRING ID 
%token ',' ';' '(' ')' '.'
%token '='
%token '<' '>'
%left OR
%left AND
%left '+' '-'
%left '*' '/' '%'
%left '!'

%%

statements:	statement {return 0;}
			|statements statement {return 0;}
			;

statement:	createsql {printf("CREATE TABLE\n")}
			|selectsql {printf("SELECT\n")}
			|insertsql {printf("INSERT\n")}
			|deletesql {printf("DELETE\n")}
			|updatesql {printf("UPDATE\n")}
			|createdb {printf("CREATE DB\n")}
			|usedb {printf("USE DB\n")}
			|exit {return 0;}
			;

createdb:	CREATE DATABASE dbname ';';
usedb:		USE DATABASE dbname ';';
dbname:		ID;


createsql:	CREATE TABLE tablename '(' cols ')' ';';
tablename:	ID;
cols:		cols ',' col
			|col;
col:		colname coltype;
colname:	ID;
coltype:	INT
			|DOUBLE
			|CHAR '(' INTNUM ')'
			;


selectsql:	SELECT fields_star FROM tablenames ';'
			|SELECT fields_star FROM tablenames WHERE conditions ';'
			;
fields_star: table_fields
			|'*'
			;
table_fields: table_field 
			|table_fields ',' table_field
			;
table_field: colname
			|tablename '.' colname
			;
tablenames:	tablename
			| tablenames ',' tablename
			;

conditions:	condition
			|'(' conditions ')'
			|conditions AND conditions
			|conditions OR conditions
			;
condition:	comp_left comp_op comp_right;
comp_left:	table_field;
comp_right:	table_field|INTNUM|FLOATNUM;
comp_op:	'<'|'>'|'<' '='|'>' '='|'!' '='|'=';


insertsql:	INSERT INTO tablename insertcolname VALUES '(' values ')' ';'
			|INSERT INTO tablename VALUES '(' values ')' ';'
			;
insertcolname:	'(' fields_star ')';
values:	values ',' value
		|value
		;
value:	STRING
		|cal
		;
cal:	cal '+' cal
		|cal '-' cal
		|cal '*' cal
		|cal '/' cal
		|'-' cal
		|'(' cal ')'
		|INTNUM
		|FLOATNUM
		;


updatesql:	UPDATE tablename SET setconfs WHERE conditions ';'
			|UPDATE tablename SET setconfs ';'
			;
setconfs:	setconf
			|setconfs ',' setconf
			;
setconf:	table_field '=' value;


deletesql:	DELETE FROM tablename WHERE conditions ';'
			|DELETE FROM tablename ';'
			;

exit:	EXIT ';';

%%
int main(void)
{
	while(1)
	{
		yyparse();
	}
	return 0;
}

int yyerror(char * msg)
{
	printf("%s is error in line\n", msg);
	return 1;
}

