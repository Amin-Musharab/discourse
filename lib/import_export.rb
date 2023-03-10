# frozen_string_literal: true

require "import_export/importer"
require "import_export/base_exporter"
require "import_export/category_structure_exporter"
require "import_export/category_exporter"
require "import_export/topic_exporter"
require "import_export/group_exporter"
require "import_export/translation_overrides_exporter"
require "json"

module ImportExport
  def self.import(filename)
    data =
      ActiveSupport::HashWithIndifferentAccess.new(
        File.open(filename, "r:UTF-8") { |f| JSON.parse(f.read) },
      )
    ImportExport::Importer.new(data).perform
  end

  def self.export_category_structure(include_users, filename = nil)
    ImportExport::CategoryStructureExporter.new(include_users).perform.save_to_file(filename)
  end

  def self.export_categories(category_ids, filename = nil)
    ImportExport::CategoryExporter.new(category_ids).perform.save_to_file(filename)
  end

  def self.export_topics(topic_ids, filename = nil)
    ImportExport::TopicExporter.new(topic_ids).perform.save_to_file(filename)
  end

  def self.export_groups(include_users, filename = nil)
    ImportExport::GroupExporter.new(include_users).perform.save_to_file(filename)
  end

  def self.export_translation_overrides(filename = nil)
    ImportExport::TranslationOverridesExporter.new.perform.save_to_file(filename)
  end
end
