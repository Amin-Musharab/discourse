# frozen_string_literal: true

module Jobs
  class UnsilenceUsers < ::Jobs::Scheduled
    every 15.minutes

    def execute(args)
      User
        .where("silenced_till IS NOT NULL AND silenced_till < now()")
        .find_each { |user| UserSilencer.unsilence(user, Discourse.system_user) }
    end
  end
end
