%{
#include <stdio.h>
#include <string>
#include "operations.h"
#include "sql.tab.h"

%}

%option caseless

letter [a-zA-Z]
digit [0-9]
digits {digit}+
optional_fraction ("."{digits})?
optional_exponent (E[+-]?{digits})?
string (\'[^\']*\')|(\"[^\"]*\")
id {letter}({letter}|{digit}|_)*


create create
table table
database database
use use
select select
insert insert
delete delete
update update
drop drop
from from
where where
into into
values values
set set
int int
double double
char char
and and
or or

symbol ";"|"("|")"|","|"+"|"-"|"*"|"/"|"."|"="|"<"|">"|"!"

exit exit

%%

{exit} {
    return EXIT;
}
{create} {
    return CREATE;
}
{table} {
    return TABLE;
}
{database} {
    return DATABASE;
}
{select} {
    return SELECT;
}
{insert} {
    return INSERT;
}
{delete} {
    return DELETE;
}
{drop} {
    return DROP;
}
{from} {
    return FROM;
}
{where} {
    return WHERE;
}
{into} {
    return INTO;
}
{values} {
    return VALUES;
}
{set} {
    return SET;
}
{int} {
    return INT;
}
{double} {
    return DOUBLE;
}
{char} {
    return CHAR;
}
{and} {
    return AND;
}
{or} {
    return OR;
}
{use} {
    return USE;
}

{digits} {
    // printf("整数%s：长度为%zu\n", yytext, yyleng);
    // printf("整数 ");
    yylval.value.length = 4;
	yylval.value.intnum=atoi(yytext);
    return INTNUM;
}

{digits}{optional_fraction} {
    // printf("浮点数 ");
    yylval.value.length = 8;
	yylval.value.doublenum = atof(yytext);
    return FLOATNUM;
}

{string} {
    yylval.value.length = strlen(yytext)+1; 
    yylval.value.name=(char *)malloc(strlen(yytext)+1);
    strlcpy(yylval.value.name, yytext, sizeof(yylval.value.name));
    // printf("字符串%s：长度为%zu\n", yytext, yyleng);
    return STRING;
}

{symbol} {
    // printf("%c ", yytext[0]);
    return yytext[0];
}

{id} {
    yylval.value.length = strlen(yytext)+1; 
    yylval.value.name=(char *)malloc(strlen(yytext)+1);
    strlcpy(yylval.value.name, yytext, sizeof(yylval.value.name));
    // printf("标识符 %s ", yytext);
    // printf("标识符 %s ", yylval.value.name);
    return ID;
}

[ \n\t]+

%%

// int main()
// {
//     for(;;)
//         yylex();

//     return 0;
// }