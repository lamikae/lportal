
# Create database users (enter password "lportal" for both users)
 $ sudo -u postgres createuser -S -D -R -l -i -P -E -e lportal_user # give password "lportal"
 $ sudo -u postgres createuser -S -d -R -l -i -P -E -e rails_tester # give password "rails"

# Create databases
 $ sudo -u postgres createdb lportal -e -E UNICODE -O lportal_user
 $ sudo -u postgres createdb lportal_test -e -E UNICODE -O rails_tester


# Insert data (optinal), you probably should just start up Liferay to populate the database
 $ sudo -u postgres psql -U lportal_user lportal < vendor/liferay-portal-sql-5.2.3/create/create-postgresql.sql

# Populate test database (required to run tests, even if you use live fixtures with the tests)
# Rails wants to drop all existing tables, and fails if they are not found
 $ sed 's/lportal/lportal_test/' vendor/liferay-portal-sql-5.2.3/create/create-postgresql.sql > testdb.sql
 $ sudo -u postgres psql -U rails_tester lportal_test < testdb.sql

# Then configure database.yml, or take a template from config/ directory.

