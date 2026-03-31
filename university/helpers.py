import psycopg2
from psycopg2.extensions import cursor
from psycopg2.extras import RealDictCursor
from config import Config

def get_db_connection():
    conn=psycopg2.connect(**Config.DATABASE)
    return conn

def execute_query(sql, params):
    conn=get_db_connection()
    cursor=conn.cursor(cursor_factory=RealDictCursor)
    try:
        cursor.execute(sql,params)
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return results
    except Exception as e:
        print(f"Error: {e}")
        return []

def execute_update(sql, params=None):
    conn=get_db_connection()
    cursor=conn.cursor()
    try:
        cursor.execute(sql, params)
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        conn.rollback()
        print(f"Error at {e} update didnt execute")
        return False

def call_procedure(proc_name, args=None):
    conn=get_db_connection()
    cursor=conn.cursor()
    try:
        cursor.callproc(proc_name, args)
        results=cursor.fetchall()
        conn.commit()
        cursor.close()
        conn.close()
        return results
    except Exception as e:
        conn.rollback()
        print(f"Error procedure at {e}")
        return []
