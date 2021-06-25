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
	struct type* type;
	struct colstruct* colstruct;
	struct createstate* createstate;

	/* select */
	struct fields* fields;
	struct tablenames* tablenames;
	struct selectstate* selectstate;

	struct calvalue* calvalue;
	struct dataformat* dataformat;
	struct insertstate* insertstate;

	/* condition */
	struct condition_field* condfield;
	struct conditions* condition;
	int comp_op;
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
%type<type> type
%type<colstruct> columns onecol
%type<createstate> createstate

%type<fields> fields_star table_field table_fields
%type<tablenames> tablenames
%type<selectstate> selectstate

%type<calvalue> cal 
%type<dataformat> value values
%type<insertstate> insertstate

%type<condfield> comp_left comp_right
%type<condition> conditions condition
%type<comp_op> comp_op
%%

statements:	statement {return 0;}
			|statements statement {return 0;}
			;

statement:	createdb 
			|createstate {createtable($1)}
			|selectstate {select($1)}
			|insertstate {insert($1)}
			|deletestate {printf("DELETE\n")}
			|updatestate {printf("UPDATE\n")}
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
				strlcpy($$.name, $1.name, $1.length);
			};


createstate:	CREATE TABLE tablename '(' columns ')' ';'
			{
				$$=new struct createstate;
				$$->tablename = (char *)malloc($3.length);
				strlcpy($$->tablename, $3.name, $3.length);
				$$->cols = $5;
			};
tablename:	ID
			{
				$$.length = $1.length;
				$$.name = (char *)malloc($1.length);
				strlcpy($$.name, $1.name, $1.length);
			};
columns:		columns ',' onecol
			{
				$$=$1;
				while($1->next!=NULL)
				{
					$1 = $1->next;
				}
				$1->next = $3;
			}
			|onecol
			{
				$$=$1;
			};
onecol:		colname type
			{
				$$=new struct colstruct;
				$$->colname=(char*)malloc($1.length);
				strlcpy($$->colname, $1.name, $1.length);
				$$->type = $2->type;
				$$->length = $2->length;
				$$->next = NULL;
			};
colname:	ID
			{
				$$.length = $1.length;
				$$.name = (char *)malloc($1.length);
				strlcpy($$.name, $1.name, $1.length);
			};
type:	INT
			{
				$$=new struct type; 
				$$->type = 1;
				$$->length = 4;
			}
			|DOUBLE
			{
				$$=new struct type;
				$$->type = 2;
				$$->length = 8;
			}
			|CHAR '(' INTNUM ')'
			{
				$$=new struct type;
				$$->type = 3;
				$$->length = $3.intnum;
			}
			;


selectstate: SELECT fields_star FROM tablenames ';'
			{
				$$=new struct selectstate;
				$$->fields = $2;
				$$->tablenames = $4;
			}
			|SELECT fields_star FROM tablenames WHERE conditions ';'
			{
				$$=new struct selectstate;
				$$->fields = $2;
				$$->tablenames = $4;
				$$->conds = $6;
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
				strlcpy($$->colname, $1.name, $1.length);
				$$->ifall=false;
				$$->next=NULL;
			}
			|tablename '.' colname
			{
				$$=new struct fields;
				$$->tablename = (char*)malloc($1.length);
				strlcpy($$->tablename, $1.name, $1.length);
				$$->colname = (char*)malloc($3.length);
				strlcpy($$->colname, $3.name, $3.length);
				$$->ifall=false;
				$$->next=NULL;
			}
			;
tablenames:	tablename
			{
				$$=new struct tablenames;
				$$->tablename = (char*)malloc($1.length);
				strlcpy($$->tablename, $1.name, $1.length);
				$$->next=NULL;
			}
			| tablenames ',' tablename
			;

conditions:	condition
			{
				$$ = $1;
			}
			|'(' conditions ')'
			{
				$$ = $2;
			}
			|conditions AND conditions
			{
				$$ = new struct conditions;
				$$->node_type = 2;
				$$->virtualtype = 1;
				$$->left = $1;
				$$->right = $3;
			}
			|conditions OR conditions
			{
				$$ = new struct conditions;
				$$->node_type = 2;
				$$->virtualtype = 2;
				$$->left = $1;
				$$->right = $3;
			}
			;
condition:	comp_left comp_op comp_right
			{
				$$ = new struct conditions;
				$$->node_type = 1;
				$$->con_type = $2;
				$$->con_left = $1;
				$$->con_right = $3;
				// $$->left=NULL;
				// $$->right=NULL;
			};
