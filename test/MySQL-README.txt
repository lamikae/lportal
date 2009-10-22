
CREATE DATABASE lportal CHARACTER SET utf8;
CREATE DATABASE lportal_test CHARACTER SET utf8;

GRANT ALL PRIVILEGES ON lportal.* TO lportal_user@'%' IDENTIFIED BY 'lportal';
GRANT ALL PRIVILEGES ON lportal_test.* TO lportal_tester@'%' IDENTIFIED BY 'lportal';

# Test connection
 $ mysql --host $MYSQL_HOST --port 3306 -u lportal_tester -plportal

# Insert data
 $ mysql --host arilou -u lportal_user -plportal < vendor/liferay-portal-sql-5.2.3/create/create-mysql.sql 

# Create test database
 $ sed -i 's/lportal/lportal_test/' vendor/liferay-portal-sql-5.2.3/create-minimal/create-minimal-mysql.sql 
 $ mysql --host arilou -u lportal_tester -plportal < vendor/liferay-portal-sql-5.2.3/create-minimal/create-minimal-mysql.sql 

