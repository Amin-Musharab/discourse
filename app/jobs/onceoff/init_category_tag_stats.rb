module Jobs
  class InitCategoryTagStats < Jobs::Onceoff
    def execute_onceoff(args)
      CategoryTagStat.exec_sql "DELETE FROM category_tag_stats"

      CategoryTagStat.exec_sql <<~SQL
    INSERT INTO category_tag_stats (category_id, tag_id, topic_count)
         SELECT topics.category_id, tags.id, COUNT(topics.id)
           FROM tags
     INNER JOIN topic_tags ON tags.id = topic_tags.tag_id
     INNER JOIN topics ON topics.id = topic_tags.topic_id
            AND topics.deleted_at IS NULL
       GROUP BY tags.id, topics.category_id
      SQL
    end
  end
end
