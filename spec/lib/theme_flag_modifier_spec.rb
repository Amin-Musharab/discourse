# frozen_string_literal: true
RSpec.describe ThemeModifierHelper do
  fab!(:theme) do
    Fabricate(:theme).tap { |t| t.theme_modifier_set.update!(serialize_topic_excerpts: true) }
  end

  it "defines a getter for modifiers" do
    tmh = ThemeModifierHelper.new(theme_ids: [theme.id])
    expect(tmh.serialize_topic_excerpts).to eq(true)
  end

  it "can extract theme ids from a request object" do
    request = Rack::Request.new({ resolved_theme_id: theme.id })
    tmh = ThemeModifierHelper.new(request: request)
    expect(tmh.serialize_topic_excerpts).to eq(true)
  end
end