comp_left:	table_field
			{
				$$ = new struct condition_field;
				$$->type = 1;
				$$->field = $1;
			}
			|INTNUM
			{
				$$ = new struct condition_field;
				$$->type = 2;
				$$->intnum = $1.intnum;
			}
			|FLOATNUM
			{
				$$ = new struct condition_field;
				$$->type = 3;
				$$->doublenum = $1.doublenum;
			};
comp_right:	table_field
			{
				$$ = new struct condition_field;
				$$->type = 1;
				$$->field = $1;
			}
			|INTNUM
			{
				$$ = new struct condition_field;
				$$->type = 2;
				$$->intnum = $1.intnum;
			}
			|FLOATNUM
			{
				$$ = new struct condition_field;
				$$->type = 3;
				$$->doublenum = $1.doublenum;
			}
			;
comp_op:	'<'{$$=1;} |'>'{$$=2;}|'<' '='{$$=3;}|'>' '='{$$=4;}|'!' '='{$$=5;}|'='{$$=6;};


insertstate: INSERT INTO tablename insertcolname VALUES '(' values ')' ';'
			{
				$$=new struct insertstate;
			}
			|INSERT INTO tablename VALUES '(' values ')' ';'
			{
				$$ = new struct insertstate;
				$$->tablename = (char*)malloc($3.length);
				strlcpy($$->tablename, $3.name, $3.length);
				$$->colnames = NULL;
				$$->datas = $6;
			}
			;
insertcolname:	'(' fields_star ')';
values:	values ',' value 
		{
			$$ = $1;
			while($1->next!=NULL) $1 = $1->next; 
			$1->next = $3;
		}
		|value{$$=$1}
		;
value:	STRING
		{
			$$=new struct dataformat;
			$$->data = (char*) malloc($1.length);
			strlcpy($$->data, $1.name, $1.length);
			$$->length = $1.length-2; //去掉两个引号
			$$->type=3;
			$$->next = NULL;
		}
		|cal
		{
			$$ = new struct dataformat;
			calculate($1);
			if($1->valuetype == 1) 
			{
				$$->data = (char *)malloc(4);
				string str = std::to_string($1->intnum);
				strlcpy($$->data, str.c_str(), sizeof($$->data));
				$$->length = 4;
				$$->type = 1;
				$$->next = NULL; 
			}
			if($1->valuetype == 2)
			{
				$$->data = (char *)malloc(8);
				string str = std::to_string($1->doublenum);
				strlcpy($$->data, str.c_str(), sizeof($$->data));
				$$->length = 8;
				$$->type = 2;
				$$->next = NULL; 
			}
		}
		;
cal:	cal '+' cal
		{
			$$ = new struct calvalue;
			$$->valuetype = 3;
			$$->caltype = 1;
			$$->leftcal = $1;
			$$->rightcal = $3;
		}
		|cal '-' cal
		{
			$$ = new struct calvalue;
			$$->valuetype = 3;
			$$->caltype = 2;
			$$->leftcal = $1;
			$$->rightcal = $3;
		}
		|cal '*' cal
		{
			$$ = new struct calvalue;
			$$->valuetype = 3;
			$$->caltype = 3;
			$$->leftcal = $1;
			$$->rightcal = $3;
		}
		|cal '/' cal
		{
			$$ = new struct calvalue;
			$$->valuetype = 3;
			$$->caltype = 4;
			$$->leftcal = $1;
			$$->rightcal = $3;
		}
		|'-' cal
		{
			$$ = new struct calvalue;
			$$->valuetype = 3;
			$$->caltype = 2;
			$$->leftcal = new struct calvalue;
			$$->leftcal->valuetype=1;
			$$->leftcal->intnum=0;
			$$->rightcal = $2;
		}
		|'(' cal ')'{{$$ = $2;}}
		|INTNUM
		{
			$$ = new struct calvalue;
			$$->valuetype = 1;
			$$->leftcal = NULL;
			$$->rightcal = NULL;
			$$->intnum = $1.intnum;
		}
		|FLOATNUM
		{
			$$ = new struct calvalue;
			$$->valuetype = 2;
			$$->leftcal = NULL;
			$$->rightcal = NULL;
			$$->doublenum = $1.doublenum; 
		}
		;


updatestate: UPDATE tablename SET setconfs WHERE conditions ';'
			|UPDATE tablename SET setconfs ';'
			;
setconfs:	setconf
			|setconfs ',' setconf
			;
setconf:	table_field '=' value;


deletestate: DELETE FROM tablename WHERE conditions ';'
			|DELETE FROM tablename ';'
			;

exit:	EXIT ';';

%%
int main(void)
{	
	initdb();
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

