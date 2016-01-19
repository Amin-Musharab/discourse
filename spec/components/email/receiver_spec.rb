require "rails_helper"
require "email/receiver"

describe Email::Receiver do

  before do
    SiteSetting.email_in = true
    SiteSetting.reply_by_email_address = "reply+%{reply_key}@bar.com"
  end

  def email(email_name)
    fixture_file("emails/#{email_name}.eml")
  end

  def process(email_name)
    Email::Receiver.new(email(email_name)).process
  end

  it "raises an EmptyEmailError when 'mail_string' is blank" do
    expect { Email::Receiver.new(nil) }.to raise_error(Email::Receiver::EmptyEmailError)
    expect { Email::Receiver.new("") }.to raise_error(Email::Receiver::EmptyEmailError)
  end

  it "raises an NoMessageIdError when 'mail_string' is not an email" do
    expect { Email::Receiver.new("wat") }.to raise_error(Email::Receiver::NoMessageIdError)
  end

  it "raises an NoMessageIdError when 'mail_string' is missing the message_id" do
    expect { Email::Receiver.new(email(:missing_message_id)) }.to raise_error(Email::Receiver::NoMessageIdError)
  end

  it "raises an AutoGeneratedEmailError when the mail has no return path" do
    expect { process(:no_return_path) }.to raise_error(Email::Receiver::AutoGeneratedEmailError)
  end

  it "raises an AutoGeneratedEmailError when the mail is auto generated" do
    expect { process(:auto_generated_precedence) }.to raise_error(Email::Receiver::AutoGeneratedEmailError)
    expect { process(:auto_generated_header) }.to raise_error(Email::Receiver::AutoGeneratedEmailError)
  end

  it "raises a NoBodyDetectedError when the body is blank" do
    expect { process(:no_body) }.to raise_error(Email::Receiver::NoBodyDetectedError)
  end

  it "raises an InactiveUserError when the sender is inactive" do
    Fabricate(:user, email: "inactive@bar.com", active: false)
    expect { process(:inactive_sender) }.to raise_error(Email::Receiver::InactiveUserError)
  end

  skip "doesn't raise an InactiveUserError when the sender is staged" do
    Fabricate(:user, email: "staged@bar.com", active: false, staged: true)
    expect { process(:staged_sender) }.not_to raise_error
  end

  it "raises a BadDestinationAddress when destinations aren't matching any of the incoming emails" do
    expect { process(:bad_destinations) }.to raise_error(Email::Receiver::BadDestinationAddress)
  end

  context "reply" do

    let(:reply_key) { "4f97315cc828096c9cb34c6f1a0d6fe8" }
    let(:user) { Fabricate(:user, email: "discourse@bar.com") }
    let(:topic) { create_topic(user: user) }
    let(:post) { create_post(topic: topic, user: user) }
    let!(:email_log) { Fabricate(:email_log, reply_key: reply_key, user: user, topic: topic, post: post) }

    it "raises a ReplyUserNotMatchingError when the email address isn't matching the one we sent the notification to" do
      expect { process(:reply_user_not_matching) }.to raise_error(Email::Receiver::ReplyUserNotMatchingError)
    end

    it "raises a TopicNotFoundError when the topic was deleted" do
      topic.update_columns(deleted_at: 1.day.ago)
      expect { process(:reply_user_matching) }.to raise_error(Email::Receiver::TopicNotFoundError)
    end

    it "raises a TopicClosedError when the topic was closed" do
      topic.update_columns(closed: true)
      expect { process(:reply_user_matching) }.to raise_error(Email::Receiver::TopicClosedError)
    end

    it "raises an InvalidPost when there was an error while creating the post" do
      expect { process(:too_small) }.to raise_error(Email::Receiver::InvalidPost)
    end

    it "raises an InvalidPost when there are too may mentions" do
      SiteSetting.max_mentions_per_post = 1
      Fabricate(:user, username: "user1")
      Fabricate(:user, username: "user2")
      expect { process(:too_many_mentions) }.to raise_error(Email::Receiver::InvalidPost)
    end

    it "raises an InvalidPostAction when they aren't allowed to like a post" do
      topic.update_columns(archived: true)
      expect { process(:like) }.to raise_error(Email::Receiver::InvalidPostAction)
    end

    it "works" do
      expect { process(:text_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a text reply :)")
      expect(topic.posts.last.via_email).to eq(true)
      expect(topic.posts.last.cooked).not_to match(/<br/)

      expect { process(:html_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a <b>HTML</b> reply ;)")

      expect { process(:hebrew_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("שלום! מה שלומך היום?")

      expect { process(:chinese_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("您好！ 你今天好吗？")
    end

    it "prefers text over html" do
      expect { process(:text_and_html_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is the *text* part.")
    end

    it "removes the 'on <date>, <contact> wrote' quoting line" do
      expect { process(:on_date_contact_wrote) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is the actual reply.")
    end

    it "removes the 'Previous Replies' marker" do
      expect { process(:previous_replies) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This will not include the previous discussion that is present in this email.")
    end

    it "handles multiple paragraphs" do
      expect { process(:paragraphs) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("Do you like liquorice?\n\nI really like them. One could even say that I am *addicted* to liquorice. Anf if\nyou can mix it up with some anise, then I'm in heaven ;)")
    end

    it "handles inline reply" do
      expect { process(:inline_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("On Tue, Jan 15, 2016 at 11:12 AM, Bar Foo <info@unconfigured.discourse.org> wrote:\n\n> WAT <https://bar.com/users/wat> November 28\n>\n> This is the previous post.\n\nAnd this is *my* reply :+1:")
    end

    it "retrieves the first part of multiple replies" do
      expect { process(:inline_mixed_replies) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("On Tue, Jan 15, 2016 at 11:12 AM, Bar Foo <info@unconfigured.discourse.org> wrote:\n\n> WAT <https://bar.com/users/wat> November 28\n>\n> This is the previous post.\n\nAnd this is *my* reply :+1:\n\n> This is another post.\n\nAnd this is **another** reply.")
    end

    it "strips signatures" do
      expect { process(:iphone_signature) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is not the signature you're looking for.")

      expect { process(:signature) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("You shall not sign!")
    end

    it "strips 'original message' context" do
      expect { process(:original_message) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a reply :)")
    end

    it "supports attachments" do
      expect { process(:no_body_with_attachments) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to match(/<img/)

      expect { process(:inline_attachment) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to match(/Before\s+<img.+\s+After/m)
    end

    it "supports liking via email" do
      expect { process(:like) }.to change(PostAction, :count)
    end

    it "ensures posts aren't dated in the future" do
      expect { process(:from_the_future) }.to change { topic.posts.count }
      expect(topic.posts.last.created_at).to be_within(1.minute).of(DateTime.now)
    end

  end

  context "new message to a group" do

    let!(:group) { Fabricate(:group, incoming_email: "team@bar.com") }

    it "handles encoded display names" do
      expect { process(:encoded_display_name) }.to change(Topic, :count)

      topic = Topic.last
      expect(topic.private_message?).to eq(true)
      expect(topic.allowed_groups).to include(group)

      user = topic.user
      expect(user.staged).to eq(true)
      expect(user.username).to eq("random_name")
      expect(user.name).to eq("Случайная Имя")
    end

    it "invites everyone in the chain but users whose email matches the 'reply_by_email_address'" do
      expect { process(:cc) }.to change(Topic, :count)
      emails = Topic.last.allowed_users.pluck(:email)
      expect(emails.size).to eq(4)
      expect(emails).to include("someone@else.com", "discourse@bar.com", "team@bar.com", "wat@bar.com")
    end

  end

  context "new topic in a category" do

    let!(:category) { Fabricate(:category, email_in: "category@bar.com", email_in_allow_strangers: false) }

    it "raises a StrangersNotAllowedError when 'email_in_allow_strangers' is disabled" do
      expect { process(:stranger_not_allowed) }.to raise_error(Email::Receiver::StrangersNotAllowedError)
    end

    it "raises an InsufficientTrustLevelError when user's trust level isn't enough" do
      SiteSetting.email_in_min_trust = 4
      Fabricate(:user, email: "insufficient@bar.com", trust_level: 3)
      expect { process(:insufficient_trust_level) }.to raise_error(Email::Receiver::InsufficientTrustLevelError)
    end

    it "raises an InvalidAccess when the user is part of a readonly group" do
      user = Fabricate(:user, email: "readonly@bar.com", trust_level: SiteSetting.email_in_min_trust)
      group = Fabricate(:group)

      group.add(user)
      group.save

      category.set_permissions(group => :readonly)
      category.save

      expect { process(:readonly) }.to raise_error(Discourse::InvalidAccess)
    end

    it "works" do
      Fabricate(:user, email: "sufficient@bar.com", trust_level: SiteSetting.email_in_min_trust)
      expect { process(:sufficient_trust_level) }.to change(Topic, :count)
    end

  end

end
