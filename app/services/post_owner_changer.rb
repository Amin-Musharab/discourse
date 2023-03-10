# frozen_string_literal: true

class PostOwnerChanger
  def initialize(params)
    @post_ids = params[:post_ids]
    @topic = Topic.with_deleted.find_by(id: params[:topic_id].to_i)
    @new_owner = params[:new_owner]
    @acting_user = params[:acting_user]
    @skip_revision = params[:skip_revision] || false

    %i[post_ids topic new_owner acting_user].each do |arg|
      raise ArgumentError.new(arg) if self.instance_variable_get("@#{arg}").blank?
    end
  end

  def change_owner!
    @post_ids.each do |post_id|
      next unless post = Post.with_deleted.find_by(id: post_id, topic_id: @topic.id)

      if post.is_first_post?
        @topic.user = @new_owner
        @topic.recover! if post.user.nil?
      end

      post.topic = @topic
      post.set_owner(@new_owner, @acting_user, @skip_revision)
      PostActionDestroyer.destroy(@new_owner, post, :like, skip_delete_check: true)

      level = post.is_first_post? ? :watching : :tracking
      TopicUser.change(
        @new_owner.id,
        @topic.id,
        notification_level: NotificationLevels.topic_levels[level],
        posted: true,
      )

      if post ==
           @topic
             .posts
             .order("post_number DESC")
             .where("NOT hidden AND posts.deleted_at IS NULL")
             .first
        @topic.last_poster = @new_owner
      end

      @topic.update_statistics

      @new_owner.user_stat.update(
        first_post_created_at: @new_owner.reload.posts.order("created_at ASC").first&.created_at,
      )

      Post.where(topic_id: @topic.id, reply_to_post_number: post.post_number).update_all(
        reply_to_user_id: @new_owner.id,
      )

      @topic.save!(validate: false)
    end
  end
end
