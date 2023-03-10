# frozen_string_literal: true

require "net/pop"

class POP3PollingEnabledSettingValidator
  def initialize(opts = {})
    @opts = opts
  end

  def valid_value?(val)
    # only validate when enabling polling
    return true if val == "f"
    # ensure we can authenticate
    SiteSetting.pop3_polling_host.present? && SiteSetting.pop3_polling_username.present? &&
      SiteSetting.pop3_polling_password.present? && authentication_works?
  end

  def error_message
    if SiteSetting.pop3_polling_host.blank?
      I18n.t("site_settings.errors.pop3_polling_host_is_empty")
    elsif SiteSetting.pop3_polling_username.blank?
      I18n.t("site_settings.errors.pop3_polling_username_is_empty")
    elsif SiteSetting.pop3_polling_password.blank?
      I18n.t("site_settings.errors.pop3_polling_password_is_empty")
    elsif !authentication_works?
      I18n.t("site_settings.errors.pop3_polling_authentication_failed")
    end
  end

  private

  def authentication_works?
    @authentication_works ||=
      begin
        EmailSettingsValidator.validate_pop3(
          host: SiteSetting.pop3_polling_host,
          port: SiteSetting.pop3_polling_port,
          ssl: SiteSetting.pop3_polling_ssl,
          username: SiteSetting.pop3_polling_username,
          password: SiteSetting.pop3_polling_password,
          openssl_verify: SiteSetting.pop3_polling_openssl_verify,
        )
      rescue *EmailSettingsExceptionHandler::EXPECTED_EXCEPTIONS => err
        false
      else
        true
      end
  end
end
