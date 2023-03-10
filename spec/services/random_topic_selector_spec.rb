# frozen_string_literal: true

RSpec.describe RandomTopicSelector do
  it "can correctly use cache" do
    key = RandomTopicSelector.cache_key

    Discourse.redis.del key

    4.times { |t| Discourse.redis.rpush key, t }

    expect(RandomTopicSelector.next(0)).to eq([])
    expect(RandomTopicSelector.next(2)).to eq([0, 1])

    Discourse.redis.expects(:multi).returns(Discourse.received_redis_readonly!)
    expect(RandomTopicSelector.next(2)).to eq([2, 3])
    Discourse.redis.unstub(:multi)

    expect(RandomTopicSelector.next(2)).to eq([2, 3])
    expect(RandomTopicSelector.next(2)).to eq([])
  end

  it "can correctly backfill" do
    category = Fabricate(:category, sort_order: "op_likes")
    t1 = Fabricate(:topic, category_id: category.id)
    _t2 = Fabricate(:topic, category_id: category.id, visible: false)
    _t3 = Fabricate(:topic, category_id: category.id, deleted_at: 1.minute.ago)
    t4 = Fabricate(:topic, category_id: category.id)

    expect(RandomTopicSelector.next(5, category).sort).to eq([t1.id, t4.id].sort)
  end
end
