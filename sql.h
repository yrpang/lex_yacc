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

/* createsql */
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

/* selectsql */
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

/* insertsql */
struct calvalue //记录运算得到的值
{
    //valuetype: 1是int，2是double，3是表达式（如 1+2）；
    int valuetype;
    int intnum;
    double doublenum;
    struct calvalue *leftcal;
    //caltype: 1是+，2是-，3是*，4是/
    int caltype;
    struct calvalue *rightcal;
};

struct dataformat
{
    char *data;
    int length;
    int type; // 3:string
    int num;
    struct dataformat *next;
};

struct insertsql
{
    char *tablename;
    struct colname *colnames;
    struct dataformat *datas;
};

/* 数据库自用结构 */
struct Column
{
    string name;
    int type;
    vector<string> data;
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
void calculate(struct calvalue *);
void insert(struct insertsql *);