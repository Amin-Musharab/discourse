# frozen_string_literal: true

task "tags:bulk_tag_category", %i[tags category append] => [:environment] do |_, args|
  args.with_defaults(append: false)
  tags = args[:tags].split("|")
  category_id = args[:category]
  append = args[:append]

  if !tags || !category_id
    puts 'ERROR: Expecting tags:bulk_tag_category["tag",category_id]'
    exit 1
  end

  guardian = Guardian.new(Discourse.system_user)
  category = Category.find(category_id)

  tagged = 0
  total = category.topics.count

  category.topics.find_each do |topic|
    DiscourseTagging.tag_topic_by_names(topic, guardian, tags, append: append)
    print_status(tagged += 1, total)
  end

  puts "", "Done!", ""
end

def print_status(current, max)
  print "\r%9d / %d (%5.1f%%)" % [current, max, ((current.to_f / max.to_f) * 100).round(1)]
end
