# frozen_string_literal: true

class CategoryDetailedSerializer < BasicCategorySerializer
  attributes :topic_count,
             :post_count,
             :topics_day,
             :topics_week,
             :topics_month,
             :topics_year,
             :topics_all_time,
             :is_uncategorized,
             :subcategory_ids

  has_many :displayable_topics, serializer: ListableTopicSerializer, embed: :objects, key: :topics

  has_many :subcategory_list,
           serializer: CategoryDetailedSerializer,
           embed: :objects,
           key: :subcategory_list

  def include_displayable_topics?
    displayable_topics.present?
  end

  def include_subcategory_list?
    subcategory_list.present?
  end

  def is_uncategorized
    object.id == SiteSetting.uncategorized_category_id
  end

  def include_is_uncategorized?
    is_uncategorized
  end

  def topics_day
    count_with_subcategories(:topics_day)
  end

  def topics_week
    count_with_subcategories(:topics_week)
  end

  def topics_month
    count_with_subcategories(:topics_month)
  end

  def topics_year
    count_with_subcategories(:topics_year)
  end

  def topics_all_time
    count_with_subcategories(:topic_count)
  end

  def count_with_subcategories(method)
    count = object.public_send(method) || 0

    object.subcategories.each { |category| count += (category.public_send(method) || 0) }

    count
  end
end
