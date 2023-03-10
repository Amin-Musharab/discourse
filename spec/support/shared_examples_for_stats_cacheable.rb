# frozen_string_literal: true

RSpec.shared_examples_for "stats cacheable" do
  describe "fetch_cached_stats" do
    after { Discourse.redis.del(described_class.stats_cache_key) }

    it "returns the cached stats" do
      stats = described_class.fetch_stats.to_json
      Discourse.redis.set(described_class.stats_cache_key, stats)
      expect(described_class.fetch_cached_stats).to eq(JSON.parse(stats))
    end

    it "returns fetches the stats if stats has not been cached" do
      freeze_time

      Discourse.redis.del(described_class.stats_cache_key)
      expect(described_class.fetch_cached_stats).to eq(
        JSON.parse(described_class.fetch_stats.to_json),
      )
    end
  end

  describe "fetch_stats" do
    it "has not been implemented" do
      expect { described_class.fetch_stats }.to_not raise_error
    end
  end
end
