#include "operations.h"
#include <iostream>
#include <fstream>
#include <string>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
using namespace std;

vector<Database> all;
int db_num;
int db_now;

void initdb()
{
    db_num = 0;
    db_now = -1;
}

void closedb()
{
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

    cout << table.num << endl;
    cout << table.all_cols.size() << endl;
}

void select(struct selectsql *sql)
{
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
            cout << i.name << " ";
        }
        cout << endl;
    }
}