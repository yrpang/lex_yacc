// bug: 1.计算表达式的值 2.insert没有检验类型 3.

#include "sql.h"
#include <iostream>
#include <fstream>
#include <string>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/archive/binary_oarchive.hpp>
using namespace std;

vector<Database> all;
int db_now;

void initdb()
{
    db_now = -1;
    std::ifstream ifs("data.dat");
    if (ifs)
    {
        boost::archive::binary_iarchive ia(ifs);
        ia >> all;
    }
}

void closedb()
{
    std::ofstream ofs("data.dat");
    {
        boost::archive::binary_oarchive oa(ofs);
        oa << all;
    }

    cout << "saving... No shutdown!!!" << endl;
    exit(0);
}

void createdb(char *name)
{
    string dbnamestr(name);
    struct Database db;
    db.name = name;
    db.num = 0;
    all.push_back(db);

    // cout << all.size() << endl;
    cout << "Created " << name << endl;
}

void usedb(char *name)
{
    int i;
    for (i = 0; i < all.size(); i++)
    {
        if (all[i].name == name)
        {
            db_now = i;
            cout << "use db: " << name << " now." << endl;
            break;
        }
    }
    if (i >= all.size())
    {
        cout << "Error: db: " << name << " is not exist" << endl;
    }
}

void createtable(struct createsql *data)
{
    if (db_now == -1)
    {
        cout << "Error: no use db." << endl;
        return;
    }

    for (auto i : all[db_now].tables)
    {
        if (i.name == data->tablename)
        {
            cout << "Error: Table exists!";
            return;
        }
    }

    struct Table table;
    table.name = data->tablename;
    table.num = 0;

    struct cols *ptr = data->cols;
    while (ptr != NULL)
    {
        struct Column tmp;
        tmp.name = ptr->colname;
        tmp.type = ptr->coltype;
        table.num++;
        table.all_cols.push_back(tmp);
        ptr = ptr->next;
    }

    all[db_now].tables.push_back(table);

    // cout << table.num << endl;
    // cout << table.all_cols.size() << endl;
    cout << "Created " << data->tablename << endl;
}

void select(struct selectsql *sql)
{
    if (db_now == -1)
    {
        cout << "Error: no use db." << endl;
        return;
    }

    int table_index;
    for (table_index = 0; table_index < all[db_now].tables.size(); table_index++)
    {
        if (all[db_now].tables[table_index].name == string(sql->tablenames->tablename))
            break;
    }
    if (table_index >= all[db_now].tables.size())
    {
        cout << "Error: table fields now exist." << endl;
        return;
    }

    if (sql->fields->ifall)
    {
        for (auto i : all[db_now].tables[table_index].all_cols)
        {
            cout << i.name << ":";
            for (auto j : i.data)
                cout << j << " ";
            cout << endl;
        }
        cout << endl;
    }
}

void droptable(char *name)
{
    if (db_now == -1)
    {
        cout << "Error: no use db." << endl;
        return;
    }

    bool flag = false;
    for (vector<Table>::iterator iter = all[db_now].tables.begin(); iter != all[db_now].tables.end(); iter++)
    {
        if ((*iter).name == name)
        {
            iter = all[db_now].tables.erase(iter);
            iter--;
            flag = true;
        }
    }
    if (flag)
        cout << "deleted: " << name << endl;
    else
        cout << "not found." << endl;
}

void dropdb(char *name)
{
    bool flag = false;
    for (vector<Database>::iterator iter = all.begin(); iter != all.end(); iter++)
    {
        if ((*iter).name == name)
        {
            iter = all.erase(iter);
            iter--;
            flag = true;
        }
    }
    if (flag)
        cout << "deleted: " << name << endl;
    else
        cout << "not found." << endl;
}

void calculate(struct calvalue *cal)
{
    if (cal->valuetype == 1 || cal->valuetype == 2)
        return;

    if (cal->valuetype == 3)
    {
        calculate(cal->leftcal);
        calculate(cal->rightcal);

        struct calvalue *&left = cal->leftcal;
        struct calvalue *&right = cal->rightcal;

        if (left->valuetype == 1 && right->valuetype == 1)
        {
            cal->valuetype = 1;
            if (cal->caltype == 1)
            {
                cal->intnum = left->intnum + right->intnum;
            }
            else if (cal->caltype == 2)
            {
                cal->intnum = left->intnum - right->intnum;
            }
            else if (cal->caltype == 3)
            {
                cal->intnum = left->intnum * right->intnum;
            }
            else
            {
                cal->valuetype = 2;
                cal->doublenum = left->intnum / right->intnum;
            }
        }
        else if (left->valuetype == 1 && right->valuetype == 2)
        {
            cal->valuetype = 2;
            if (cal->caltype == 1)
            {
                cal->doublenum = left->intnum + right->doublenum;
            }
            else if (cal->caltype == 2)
            {
                cal->doublenum = left->intnum - right->doublenum;
            }
            else if (cal->caltype == 3)
            {
                cal->doublenum = left->intnum * right->doublenum;
            }
            else
            {
                cal->doublenum = left->intnum / right->doublenum;
            }
        }
        else if (left->valuetype == 2 && right->valuetype == 1)
        {
            cal->valuetype = 2;
            if (cal->caltype == 1)
            {
                cal->doublenum = left->doublenum + right->intnum;
            }
            else if (cal->caltype == 2)
            {
                cal->doublenum = left->doublenum - right->intnum;
            }
            else if (cal->caltype == 3)
            {
                cal->doublenum = left->doublenum * right->intnum;
            }
            else
            {
                cal->doublenum = left->doublenum / right->intnum;
            }
        }
        else
        {
            cal->valuetype = 2;
            cout << cal->caltype << endl;
            if (cal->caltype == 1)
            {
                cal->doublenum = left->doublenum + right->doublenum;
            }
            else if (cal->caltype == 2)
            {
                cal->doublenum = left->doublenum - right->doublenum;
            }
            else if (cal->caltype == 3)
            {
                cal->doublenum = left->doublenum * right->doublenum;
            }
            else
            {
                cal->doublenum = left->doublenum / right->doublenum;
            }
        }
        return;
    }
}

void insert(struct insertsql *sql)
{
    if (db_now == -1)
    {
        cout << "Error: no use db." << endl;
        return;
    }

    struct Database &db = all[db_now];
    int table_index = 0;
    for (table_index = 0; table_index < db.tables.size(); table_index++)
    {
        if (db.tables[table_index].name == sql->tablename)
            break;
    }
    if (table_index >= db.tables.size())
    {
        cout << "Table not exist" << endl;
        return;
    }

    struct Table &table = db.tables[table_index];

    struct dataformat *ptr = sql->datas;
    vector<dataformat> data;
    while (ptr != NULL)
    {
        data.push_back(*ptr);
        cout << ptr->data << " ";
        ptr = ptr->next;
    }
    if (data.size() != table.all_cols.size())
    {
        cout << "Error: values supply is not match with the columns.";
    }

    for (int i = 0; i < data.size(); i++)
    {
        table.all_cols[i].data.push_back(data[i].data);
    }

    cout << endl;
}