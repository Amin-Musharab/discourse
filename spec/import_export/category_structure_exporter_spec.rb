# frozen_string_literal: true

require "import_export/category_structure_exporter"

RSpec.describe ImportExport::CategoryStructureExporter do
  before { STDOUT.stubs(:write) }

  it "export all the categories" do
    category = Fabricate(:category)
    data = ImportExport::CategoryStructureExporter.new.perform.export_data

    expect(data[:categories].count).to eq(2)
    expect(data[:groups].count).to eq(0)
    expect(data[:users].blank?).to eq(true)
  end

  it "export all the categories with permission groups" do
    category = Fabricate(:category)
    group = Fabricate(:group)
    category_group = Fabricate(:category_group, category: category, group: group)
    data = ImportExport::CategoryStructureExporter.new.perform.export_data

    expect(data[:categories].count).to eq(2)
    expect(data[:groups].count).to eq(1)
    expect(data[:users].blank?).to eq(true)
  end

  it "export all the categories with permission groups and users" do
    category = Fabricate(:category)
    group = Fabricate(:group)
    user = Fabricate(:user)
    category_group = Fabricate(:category_group, category: category, group: group)
    group_user = Fabricate(:group_user, group: group, user: user)
    data = ImportExport::CategoryStructureExporter.new(true).perform.export_data

    expect(data[:categories].count).to eq(2)
    expect(data[:groups].count).to eq(1)
    expect(data[:users].count).to eq(1)
  end
end
