import psycopg2 as ps
from datetime import date 

# state = 0 databases are equal
# state = 1 second database is datawarhouse
state = 1
#functions
###############################################################

# function for getting tables name from database
def get_table_name(cur):
    cur.execute("SELECT table_name FROM information_schema.tables WHERE table_type='BASE TABLE' AND table_schema='public';")
    row = cur.fetchall()
    tabels = []
    for r in row:
        tabels.append(r[0])
    return tabels


# function for getting attributes of each table in dictionary format
def get_attributes(cur, tabels):
    # cur: cursor to the database
    # tables: dictionary of name of each tabel in the database
    attributes = {}
    for i in range(len(tabels)):
        cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = '{tabels[i]}';")
        attr = cur.fetchall()
        attr_name = []
        for j in range(len(attr)):
            attr_name.append(attr[j][0])
        attributes[tabels[i]] = attr_name
    return attributes


#function for getting primary keys in dictionary format
def get_pk(cur, tabels):
    # cur: cursor to the database
    # tables: dictionary of name of each tabel in the database
    primary_keys = {}
    for i in range(len(tabels)):
        cur.execute("SELECT pg_attribute.attname\n"
                    "FROM pg_index, pg_class, pg_attribute, pg_namespace\n" 
                    f"WHERE pg_class.oid = '{tabels[i]}'::regclass AND  indrelid = pg_class.oid AND nspname = 'public' AND\n" 
                    "pg_class.relnamespace = pg_namespace.oid AND pg_attribute.attrelid = pg_class.oid AND\n" 
                    "pg_attribute.attnum = any(pg_index.indkey) AND indisprimary;")
        pks = cur.fetchall()
        primary_keys[tabels[i]] = pks[0][0]
    return primary_keys


#function for getting foreign key refrences in dictionary format
def get_fk(cur, tabels):
    # cur: cursor to the database
    # tables: dictionary of name of each tabel in the database
    foreign_ref = {}
    for i in range(len(tabels)):
        cur.execute("SELECT ccu.table_name AS foreign_table_name\n"
                    "FROM information_schema.table_constraints AS tc\n" 
                    "JOIN information_schema.key_column_usage AS kcu\n"
                    "ON tc.constraint_name = kcu.constraint_name\n"
                    "AND tc.table_schema = kcu.table_schema\n"
                    "JOIN information_schema.constraint_column_usage AS ccu\n"
                    "ON ccu.constraint_name = tc.constraint_name\n"
                    "AND ccu.table_schema = tc.table_schema\n"
                    f"WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name='{tabels[i]}';")
        fks = cur.fetchall()
        fk_ref = []
        for j in range(len(fks)):
            fk_ref.append(fks[j][0])
        foreign_ref[tabels[i]] = fk_ref
    return foreign_ref


#function for returning the number of records of one table
def count_records(cur, table_name):
    # table_name: name of the table which we want to find the number of rows
    cur.execute("SELECT COUNT(*)\n"
                f"FROM {table_name}\n;")
    count = cur.fetchall()[0][0]
    return count


#function for checking one table and return one of {"NOTHING", "INSERT", "UPDATE"}
def check_table(cur, table_name, pk_name, pk_value, list_row):
    # cur: is cursor to first database
    # table name: name of the table which we want to check 
    # pk_name: name of the primary key of the table which we want to check
    # pk_value: value of primary key of the first database 
    # list_row: value of each coloumn in first database
    result = "NOTHING"
    cur.execute(f"SELECT * FROM {table_name} WHERE {pk_name} = '{pk_value}';")
    row = cur.fetchall()
    if (row == []):
        result = "INSERT"
    else:
        for i in range(len(row[0])):
            if i < len(list_row):
                if row[0][i] != list_row[i]:
                    result = "UPDATE"
    return result


#function for chcking the tables in databases
def check_tables(cur1, cur2, table_name, pk_name, pk_index, attr_name):
    # cur1: is cursor to first database
    # cur2: is cursor to final database
    # table name: name of the table which we want to check 
    # pk_name: name of the primary key of the table which we want to check
    # pk_index: index the coloumn of primary key in the table
    # attr_name: list of the name of attributes of the table(we use it in insert or update function)  
    count = count_records(cur1, table_name)
    for i in range(count):
        cur1.execute(f"SELECT * FROM {table_name} limit 1 offset {i}")
        row = cur1.fetchall()                                           
        list_row = []                                                   # value of attributes
        for j in range(len(row[0])):
            if row[0][j] == None:
                list_row.append(None)
            else:
                if j == pk_index:
                    pk_value = row[0][j]
                list_row.append(row[0][j])

        result = check_table(cur2, table_name, pk_name, pk_value, list_row) 
        if result == "NOTHING":
            continue 
        elif result == "UPDATE":
            UPDATE_TABLE(cur2, table_name, pk_name, pk_value, list_row, attr_name)
        elif result == "INSERT":
            INSERT_TABLE(cur2, table_name, list_row, attr_name)  

    DELETE_TABLE(cur2, cur1, table_name, pk_name, pk_index)  
 
    return 0


