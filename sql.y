%{
#include <ctype.h>
#include <cstdio>
#include <string>
#include "sql.h"
#include "sql.tab.h"
using namespace std;
extern int yylex(void);
int yyerror(char * msg);
%}

%union
{
	/* ID */
	struct values value;

	/* createtable */
	struct colname* colname;
	struct coltype* coltype;
	struct cols* cols;
	struct createsql* createsql;

	struct fields* fields;
	struct selectsql* selectsql;
	struct tablenames* tablenames;
}

%token EXIT
%token CREATE TABLE DATABASE USE SELECT INSERT DELETE UPDATE FROM WHERE INTO VALUES SET DROP
%token INT DOUBLE CHAR
%token<value> INTNUM FLOATNUM STRING ID 
%token ',' ';' '(' ')' '.'
%token '='
%token '<' '>'
%left OR
%left AND
%left '+' '-'
%left '*' '/' '%'
%left '!'

%type<value> dbname colname tablename
%type<coltype> coltype
%type<cols> cols col
%type<createsql> createsql

%type<fields> fields_star table_field table_fields
%type<tablenames> tablenames
%type<selectsql> selectsql


%%

statements:	statement {return 0;}
			|statements statement {return 0;}
			;

statement:	createsql {createtable($1)}
			|selectsql {select($1)}
			|insertsql {printf("INSERT\n")}
			|deletesql {printf("DELETE\n")}
			|updatesql {printf("UPDATE\n")}
			|createdb 
			|usedb
			|droptable
			|dropdb
			|exit {closedb();}
			;

droptable:	DROP TABLE tablename ';' {droptable($3.name)};
dropdb:		DROP DATABASE dbname ';' {dropdb($3.name)};

createdb:	CREATE DATABASE dbname ';' {createdb($3.name)};
usedb:		USE DATABASE dbname ';' {usedb($3.name)};
dbname:		ID
			{
				$$.length = $1.length;
				$$.name = (char *)malloc($1.length);
				strlcpy($$.name, $1.name, sizeof($$.name));
			};


createsql:	CREATE TABLE tablename '(' cols ')' ';'
			{
				$$=new struct createsql;
				$$->tablename = (char *)malloc($3.length);
				strlcpy($$->tablename, $3.name, sizeof($$->tablename));
				$$->cols = $5;
			};
tablename:	ID
			{
				$$.length = $1.length;
				$$.name = (char *)malloc($1.length);
				strlcpy($$.name, $1.name, sizeof($$.name));
			};
cols:		cols ',' col
			{
				$$=$1;
				while($1->next!=NULL)
				{
					$1 = $1->next;
				}
				$1->next = $3;
			}
			|col
			{
				$$=$1;
			};
col:		colname coltype
			{
				$$=new struct cols;
				$$->colname=(char*)malloc($1.length);
				strlcpy($$->colname, $1.name, sizeof($$->colname));
				$$->coltype = $2->type;
				$$->length = $2->length;
				$$->next = NULL;
			};
colname:	ID
			{
				$$.length = $1.length;
				$$.name = (char *)malloc($1.length);
				strlcpy($$.name, $1.name, sizeof($$.name));
			};
coltype:	INT
			{
				$$=new struct coltype; 
				$$->type = 1;
				$$->length = 4;
			}
			|DOUBLE
			{
				$$=new struct coltype;
				$$->type = 2;
				$$->length = 8;
			}
			|CHAR '(' INTNUM ')'
			{
				$$=new struct coltype;
				$$->type = 3;
				$$->length = $3.intnum;
			}
			;


selectsql:	SELECT fields_star FROM tablenames ';'
			{
				$$=new struct selectsql;
				$$->fields = $2;
				$$->tablenames = $4;
			}
			|SELECT fields_star FROM tablenames WHERE conditions ';'
			{
				$$=new struct selectsql;
			}
			;
fields_star: table_fields
			{
				$$=$1;
			}
			|'*'
			{
				$$=new struct fields;
				$$->ifall=true;
				$$->next=NULL;
			}
			;
table_fields: table_field
			{
				$$=$1
			}
			|table_fields ',' table_field
			{
				$$=$1;
				while($1->next!=NULL)
				{
					$1 = $1->next;
				}
				$1->next = $3;
			}
			;
table_field: colname
			{
				$$=new struct fields;
				$$->tablename = NULL;
				$$->colname = (char*)malloc($1.length);
				strlcpy($$->colname, $1.name, sizeof($$->colname));
				$$->ifall=false;
				$$->next=NULL;
			}
			|tablename '.' colname
			{
				$$=new struct fields;
				$$->tablename = (char*)malloc($1.length);
				strlcpy($$->tablename, $1.name, sizeof($$->tablename));
				$$->colname = (char*)malloc($3.length);
				strlcpy($$->colname, $3.name, sizeof($$->colname));
				$$->ifall=false;
				$$->next=NULL;
			}
			;
tablenames:	tablename
			{
				$$=new struct tablenames;
				$$->tablename = (char*)malloc($1.length);
				strlcpy($$->tablename, $1.name, sizeof($$->tablename));
				$$->next=NULL;
			}
			| tablenames ',' tablename
			;

conditions:	condition
			|'(' conditions ')'
			|conditions AND conditions
			|conditions OR conditions
			;
condition:	comp_left comp_op comp_right;
comp_left:	table_field|INTNUM|FLOATNUM;
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
		{
			
		}
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

