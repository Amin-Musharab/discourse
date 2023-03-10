# frozen_string_literal: true

Fabricator(:web_hook) do
  payload_url "https://meta.discourse.org/webhook_listener"
  content_type WebHook.content_types["application/json"]
  wildcard_web_hook false
  secret "my_lovely_secret_for_web_hook"
  verify_certificate true
  active true

  transient post_hook: WebHookEventType.find_by(name: "post")

  after_build { |web_hook, transients| web_hook.web_hook_event_types << transients[:post_hook] }
end

Fabricator(:inactive_web_hook, from: :web_hook) { active false }

Fabricator(:wildcard_web_hook, from: :web_hook) { wildcard_web_hook true }

Fabricator(:topic_web_hook, from: :web_hook) do
  transient topic_hook: WebHookEventType.find_by(name: "topic")

  after_build { |web_hook, transients| web_hook.web_hook_event_types = [transients[:topic_hook]] }
end

Fabricator(:post_web_hook, from: :web_hook) do
  transient topic_hook: WebHookEventType.find_by(name: "post")

  after_build { |web_hook, transients| web_hook.web_hook_event_types = [transients[:post_hook]] }
end

Fabricator(:user_web_hook, from: :web_hook) do
  transient user_hook: WebHookEventType.find_by(name: "user")

  after_build { |web_hook, transients| web_hook.web_hook_event_types = [transients[:user_hook]] }
end

Fabricator(:group_web_hook, from: :web_hook) do
  transient group_hook: WebHookEventType.find_by(name: "group")

  after_build { |web_hook, transients| web_hook.web_hook_event_types = [transients[:group_hook]] }
end

Fabricator(:category_web_hook, from: :web_hook) do
  transient category_hook: WebHookEventType.find_by(name: "category")

  after_build do |web_hook, transients|
    web_hook.web_hook_event_types = [transients[:category_hook]]
  end
end

Fabricator(:tag_web_hook, from: :web_hook) do
  transient tag_hook: WebHookEventType.find_by(name: "tag")

  after_build { |web_hook, transients| web_hook.web_hook_event_types = [transients[:tag_hook]] }
end

Fabricator(:reviewable_web_hook, from: :web_hook) do
  transient reviewable_hook: WebHookEventType.find_by(name: "reviewable")

  after_build do |web_hook, transients|
    web_hook.web_hook_event_types = [transients[:reviewable_hook]]
  end
end

Fabricator(:notification_web_hook, from: :web_hook) do
  transient notification_hook: WebHookEventType.find_by(name: "notification")

  after_build do |web_hook, transients|
    web_hook.web_hook_event_types = [transients[:notification_hook]]
  end
end

Fabricator(:user_badge_web_hook, from: :web_hook) do
  transient user_badge_hook: WebHookEventType.find_by(name: "user_badge")

  after_build do |web_hook, transients|
    web_hook.web_hook_event_types = [transients[:user_badge_hook]]
  end
end

Fabricator(:group_user_web_hook, from: :web_hook) do
  transient group_user_hook: WebHookEventType.find_by(name: "group_user")

  after_build do |web_hook, transients|
    web_hook.web_hook_event_types = [transients[:group_user_hook]]
  end
end

Fabricator(:like_web_hook, from: :web_hook) do
  transient like_hook: WebHookEventType.find_by(name: "like")

  after_build { |web_hook, transients| web_hook.web_hook_event_types = [transients[:like_hook]] }
end

Fabricator(:user_promoted_web_hook, from: :web_hook) do
  transient user_promoted_hook: WebHookEventType.find_by(name: "user_promoted")

  after_build do |web_hook, transients|
    web_hook.web_hook_event_types = [transients[:user_promoted_hook]]
  end
end