# delete a row which had deleted
def DELETE_TABLE(cur2, cur1, table_name, pk_name, pk_index):
    count = count_records(cur2, table_name)
    d_pk = []
    for i in range(count):
    
        cur2.execute(f"SELECT * FROM {table_name} limit 1 offset {i}")
        row = cur2.fetchall()                                                  
        pk_value = row[0][pk_index]
        cur1.execute(f"SELECT * FROM {table_name} WHERE {pk_name} = \'{pk_value}\'")
        row1 = cur1.fetchall()
        if row1 == []:
            d_pk.append(pk_value)
    for i in range(len(d_pk)):
        print("DELETE")
        print(f"DELETE FROM {table_name} WHERE {pk_name} = \'{d_pk[i]}\'")  
        cur2.execute(f"DELETE FROM {table_name} WHERE {pk_name} = \'{d_pk[i]}\'")
          
    return 0


# insert a row in final database
def INSERT_TABLE(cur, table_name, list_row, attr_name):
    # cur: is cursor to first database
    # table name: name of the table which we want to insert
    # list_row: list of the attributes which we want to insert 
    attr = []                           # choose the not null attributes
    row = []              
    for i in range(len(list_row)):
        if list_row[i] == None:
            continue
        else:
            row.append(str(list_row[i]))
            attr.append(attr_name[i])
    
    
    str1 = "("
    for i in range(len(attr) - 1):
        
        str1 = str1 + attr[i] + ", " 
    str1 = str1 + attr[len(attr) - 1]
    if state == 1:
        str1 = str1 + " ,time_add_to_main"
        row.append(str(date.today()))
    str1 = str1 + ")"
    print("*****************", str1)

    print(f"INSERT INTO {table_name} {str1} VALUES {tuple(row)};")
    cur.execute(f"INSERT INTO {table_name} {str1} VALUES {tuple(row)};")
    
    return 0


# update a row in final database
def UPDATE_TABLE(cur, table_name, pk_name, pk_value, list_row, attr_name):
    attr = []                           # choose the not null attributes
    row = []              
    for i in range(len(list_row)):
        if list_row[i] == None:
            continue
        else:
            row.append(list_row[i])
            attr.append(attr_name[i])

    str1 = "SET "
    for i in range(len(attr)):
        if type(row[i]).__name__ == "int":
            str1 = str1 + attr[i] + " = " + str(row[i])
            
        else:
            str1 = str1 + attr[i] + " = " + f"\'{row[i]}\'" 
        if i < len(attr) - 1:
            str1 = str1 + ", "
    
    print(f"UPDATE {table_name} {str1}\n"
                f"WHERE {pk_name} = \'{pk_value}\';")
    cur.execute(f"UPDATE {table_name} {str1}\n"
                f"WHERE {pk_name} = \'{pk_value}\';")
    
    return 0


# create DAG
def create_DAG(fk):
    DAG = []
    while fk != {}:
        for i in range(len(tabels)):
            if tabels[i] in fk.keys():
                if fk[tabels[i]] == []:
                    DAG.append(tabels[i])
                    for j in fk:
                        if tabels[i] in fk[j]:
                            fk[j].remove(tabels[i])
                            if fk[j] == None:
                                fk[j] = []

                    del fk[tabels[i]]

    return DAG


###############################################################
# finish functions ....
# main code ...

# make connections
con1 = ps.connect(
    host = "localhost",
    database = "origin_database",
    user = "postgres",
    password = "postgres"
)
con1.autocommit = True
con2 = ps.connect(
    host = "localhost",
    database = "datawarhouse",
    user = "postgres",
    password = "postgres"
)
con2.autocommit = True


#initialize cursors
cur1 = con1.cursor()
cur2 = con2.cursor()

# get name of the tabeles of two databases
tabels = get_table_name(cur1)
# print(tabels)

# get coloumn name for each tables in dictionary format
attributes = get_attributes(cur1, tabels)
# print(attributes)

# get primary key of each table in dictionary format
primary_key = get_pk(cur1, tabels)
# print(primary_key)

# get foreign key refrences for each table in dictionary format
foreign_ref = get_fk(cur1, tabels)
# print(foreign_ref)

# create DAG
DAG = create_DAG(foreign_ref)
# print(DAG)

# check tabels
for i in range(len(DAG)):
    check_tables(cur1, cur2, DAG[i], primary_key[DAG[i]], attributes[DAG[i]].index(primary_key[DAG[i]]), attributes[DAG[i]])


# close the cursor
cur1.close()
cur2.close()


# close the connection
con1.close()
con2.close