# frozen_string_literal: true

module Jobs
  # TODO (martin) Move into ChatChannel.ensure_consistency! so it
  # is run with ChatPeriodicalUpdates
  class UpdateUserCountsForChatChannels < ::Jobs::Scheduled
    every 1.hour

    # FIXME: This could become huge as the amount of channels grows, we
    # need a different approach here. Perhaps we should only bother for
    # channels updated or with new messages in the past N days? Perhaps
    # we could update all the counts in a single query as well?
    def execute(args = {})
      ChatChannel
        .where(status: %i[open closed])
        .find_each { |chat_channel| set_user_count(chat_channel) }
    end

    def set_user_count(chat_channel)
      current_count = chat_channel.user_count || 0
      new_count = ChatChannelMembershipsQuery.count(chat_channel)
      return if current_count == new_count

      chat_channel.update(user_count: new_count, user_count_stale: false)
      ChatPublisher.publish_chat_channel_metadata(chat_channel)
    end
  end
end
