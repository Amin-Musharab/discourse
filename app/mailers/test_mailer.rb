# frozen_string_literal: true

class TestMailer < ActionMailer::Base
  include Email::BuildEmailHelper

  def send_test(to_address, opts = {})
    build_email(to_address, template: "test_mailer", **opts)
  end
end
