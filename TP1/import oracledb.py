import oracledb
import os
from dotenv import load_dotenv

load_dotenv()

local_dsn = "tcps://db.freesql.com:2484/23ai_34ui2"
connection = oracledb.connect(
    user="MYSTYELLOW_SCHEMA_UNVK4",
    password="<CURRENT_PASSWORD>",
    dsn=local_dsn)

print("Successfully connected to Oracle Database")

cursor = connection.cursor()
for result in cursor.execute("SELECT * FROM DUAL"):
    print(result)
