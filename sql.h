#include <vector>
#include <string>
using namespace std;

struct values
{
    char *name;
    int intnum;
    double doublenum;
    int length;
};

//createsql
struct coltype
{
    int type; //1:int, 2: double, 3:string
    int length;
};

// 列信息
struct cols
{
    char *colname;
    int coltype;
    int length;
    int num;
    struct cols *next;
};

struct createsql
{
    char *tablename;
    struct cols *cols;
};

//selectsql
struct fields
{
    char *colname;
    char *tablename;
    bool ifall;
    struct fields *next;
};

struct tablenames
{
    char *tablename;
    struct tablenames *next;
};

struct selectsql
{
    struct fields *fields;
    struct tablenames *tablenames; // 待完善
};

/* 数据库自用结构 */
struct Column
{
    string name;
    int type;
    vector<int> intdata;
    vector<float> floatdata;
    vector<string> strdata;
};

struct Table
{
    int num = 0;
    string name;
    vector<Column> all_cols;
};

struct Database
{
    int num = 0;
    string name;
    vector<Table> tables;
};

void createdb(char *);
void closedb();
void usedb(char *);
void createtable(struct createsql *);
void select(struct selectsql *);
void droptable(char *);
void dropdb(char *);