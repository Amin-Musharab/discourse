require 'spec_helper'
require 'email/sender'

describe Email::Sender do

  it "doesn't deliver mail when the message is nil" do
    Mail::Message.any_instance.expects(:deliver).never
    Email::Sender.new(nil, :hello).send
  end

  it "doesn't deliver when the to address is nil" do
    message = Mail::Message.new(body: 'hello')
    message.expects(:deliver).never
    Email::Sender.new(message, :hello).send
  end

  it "doesn't deliver when the body is nil" do
    message = Mail::Message.new(to: 'eviltrout@test.domain')
    message.expects(:deliver).never
    Email::Sender.new(message, :hello).send
  end

  context "list_id_for" do

    it "joins the host and forum name" do
      Email::Sender.list_id_for("myforum", "http://mysite.com").should == '"myforum" <myforum.mysite.com>'
    end

    it "uses localhost when no host is present" do
      Email::Sender.list_id_for("myforum", nil).should == '"myforum" <myforum.localhost>'
    end

    it "uses localhost with a weird host" do
      Email::Sender.list_id_for("Fun", "this is not a real host").should == '"Fun" <fun.localhost>'
    end

    it "removes double quotes from names" do
      Email::Sender.list_id_for('Quoted "Forum"', 'http://quoted.com').should == '"Quoted \'Forum\'" <quoted-forum.quoted.com>'
    end

    it "converts the site name to lower case and removes spaces" do
      Email::Sender.list_id_for("Robin's cool Forum!", "http://robin.com").should == '"Robin\'s cool Forum!" <robins-cool-forum.robin.com>'
    end

    it "downcases host names" do
      Email::Sender.list_id_for("cool", "http://ForumSite.com").should == '"cool" <cool.forumsite.com>'
    end

  end

  context 'with a valid message' do

    let(:reply_key) { "abcd" * 8 }

    let(:message) do
      message = Mail::Message.new to: 'eviltrout@test.domain',
                                  body: '**hello**'
      message.stubs(:deliver)
      message
    end

    let(:email_sender) { Email::Sender.new(message, :valid_type) }

    it 'calls deliver' do
      message.expects(:deliver).once
      email_sender.send
    end

    it "adds a List-Id header to identify the forum" do
      email_sender.send
      message.header['List-Id'].should be_present
    end

    context 'email logs' do
      let(:email_log) { EmailLog.last }

      When { email_sender.send }
      Then { expect(email_log).to be_present }
      Then { expect(email_log.email_type).to eq('valid_type') }
      Then { expect(email_log.to_address).to eq('eviltrout@test.domain') }
      Then { expect(email_log.reply_key).to be_blank }
      Then { expect(email_log.user_id).to be_blank }
    end

    context "email log with a post id and topic id" do
      before do
        message.header['X-Discourse-Post-Id'] = 3344
        message.header['X-Discourse-Topic-Id'] = 5577
      end

      let(:email_log) { EmailLog.last }
      When { email_sender.send }
      Then { expect(email_log.post_id).to eq(3344) }
      Then { expect(email_log.topic_id).to eq(5577) }
    end

    context "email log with a reply key" do
      before do
        message.header['X-Discourse-Reply-Key'] = reply_key
      end

      let(:email_log) { EmailLog.last }
      When { email_sender.send }
      Then { expect(email_log.reply_key).to eq(reply_key) }
    end


    context 'email parts' do
      When { email_sender.send }
      Then { expect(message).to be_multipart }
      Then { expect(message.text_part.content_type).to eq('text/plain; charset=UTF-8') }
      Then { expect(message.html_part.content_type).to eq('text/html; charset=UTF-8') }
      Then { expect(message.html_part.body.to_s).to match("<p><strong>hello</strong></p>") }
    end
  end

  context 'with a user' do
    let(:message) do
      message = Mail::Message.new to: 'eviltrout@test.domain', body: 'test body'
      message.stubs(:deliver)
      message
    end

    let(:user) { Fabricate(:user) }
    let(:email_sender) { Email::Sender.new(message, :valid_type, user) }

    before do
      email_sender.send
      @email_log = EmailLog.last
    end

    it 'should have the current user_id' do
      @email_log.user_id.should == user.id
    end


  end

end
