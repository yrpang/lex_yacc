%{
#include <stdio.h>
#include <string.h>
#include "sql.tab.h"
// #define KEYWORD 0
// #define INTNUM 1
// #define FLOATNUM 2
// #define STRING 3
// #define ID 4

// #define CREATE 5
// #define TABLE 6
// #define DATABASE 7
// #define SELECT 8
// #define INSERT 9
// #define DELETE 10
// #define FROM 11
// #define WHERE 12
// #define INTO 13
// #define VALUES 14
// #define SET 15

// #define INT 16
// #define DOUBLE 17
// #define CHAR 18

// #define AND 19
// #define OR 20

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
    return INTNUM;
}

{digits}{optional_fraction} {
    // printf("浮点数 ");
    return FLOATNUM;
}

{string} {
    // printf("字符串%s：长度为%zu\n", yytext, yyleng);
    // printf("%s ", yytext);
    return STRING;
}

{symbol} {
    // printf("%c ", yytext[0]);
    return yytext[0];
}

{id} {
    // printf("标识符 ");
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