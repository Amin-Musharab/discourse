# frozen_string_literal: true

require "image_sizer"

module Jobs
  class SendSystemMessage < ::Jobs::Base
    def execute(args)
      raise Discourse::InvalidParameters.new(:user_id) unless args[:user_id].present?
      raise Discourse::InvalidParameters.new(:message_type) unless args[:message_type].present?

      user = User.find_by(id: args[:user_id])
      return if user.blank?

      system_message = SystemMessage.new(user)
      system_message.create(args[:message_type], args[:message_options]&.symbolize_keys || {})
    end
  end
end
