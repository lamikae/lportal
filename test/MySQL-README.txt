mysql> CREATE DATABASE lportal_test;

mysql> GRANT ALL PRIVILEGES ON lportal_test.* TO lportal_tester@'%' IDENTIFIED BY 'lportal';

 $ mysql --host $MYSQL_HOST --port 3306 -u lportal_tester -plportal

