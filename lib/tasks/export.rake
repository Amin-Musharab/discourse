# frozen_string_literal: true

desc "Export all the categories"
task "export:categories", [:category_ids] => [:environment] do |_, args|
  require "import_export"
  ids = args[:category_ids].split(" ")

  ImportExport.export_categories(ids)
  puts "", "Done", ""
end

desc "Export only the structure of all categories"
task "export:category_structure", %i[include_group_users file_name] => [:environment] do |_, args|
  require "import_export"

  ImportExport.export_category_structure(args[:include_group_users], args[:file_name])
  puts "", "Done", ""
end

desc "Export all user groups"
task "export:groups", %i[include_group_users file_name] => [:environment] do |_, args|
  require "import_export"

  ImportExport.export_groups(args[:include_group_users], args[:file_name])
  puts "", "Done", ""
end

desc "Export all translation overrides"
task "export:translation_overrides" => [:environment] do |_, args|
  require "import_export"

  ImportExport.export_translation_overrides
  puts "", "Done", ""
end
