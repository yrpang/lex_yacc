#include <vector>
#include <string>
#include <boost/serialization/vector.hpp>
using namespace std;

struct values
{
    char *name;
    int intnum;
    double doublenum;
    int length;
};

/* createstate */
struct type
{
    int type; //1:int, 2: double, 3:string
    int length;
};

// 列信息
struct colstruct
{
    char *colname;
    int type;
    int length;
    int num;
    struct colstruct *next;
};

struct createstate
{
    char *tablename;
    struct colstruct *cols;
};

/* selectstate */
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

struct selectstate
{
    struct fields *fields;
    struct tablenames *tablenames; // 待完善
    struct conditions *conds;
};

/* insertstate */
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

struct insertstate
{
    char *tablename;
    struct colname *colnames;
    struct dataformat *datas;
};

/* 条件部分 */
struct condition_field
{
    int type; // 1:table_field 表名称 2:INTNUM 3:FLOATNUM
    struct fields *field; // 以field填充保留扩展性
    int intnum;
    double doublenum;
};

struct conditions
{
    // 0:null, 1:condition node, 2: virtual node(AND OR NOT)
    int node_type;
    int con_type; // < > <= >= != =
    struct condition_field *con_left;
    struct condition_field *con_right;
    int virtualtype; // AND OR
    struct conditions *left;
    struct conditions *right;
    bool result;
};

/* 数据库自用结构 */
struct Column
{
    string name;
    int type;
    vector<string> data;

    template <class Archive>
    void serialize(Archive &ar, const unsigned int version)
    {
        ar &name;
        ar &type;
        ar &data;
    }
};

struct Table
{
    int num = 0;
    string name;
    vector<Column> all_cols;

    template <class Archive>
    void serialize(Archive &ar, const unsigned int version)
    {
        ar &num;
        ar &name;
        ar &all_cols;
    }
};

struct Database
{
    int num = 0;
    string name;
    vector<Table> tables;

    template <class Archive>
    void serialize(Archive &ar, const unsigned int version)
    {
        ar &num;
        ar &name;
        ar &tables;
    }
};

void initdb();
void createdb(char *);
void closedb();
void usedb(char *);
void createtable(struct createstate *);
void select(struct selectstate *);
void droptable(char *);
void dropdb(char *);
void calculate(struct calvalue *);
void insert(struct insertstate *);