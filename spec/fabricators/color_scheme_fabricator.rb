# frozen_string_literal: true

Fabricator(:color_scheme) do
  name { sequence(:name) { |i| "Palette #{i}" } }
  color_scheme_colors(count: 2) do |attrs, i|
    Fabricate.build(:color_scheme_color, color_scheme: nil)
  end
end
