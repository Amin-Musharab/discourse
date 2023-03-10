# frozen_string_literal: true

class PostActionNotifier
  def self.disable
    @disabled = true
  end

  def self.enable
    @disabled = false
  end

  # For testing purposes
  def self.reset!
    @custom_post_revision_notifier_recipients = nil
  end

  def self.alerter
    @alerter ||= PostAlerter.new
  end

  def self.refresh_like_notification(post, read)
    return unless post && post.user_id && post.topic

    usernames =
      post
        .post_actions
        .where(post_action_type_id: PostActionType.types[:like])
        .joins(:user)
        .order("post_actions.created_at desc")
        .where("post_actions.created_at > ?", 1.day.ago)
        .pluck(:username)

    if usernames.length > 0
      data = {
        topic_title: post.topic.title,
        username: usernames[0],
        display_username: usernames[0],
        username2: usernames[1],
        count: usernames.length,
      }
      Notification.create(
        notification_type: Notification.types[:liked],
        topic_id: post.topic_id,
        post_number: post.post_number,
        user_id: post.user_id,
        read: read,
        data: data.to_json,
      )
    end
  end

  def self.post_action_deleted(post_action)
    return if @disabled

    # We only care about deleting post actions for now
    return if post_action.deleted_at.blank?

    if post_action.post_action_type_id == PostActionType.types[:like] && post_action.post
      read = true

      Notification
        .where(
          topic_id: post_action.post.topic_id,
          user_id: post_action.post.user_id,
          post_number: post_action.post.post_number,
          notification_type: Notification.types[:liked],
        )
        .each do |notification|
          read = false unless notification.read
          notification.destroy
        end

      refresh_like_notification(post_action.post, read)
    else
      # not using destroy_all cause we want stuff to trigger
      Notification.where(post_action_id: post_action.id).each(&:destroy)
    end
  end

  def self.post_action_created(post_action)
    return if @disabled

    # We only notify on likes for now
    return unless post_action.is_like?

    post = post_action.post
    return if post_action.user.blank? || post.blank?

    alerter.create_notification(
      post.user,
      Notification.types[:liked],
      post,
      display_username: post_action.user.username,
      post_action_id: post_action.id,
      user_id: post_action.user_id,
    )
  end

  def self.after_create_post_revision(post_revision)
    return if @disabled

    post = post_revision.post

    return unless post
    return if post_revision.user.blank?
    return if post.topic.blank?
    return if post.topic.private_message?
    return if notification_is_disabled?(post_revision)

    user_ids = []

    user_ids << post.user_id if post_revision.user_id != post.user_id

    # Notify all users watching the topic when the OP of a wiki topic is edited
    # or if the topic category allows unlimited owner edits on the OP.
    if post.is_first_post? &&
         (post.wiki? || post.topic.category_allows_unlimited_owner_edits_on_first_post?)
      user_ids.concat(
        TopicUser
          .watching(post.topic_id)
          .where.not(user_id: post_revision.user_id)
          .where(topic: post.topic)
          .pluck(:user_id),
      )
    end

    custom_post_revision_notifier_recipients.each do |block|
      user_ids.concat(Array(block.call(post_revision)))
    end

    if user_ids.present?
      DB.after_commit do
        Jobs.enqueue(:notify_post_revision, user_ids: user_ids, post_revision_id: post_revision.id)
      end
    end
  end

  def self.after_post_unhide(post, flaggers)
    return if @disabled || post.last_editor.blank? || flaggers.blank?

    flaggers.each do |flagger|
      alerter.create_notification(
        flagger,
        Notification.types[:edited],
        post,
        display_username: post.last_editor.username,
        acting_user_id: post.last_editor.id,
      )
    end
  end

  def self.custom_post_revision_notifier_recipients
    @custom_post_revision_notifier_recipients ||= Set.new
  end

  def self.add_post_revision_notifier_recipients(&block)
    custom_post_revision_notifier_recipients << block
  end

  private

  def self.notification_is_disabled?(post_revision)
    modifications = post_revision.modifications
    (
      SiteSetting.disable_system_edit_notifications &&
        post_revision.user_id == Discourse::SYSTEM_USER_ID
    ) ||
      (
        SiteSetting.disable_category_edit_notifications &&
          modifications&.dig("category_id").present?
      ) || (SiteSetting.disable_tags_edit_notifications && modifications&.dig("tags").present?)
  end
end
