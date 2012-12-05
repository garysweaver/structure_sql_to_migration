require 'tempfile'
require 'fileutils'

desc 'Attempts to convert db/structure.sql into db/000_create_initial_schema.rb.'
task :structure_sql_to_migration do
  drop_body = []
  structure_file = File.join('db','structure.sql')
  migration_file = File.join('db','migrate/000_create_initial_schema.rb')
  File.delete(migration_file) if File.exists?(migration_file)
  temp_file = Tempfile.new('000_create_initial_schema.rb')
  begin
    File.open(structure_file, 'r') do |file|
      header = <<-eos1
class CreateInitialSchema < ActiveRecord::Migration
  def up
    statements = <<-eos
eos1
      temp_file.puts header
      ignore_next_line = false
      file.each_line do |line|
        unless line.strip == '' || line.starts_with?("--")
          if line.starts_with?("INSERT INTO schema_migrations ") || line.starts_with?("CREATE TABLE schema_migrations") || line.starts_with?("CREATE UNIQUE INDEX unique_schema_migrations") 
            ignore_next_line = true
          end

          if ignore_next_line
            puts "ignoring: #{line}"
          else
            puts "   using: #{line}"
            # remove space from end of line and non-unix line-terminators so we can expect ";\n" at the real end of a function, for example
            temp_file.puts "#{line.rstrip}\n"
            if line.starts_with?("CREATE FUNCTION ")
              step1 = line.split(/[\(\)]/).collect{|t| t.strip==t ? t : t.split(' ')}.flatten
              function_name_with_args = "#{step1[0].split.last}(#{step1[1]})"
              drop_body << "DROP FUNCTION #{function_name_with_args} CASCADE;"
            elsif line.starts_with?("CREATE SEQUENCE ")
              name = (line.split)[2]
              if name.starts_with?('"')
                name = (line.split(/"/).collect{|t| t.strip==t ? t : t.split(' ')}.flatten)[2]
              end
              drop_body << "DROP SEQUENCE #{name} CASCADE;"
            elsif line.starts_with?("CREATE TABLE ")
              name = (line.split)[2]
              if name.starts_with?('"')
                name = (line.split(/"/).collect{|t| t.strip==t ? t : t.split(' ')}.flatten)[2]
              end
              drop_body << "DROP TABLE #{name} CASCADE;"
            end
          end

          ignore_next_line = false if line[';']
        end
      end
      middle = <<-eos1
eos
    statements.split(";\n").each {|s| execute s}
  end
  
  def down
    statements = <<-eos
eos1
      temp_file.puts middle
      drop_body.reverse.each {|s|temp_file.puts s}
      footer = <<-eos1
eos
    statements.split(";\n").each {|s| execute s}
  end
end
eos1
      temp_file.puts footer
    end
    temp_file.rewind
    FileUtils.mv(temp_file.path, migration_file)
  ensure
    temp_file.close
    temp_file.unlink
  end
end
