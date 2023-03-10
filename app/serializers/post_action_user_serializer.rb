# frozen_string_literal: true

class PostActionUserSerializer < BasicUserSerializer
  attributes :post_url, :username_lower, :unknown

  def id
    object.user.id
  end

  def username
    object.user.username
  end

  def username_lower
    object.user.username_lower
  end

  def avatar_template
    object.user.avatar_template
  end

  def post_url
    object.related_post.url if object.related_post_id && object.related_post
  end

  def unknown
    true
  end

  def include_unknown?
    (@options[:unknown_user_ids] || []).include?(object.user.id)
  end
end
