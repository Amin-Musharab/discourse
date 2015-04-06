class TopicFeaturedUsers
  attr_reader :topic

  def initialize(topic)
    @topic = topic
  end

  def self.count
    4
  end

  # Chooses which topic users to feature
  def choose(args={})
    self.class.ensure_consistency!(topic.id.to_i)
    update_participant_count
  end

  def user_ids
    [topic.featured_user1_id,
     topic.featured_user2_id,
     topic.featured_user3_id,
     topic.featured_user4_id].uniq.compact
  end

  def self.ensure_consistency!(topic_id=nil)

    sql = <<SQL

WITH cte as (
    SELECT
        t.id,
        p.user_id,
        MAX(p.created_at) last_post_date,
        ROW_NUMBER() OVER(PARTITION BY t.id ORDER BY COUNT(*) DESC, MAX(p.created_at) DESC) as rank
    FROM topics t
    JOIN posts p ON p.topic_id = t.id
    WHERE p.deleted_at IS NULL AND
          NOT p.hidden AND
          p.user_id <> t.user_id AND
          p.user_id <> t.last_post_user_id
    GROUP BY t.id, p.user_id
),

cte2 as (
  SELECT id, user_id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY last_post_date ASC) as rank
  FROM cte
  WHERE rank <= #{count}
)

UPDATE topics tt
SET
  featured_user1_id = featured_user1,
  featured_user2_id = featured_user2,
  featured_user3_id = featured_user3,
  featured_user4_id = featured_user4
FROM (
  SELECT
      c.id,
      MAX(case when c.rank = 1 then c.user_id end) featured_user1,
      MAX(case when c.rank = 2 then c.user_id end) featured_user2,
      MAX(case when c.rank = 3 then c.user_id end) featured_user3,
      MAX(case when c.rank = 4 then c.user_id end) featured_user4
  FROM cte2 as c
  GROUP BY c.id
) x
WHERE x.id = tt.id AND
(
  COALESCE(featured_user1_id,-99) <> COALESCE(featured_user1,-99) OR
  COALESCE(featured_user2_id,-99) <> COALESCE(featured_user2,-99) OR
  COALESCE(featured_user3_id,-99) <> COALESCE(featured_user3,-99) OR
  COALESCE(featured_user4_id,-99) <> COALESCE(featured_user4,-99)
) #{"AND x.id = #{topic_id.to_i}" if topic_id}
SQL

    Topic.exec_sql(sql)
  end

  private

    def update_participant_count
      topic.update_columns(participant_count: topic.posts.count('distinct user_id'))
    end
end
