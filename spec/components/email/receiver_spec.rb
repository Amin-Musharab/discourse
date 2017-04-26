require "rails_helper"
require "email/receiver"

describe Email::Receiver do

  before do
    SiteSetting.email_in = true
    SiteSetting.reply_by_email_address = "reply+%{reply_key}@bar.com"
    SiteSetting.alternative_reply_by_email_addresses = "alt+%{reply_key}@bar.com"
  end

  def process(email_name)
    Email::Receiver.new(email(email_name)).process!
  end

  it "raises an EmptyEmailError when 'mail_string' is blank" do
    expect { Email::Receiver.new(nil) }.to raise_error(Email::Receiver::EmptyEmailError)
    expect { Email::Receiver.new("") }.to raise_error(Email::Receiver::EmptyEmailError)
  end

  it "raises a ScreenedEmailError when email address is screened" do
    ScreenedEmail.expects(:should_block?).with("screened@mail.com").returns(true)
    expect { process(:screened_email) }.to raise_error(Email::Receiver::ScreenedEmailError)
  end

  it "raises an UserNotFoundError when staged users are disabled" do
    SiteSetting.enable_staged_users = false
    expect { process(:user_not_found) }.to raise_error(Email::Receiver::UserNotFoundError)
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

  it "raises a BlockedUserError when the sender has been blocked" do
    Fabricate(:user, email: "blocked@bar.com", blocked: true)
    expect { process(:blocked_sender) }.to raise_error(Email::Receiver::BlockedUserError)
  end

  skip "doesn't raise an InactiveUserError when the sender is staged" do
    Fabricate(:user, email: "staged@bar.com", active: false, staged: true)
    expect { process(:staged_sender) }.not_to raise_error
  end

  it "raises a BadDestinationAddress when destinations aren't matching any of the incoming emails" do
    expect { process(:bad_destinations) }.to raise_error(Email::Receiver::BadDestinationAddress)
  end

  it "raises a BouncerEmailError when email is a bounced email" do
    expect { process(:bounced_email) }.to raise_error(Email::Receiver::BouncedEmailError)
    expect(IncomingEmail.last.is_bounce).to eq(true)
  end

  context "bounces to VERP" do

    let(:bounce_key) { "14b08c855160d67f2e0c2f8ef36e251e" }
    let(:bounce_key_2) { "b542fb5a9bacda6d28cc061d18e4eb83" }
    let!(:user) { Fabricate(:user, email: "foo@bar.com") }
    let!(:email_log) { Fabricate(:email_log, user: user, bounce_key: bounce_key) }
    let!(:email_log_2) { Fabricate(:email_log, user: user, bounce_key: bounce_key_2) }

    before do
      $redis.del("bounce_score:#{user.email}:#{Date.today}")
      $redis.del("bounce_score:#{user.email}:#{2.days.from_now.to_date}")
    end

    it "deals with soft bounces" do
      expect { process(:soft_bounce_via_verp) }.to raise_error(Email::Receiver::BouncedEmailError)

      email_log.reload
      expect(email_log.bounced).to eq(true)
      expect(email_log.user.user_stat.bounce_score).to eq(1)
    end

    it "deals with hard bounces" do
      expect { process(:hard_bounce_via_verp) }.to raise_error(Email::Receiver::BouncedEmailError)

      email_log.reload
      expect(email_log.bounced).to eq(true)
      expect(email_log.user.user_stat.bounce_score).to eq(2)

      Timecop.freeze(2.days.from_now) do
        expect { process(:hard_bounce_via_verp_2) }.to raise_error(Email::Receiver::BouncedEmailError)

        email_log_2.reload
        expect(email_log_2.bounced).to eq(true)
        expect(email_log_2.user.user_stat.bounce_score).to eq(4)
      end
    end

  end

  context "reply" do

    let(:reply_key) { "4f97315cc828096c9cb34c6f1a0d6fe8" }
    let(:category) { Fabricate(:category) }
    let(:user) { Fabricate(:user, email: "discourse@bar.com") }
    let(:topic) { create_topic(category: category, user: user) }
    let(:post) { create_post(topic: topic, user: user) }
    let!(:email_log) { Fabricate(:email_log, reply_key: reply_key, user: user, topic: topic, post: post) }

    it "uses MD5 of 'mail_string' there is no message_id" do
      mail_string = email(:missing_message_id)
      expect { Email::Receiver.new(mail_string).process! }.to change { IncomingEmail.count }
      expect(IncomingEmail.last.message_id).to eq(Digest::MD5.hexdigest(mail_string))
    end

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

    it "does not raise TopicClosedError when performing a like action" do
      topic.update_columns(closed: true)
      expect { process(:like) }.to change(PostAction, :count)
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
      expect(topic.posts.last.raw).to eq("This is a **HTML** reply ;)")
    end

    it "doesn't process email with same message-id more than once" do
      expect do
        process(:text_reply)
        process(:text_reply)
      end.to change { topic.posts.count }.by(1)
    end

    it "handles different encodings correctly" do
      expect { process(:hebrew_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("שלום! מה שלומך היום?")

      expect { process(:chinese_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("您好！ 你今天好吗？")

      expect { process(:reply_with_weird_encoding) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a reply with a weird encoding.")

      expect { process(:reply_with_8bit_encoding) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("hab vergessen kritische zeichen einzufügen:\näöüÄÖÜß")

    end

    it "prefers text over html" do
      expect { process(:text_and_html_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is the *text* part.")
    end

    it "prefers html over text when site setting is enabled" do
      SiteSetting.incoming_email_prefer_html = true
      expect { process(:text_and_html_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq('This is the **html** part.')
    end

    it "uses text when prefer_html site setting is enabled but no html is available" do
      SiteSetting.incoming_email_prefer_html = true
      expect { process(:text_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a text reply :)")
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

    it "handles invalid from header" do
      expect { process(:invalid_from) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This email was sent with an invalid from header field.")
    end

    it "doesn't raise an AutoGeneratedEmailError when the mail is auto generated but is whitelisted" do
      SiteSetting.auto_generated_whitelist = "foo@bar.com|discourse@bar.com"
      expect { process(:auto_generated_whitelisted) }.to change { topic.posts.count }
    end

    it "doesn't raise an AutoGeneratedEmailError when block_auto_generated_emails is disabled" do
      SiteSetting.block_auto_generated_emails = false
      expect { process(:auto_generated_unblocked) }.to change { topic.posts.count }
    end

    it "allows staged users to reply to a restricted category" do
      user.update_columns(staged: true)

      category.email_in = "category@bar.com"
      category.email_in_allow_strangers = true
      category.set_permissions(Group[:trust_level_4] => :full)
      category.save

      expect { process(:staged_reply_restricted) }.to change { topic.posts.count }
    end

    describe 'Unsubscribing via email' do
      let(:last_email) { ActionMailer::Base.deliveries.last }

      describe 'unsubscribe_subject.eml' do
        it 'sends an email asking the user to confirm the unsubscription' do
          expect { process("unsubscribe_subject") }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(last_email.to.length).to eq 1
          expect(last_email.from.length).to eq 1
          expect(last_email.from).to include "noreply@#{Discourse.current_hostname}"
          expect(last_email.to).to include "discourse@bar.com"
          expect(last_email.subject).to eq I18n.t(:"unsubscribe_mailer.subject_template").gsub("%{site_title}", SiteSetting.title)
        end

        it 'does nothing unless unsubscribe_via_email is turned on' do
          SiteSetting.unsubscribe_via_email = false
          before_deliveries = ActionMailer::Base.deliveries.count
          expect { process("unsubscribe_subject") }.to raise_error { Email::Receiver::BadDestinationAddress }
          expect(before_deliveries).to eq ActionMailer::Base.deliveries.count
        end
      end

      describe 'unsubscribe_body.eml' do
        it 'sends an email asking the user to confirm the unsubscription' do
          expect { process("unsubscribe_body") }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(last_email.to.length).to eq 1
          expect(last_email.from.length).to eq 1
          expect(last_email.from).to include "noreply@#{Discourse.current_hostname}"
          expect(last_email.to).to include "discourse@bar.com"
          expect(last_email.subject).to eq I18n.t(:"unsubscribe_mailer.subject_template").gsub("%{site_title}", SiteSetting.title)
        end

        it 'does nothing unless unsubscribe_via_email is turned on' do
          SiteSetting.unsubscribe_via_email = false
          before_deliveries = ActionMailer::Base.deliveries.count
          expect { process("unsubscribe_body") }.to raise_error { Email::Receiver::InvalidPost }
          expect(before_deliveries).to eq ActionMailer::Base.deliveries.count
        end
      end
    end

    it "handles inline reply" do
      expect { process(:inline_reply) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("> WAT <https://bar.com/users/wat> November 28\n>\n> This is the previous post.\n\nAnd this is *my* reply :+1:")
    end

    it "retrieves the first part of multiple replies" do
      expect { process(:inline_mixed_replies) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("> WAT <https://bar.com/users/wat> November 28\n>\n> This is the previous post.\n\nAnd this is *my* reply :+1:\n\n> This is another post.\n\nAnd this is **another** reply.")
    end

    it "strips mobile/webmail signatures" do
      expect { process(:iphone_signature) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is not the signature you're looking for.")
    end

    it "strips 'original message' context" do
      expect { process(:original_message) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a reply :)")
    end

    it "add the 'elided' part of the original message only for private messages" do
      topic.update_columns(category_id: nil, archetype: Archetype.private_message)
      topic.allowed_users << user
      topic.save

      expect { process(:original_message) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to eq("This is a reply :)\n\n<details class='elided'>\n<summary title='Show trimmed content'>&#183;&#183;&#183;</summary>\n---Original Message---\nThis part should not be included\n</details>")
    end

    it "doesn't include the 'elided' part of the original message when always_show_trimmed_content is disabled" do
      SiteSetting.always_show_trimmed_content = false
      expect { process(:original_message) }.to change { topic.posts.count }.from(1).to(2)
      expect(topic.posts.last.raw).to eq("This is a reply :)")
    end

    it "adds the 'elided' part of the original message for public replies when always_show_trimmed_content is enabled" do
      SiteSetting.always_show_trimmed_content = true
      expect { process(:original_message) }.to change { topic.posts.count }.from(1).to(2)
      expect(topic.posts.last.raw).to eq("This is a reply :)\n\n<details class='elided'>\n<summary title='Show trimmed content'>&#183;&#183;&#183;</summary>\n---Original Message---\nThis part should not be included\n</details>")
    end

    it "supports attached images in TEXT part" do
      SiteSetting.queue_jobs = true

      expect { process(:no_body_with_image) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to match(/<img/)

      expect { process(:inline_image) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to match(/Before\s+<img.+>\s+After/)
    end

    it "supports attached images in HTML part" do
      SiteSetting.queue_jobs = true
      SiteSetting.incoming_email_prefer_html = true

      expect { process(:inline_image) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to match(/\*\*Before\*\*\s+<img.+>\s+\*After\*/)
    end

    it "supports attachments" do
      SiteSetting.authorized_extensions = "txt"
      expect { process(:attached_txt_file) }.to change { topic.posts.count }
      expect(topic.posts.last.raw).to match(/text\.txt/)
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

    let!(:group) { Fabricate(:group, incoming_email: "team@bar.com|meat@bar.com") }

    it "handles encoded display names" do
      expect { process(:encoded_display_name) }.to change(Topic, :count)

      topic = Topic.last
      expect(topic.title).to eq("I need help")
      expect(topic.private_message?).to eq(true)
      expect(topic.allowed_groups).to include(group)

      user = topic.user
      expect(user.staged).to eq(true)
      expect(user.username).to eq("random.name")
      expect(user.name).to eq("Случайная Имя")
    end

    it "handles email with no subject" do
      expect { process(:no_subject) }.to change(Topic, :count)
      expect(Topic.last.title).to eq("This topic needs a title")
    end

    it "invites everyone in the chain but emails configured as 'incoming' (via reply, group or category)" do
      expect { process(:cc) }.to change(Topic, :count)
      emails = Topic.last.allowed_users.joins(:user_emails).pluck(:"user_emails.email")
      expect(emails.size).to eq(3)
      expect(emails).to include("someone@else.com", "discourse@bar.com", "wat@bar.com")
    end

    it "cap the number of staged users created per email" do
      SiteSetting.maximum_staged_users_per_email = 1
      expect { process(:cc) }.to change(Topic, :count)
      expect(Topic.last.ordered_posts[-1].post_type).to eq(Post.types[:moderator_action])
    end

    it "associates email replies using both 'In-Reply-To' and 'References' headers" do
      expect { process(:email_reply_1) }.to change(Topic, :count)

      topic = Topic.last

      expect { process(:email_reply_2) }.to change { topic.posts.count }
      expect { process(:email_reply_3) }.to change { topic.posts.count }

      # Why 5 when we only processed 3 emails?
      #   - 3 of them are indeed "regular" posts generated from the emails
      #   - The 2 others are "small action" posts automatically added because
      #     we invited 2 users (two@foo.com and three@foo.com)
      expect(topic.posts.count).to eq(5)

      # trash all but the 1st post
      topic.ordered_posts[1..-1].each(&:trash!)

      expect { process(:email_reply_4) }.to change { topic.posts.count }
    end

    it "supports any kind of attachments when 'allow_all_attachments_for_group_messages' is enabled" do
      SiteSetting.allow_all_attachments_for_group_messages = true
      expect { process(:attached_rb_file) }.to change(Topic, :count)
      expect(Post.last.raw).to match(/discourse\.rb/)
    end

    context "with forwarded emails enabled" do
      before { SiteSetting.enable_forwarded_emails = true }

      it "handles forwarded emails" do
        expect { process(:forwarded_email_1) }.to change(Topic, :count)

        forwarded_post, last_post = *Post.last(2)

        expect(forwarded_post.user.email).to eq("some@one.com")
        expect(last_post.user.email).to eq("ba@bar.com")

        expect(forwarded_post.raw).to match(/XoXo/)
        expect(last_post.raw).to match(/can you have a look at this email below/)

        expect(last_post.post_type).to eq(Post.types[:regular])
      end

      it "handles weirdly forwarded emails" do
        group.add(Fabricate(:user, email: "ba@bar.com"))
        group.save

        SiteSetting.enable_forwarded_emails = true
        expect { process(:forwarded_email_2) }.to change(Topic, :count)

        forwarded_post, last_post = *Post.last(2)

        expect(forwarded_post.user.email).to eq("some@one.com")
        expect(last_post.user.email).to eq("ba@bar.com")

        expect(forwarded_post.raw).to match(/XoXo/)
        expect(last_post.raw).to match(/can you have a look at this email below/)

        expect(last_post.post_type).to eq(Post.types[:whisper])
      end

      # Who thought this was a good idea?!
      it "doesn't blow up with localized email headers" do
        expect { process(:forwarded_email_3) }.to change(Topic, :count)
      end

    end

  end

  context "new topic in a category" do

    let!(:category) { Fabricate(:category, email_in: "category@bar.com|category@foo.com", email_in_allow_strangers: false) }

    it "raises a StrangersNotAllowedError when 'email_in_allow_strangers' is disabled" do
      expect { process(:new_user) }.to raise_error(Email::Receiver::StrangersNotAllowedError)
    end

    it "raises an InsufficientTrustLevelError when user's trust level isn't enough" do
      Fabricate(:user, email: "existing@bar.com", trust_level: 3)
      SiteSetting.email_in_min_trust = 4
      expect { process(:existing_user) }.to raise_error(Email::Receiver::InsufficientTrustLevelError)
    end

    it "works" do
      user = Fabricate(:user, email: "existing@bar.com", trust_level: SiteSetting.email_in_min_trust)
      group = Fabricate(:group)

      group.add(user)
      group.save

      category.set_permissions(group => :create_post)
      category.save

      # raises an InvalidAccess when the user doesn't have the privileges to create a topic
      expect { process(:existing_user) }.to raise_error(Discourse::InvalidAccess)

      category.update_columns(email_in_allow_strangers: true)

      # allows new user to create a topic
      expect { process(:new_user) }.to change(Topic, :count)
    end

    it "adds the 'elided' part of the original message when always_show_trimmed_content is enabled" do
      SiteSetting.always_show_trimmed_content = true

      user = Fabricate(:user, email: "existing@bar.com", trust_level: SiteSetting.email_in_min_trust)
      expect { process(:forwarded_email_to_category) }.to change{Topic.count}.by(1) # Topic created

      new_post, = Post.last
      expect(new_post.raw).to include("Hi everyone, can you have a look at the email below?","<summary title='Show trimmed content'>&#183;&#183;&#183;</summary>","Discoursing much today?")
    end

    it "works when approving is enabled" do
      SiteSetting.approve_unless_trust_level = 4

      Fabricate(:user, email: "tl3@bar.com", trust_level: TrustLevel[3])
      Fabricate(:user, email: "tl4@bar.com", trust_level: TrustLevel[4])

      category.set_permissions(Group[:trust_level_4] => :full)
      category.save

      Group.refresh_automatic_group!(:trust_level_4)

      expect { process(:tl3_user) }.to_not change(Topic, :count)
      expect { process(:tl4_user) }.to change(Topic, :count)
    end

    it "ignores by title" do
      SiteSetting.ignore_by_title = "foo"
      expect { process(:ignored) }.to_not change(Topic, :count)
    end

  end

  context "new topic in a category that allows strangers" do

    let!(:category) { Fabricate(:category, email_in: "category@bar.com|category@foo.com", email_in_allow_strangers: true) }

    it "lets an email in from a stranger" do
      expect { process(:new_user) }.to change(Topic, :count)
    end

    it "lets an email in from a high-TL user" do
      Fabricate(:user, email: "tl4@bar.com", trust_level: TrustLevel[4])
      expect { process(:tl4_user) }.to change(Topic, :count)
    end

    it "fails on email from a low-TL user" do
      SiteSetting.email_in_min_trust = 4
      Fabricate(:user, email: "tl3@bar.com", trust_level: TrustLevel[3])
      expect { process(:tl3_user) }.to raise_error(Email::Receiver::InsufficientTrustLevelError)
    end

  end

  context "#reply_by_email_address_regex" do

    before do
      SiteSetting.reply_by_email_address = nil
      SiteSetting.alternative_reply_by_email_addresses = nil
    end

    it "is empty by default" do
      expect(Email::Receiver.reply_by_email_address_regex).to eq(//)
    end

    it "uses 'reply_by_email_address' site setting" do
      SiteSetting.reply_by_email_address = "foo+%{reply_key}@bar.com"
      expect(Email::Receiver.reply_by_email_address_regex).to eq(/foo\+(\h{32})@bar\.com/)
    end

    it "uses 'alternative_reply_by_email_addresses' site setting" do
      SiteSetting.alternative_reply_by_email_addresses = "alt.foo+%{reply_key}@bar.com"
      expect(Email::Receiver.reply_by_email_address_regex).to eq(/alt\.foo\+(\h{32})@bar\.com/)
    end

    it "combines both 'reply_by_email' settings" do
      SiteSetting.reply_by_email_address = "foo+%{reply_key}@bar.com"
      SiteSetting.alternative_reply_by_email_addresses = "alt.foo+%{reply_key}@bar.com"
      expect(Email::Receiver.reply_by_email_address_regex).to eq(/foo\+(\h{32})@bar\.com|alt\.foo\+(\h{32})@bar\.com/)
    end

  end

  context "check_address" do
    before do
      SiteSetting.reply_by_email_address = "foo+%{reply_key}@bar.com"
    end

    it "returns nil when the key is invalid" do
      expect(Email::Receiver.check_address('fake@fake.com')).to be_nil
      expect(Email::Receiver.check_address('foo+4f97315cc828096c9cb34c6f1a0d6fe8@bar.com')).to be_nil
    end

    context "with a valid reply" do
      it "returns the destination when the key is valid" do
        Fabricate(:email_log, reply_key: '4f97315cc828096c9cb34c6f1a0d6fe8')

        dest = Email::Receiver.check_address('foo+4f97315cc828096c9cb34c6f1a0d6fe8@bar.com')
        expect(dest).to be_present
        expect(dest[:type]).to eq(:reply)
        expect(dest[:obj]).to be_present
      end
    end
  end

end
