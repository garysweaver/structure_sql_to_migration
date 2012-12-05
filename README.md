Rails 3 structure.sql to migration converter
=====

Converts `db/structure.sql` into a migration with up and down. Only tested with PostgreSQL 9.x. If you have a different version of postgres and/or are using a different database, it may or may not work.

### Installation

In your Gemfile, add:

    gem 'structure_sql_to_migration'

Then:

    bundle install

### Usage

#### Getting the initial structure.sql

Do not proceed unless you understand what you are doing with the following commands. Some may be destructive.

The migration it generates may be destructive as well. Do not run the migration that is generated without ensuring it is safe to use.

##### Option 1: Migrate to the initial state and dump structure.sql

1. If possible, rollback the schema to the point before any existing migrations in your application (if you have any):

        rake db:migrate VERSION=0

2. Dump the structure.sql:

        rake db:structure:dump

##### Option 2: Recover your database to the point before you made any migrations and dump structure.sql

1. Recover your database from a dump as necessary that reflected the database before any migrations were run

2. Dump the structure.sql:

        rake db:structure:dump

##### Option 3: Dump structure.sql and hand-modify to get back to initial state prior to migrations

1. Dump the structure.sql:

        rake db:structure:dump

2. Edit `db/structure.sql` to undo changes by all migrations:

#### Execute the rake task

To create: `db/000_create_initial_schema.rb`, run:

    rake structure_sql_to_migration

#### Troubleshooting

If your dump assumes multiline split support, then structure.sql will have that, and if it won't execute you may see errors like:

    PG::Error: ERROR:  unterminated dollar-quoted string at or near "$$

If that happens, for this example at least, either move the next line down up after the `$$`, or use `\` before end-of-lines in the offending section(s).

I would have it automatically fix those, but I'm trying to limit postgres-specific functionality, and I would have just assumed that the structure.sql would run (for the most part) when called in execute within a migration, except for the schema_migrations table, schema_migrations inserts, and related unique_schema_migrations index- we don't include those in the migration.

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[lic]: http://github.com/garysweaver/structure_sql_to_migration/blob/master/LICENSE
