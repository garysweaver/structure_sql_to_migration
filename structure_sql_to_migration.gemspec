# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "structure_sql_to_migration/version" 

Gem::Specification.new do |s|
  s.name        = 'structure_sql_to_migration'
  s.version     = StructureSqlToMigration::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/garysweaver/structure_sql_to_migration'
  s.summary     = %q{Converts db/structure.sql into a migration.}
  s.description = %q{A rake task to generate a migration with up and down using db/structure.sql as input.}
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
  s.add_dependency 'rails', ['>= 3.0.0']
end
