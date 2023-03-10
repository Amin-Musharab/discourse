# frozen_string_literal: true

module Jobs
  class ClosePoll < ::Jobs::Base
    def execute(args)
      %i[post_id poll_name].each do |key|
        raise Discourse::InvalidParameters.new(key) if args[key].blank?
      end

      DiscoursePoll::Poll.toggle_status(
        Discourse.system_user,
        args[:post_id],
        args[:poll_name],
        "closed",
        false,
      )
    end
  end
end
