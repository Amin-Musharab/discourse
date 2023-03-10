# frozen_string_literal: true

RSpec.describe StylesheetCache do
  describe ".add" do
    it "correctly cycles once MAX_TO_KEEP is hit" do
      StylesheetCache.destroy_all

      (StylesheetCache::MAX_TO_KEEP + 1).times do |i|
        StylesheetCache.add("a", "d" + i.to_s, "c" + i.to_s, "map")
      end

      expect(StylesheetCache.count).to eq StylesheetCache::MAX_TO_KEEP
      expect(StylesheetCache.order(:id).first.content).to eq "c1"
    end

    it "does nothing if digest is set and already exists" do
      StylesheetCache.delete_all

      expect(StylesheetCache.add("a", "b", "c", "map")).to be_present
      expect(StylesheetCache.add("a", "b", "cc", "map")).to eq(false)

      expect(StylesheetCache.count).to eq 1
      expect(StylesheetCache.first.content).to eq "c"
    end

    it "it retains stylesheets for competing targets" do
      StylesheetCache.destroy_all

      StylesheetCache.add("desktop", SecureRandom.hex, "body { }", "map", max_to_keep: 2)
      StylesheetCache.add("desktop", SecureRandom.hex, "body { }", "map", max_to_keep: 2)
      StylesheetCache.add("mobile", SecureRandom.hex, "body { }", "map", max_to_keep: 2)
      StylesheetCache.add("mobile", SecureRandom.hex, "body { }", "map", max_to_keep: 2)
      StylesheetCache.add("mobile", SecureRandom.hex, "body { }", "map", max_to_keep: 2)

      expect(StylesheetCache.order(:id).pluck(:target)).to eq(%w[desktop desktop mobile mobile])
    end
  end

  describe ".clean_up" do
    it "removes items older than threshold" do
      StylesheetCache.destroy_all

      StylesheetCache.add("a", "b", "c", "map")
      StylesheetCache.add("d", "e", "f", "map")

      above_threshold = StylesheetCache::CLEANUP_AFTER_DAYS - 1
      StylesheetCache.first.update!(created_at: above_threshold.days.ago)

      StylesheetCache.clean_up
      expect(StylesheetCache.all.size).to eq(2)

      below_threshold = StylesheetCache::CLEANUP_AFTER_DAYS + 1
      StylesheetCache.first.update!(created_at: below_threshold.days.ago)

      StylesheetCache.clean_up
      expect(StylesheetCache.all.size).to eq(1)
    end
  end
end
