
# Create database users (enter password "lportal" for both users)
 $ sudo -u postgres createuser -S -D -R -l -i -P -E -e lportal_user
 $ sudo -u postgres createuser -S -d -R -l -i -P -E -e lportal_tester

# Create databases
 $ sudo -u postgres createdb lportal -e -E UNICODE -O lportal_user
 $ sudo -u postgres createdb lportal_test -e -E UNICODE -O lportal_tester

# Insert data
 $ sudo -u postgres psql -U lportal_user lportal < vendor/liferay-portal-sql-5.2.3/create/create-postgresql.sql

# Create test database
 $ sed -i 's/lportal/lportal_test/' vendor/liferay-portal-sql-5.2.3/create-minimal/create-minimal-postgresql.sql 
 $ sudo -u postgres psql -U lportal_tester lportal_test < vendor/liferay-portal-sql-5.2.3/create-minimal/create-minimal-postgresql.sql 

