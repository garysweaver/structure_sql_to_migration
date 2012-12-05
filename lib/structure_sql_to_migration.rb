require 'structure_sql_to_migration/version'

module StructureSqlToMigration
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'tasks/structure_sql_to_migration.rake')
    end
  end
end
