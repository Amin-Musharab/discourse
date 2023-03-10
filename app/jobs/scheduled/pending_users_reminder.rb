# frozen_string_literal: true

module Jobs
  class PendingUsersReminder < ::Jobs::Scheduled
    every 5.minutes

    def execute(args)
      if SiteSetting.must_approve_users && SiteSetting.pending_users_reminder_delay_minutes >= 0
        query = AdminUserIndexQuery.new(query: "pending", stats: false).find_users_query # default order is: users.created_at DESC
        if SiteSetting.pending_users_reminder_delay_minutes > 0
          query =
            query.where(
              "users.created_at < ?",
              SiteSetting.pending_users_reminder_delay_minutes.minutes.ago,
            )
        end

        newest_username = query.limit(1).select(:username).first&.username

        return true if newest_username == previous_newest_username # already notified

        count = query.count

        if count > 0
          target_usernames =
            Group[:moderators]
              .users
              .map do |user|
                next if user.bot?

                unseen_count =
                  user
                    .notifications
                    .joins(:topic)
                    .where("notifications.id > ?", user.seen_notification_id)
                    .where("notifications.read = false")
                    .where("topics.subtype = ?", TopicSubtype.pending_users_reminder)
                    .count

                unseen_count == 0 ? user.username : nil
              end
              .compact

          unless target_usernames.empty?
            PostCreator.create(
              Discourse.system_user,
              target_usernames: target_usernames,
              archetype: Archetype.private_message,
              subtype: TopicSubtype.pending_users_reminder,
              title:
                I18n.t("system_messages.pending_users_reminder.subject_template", count: count),
              raw:
                I18n.t(
                  "system_messages.pending_users_reminder.text_body_template",
                  count: count,
                  base_url: Discourse.base_url,
                ),
            )

            self.previous_newest_username = newest_username
          end
        end
      end

      true
    end

    def previous_newest_username
      Discourse.redis.get previous_newest_username_cache_key
    end

    def previous_newest_username=(username)
      Discourse.redis.setex previous_newest_username_cache_key, 7.days, username
    end

    def previous_newest_username_cache_key
      "pending-users-reminder:newest-username"
    end
  end
end
